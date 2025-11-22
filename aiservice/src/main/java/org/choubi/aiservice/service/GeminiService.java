package org.choubi.aiservice.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.Duration;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@Service
public class GeminiService {

    @Value("${gemini.api.url}")
    private String GEMINI_API_URL;
    @Value("${gemini.api.key}")
    private String GEMINI_API_KEY;
    @Value("${gemini.api.fallback-url:}")
    private String GEMINI_API_FALLBACK_URL;
    @Value("${gemini.retry.maxAttempts:3}")
    private int maxAttempts;
    @Value("${gemini.retry.baseBackoffMs:500}")
    private long baseBackoffMs;

    private final WebClient webClient;
    private static final Logger log = LoggerFactory.getLogger(GeminiService.class);

    public GeminiService(WebClient.Builder webClient) {
        this.webClient = webClient.build();
    }

    public String getGeminiResponse(String prompt) {
        // Build request body according to Generative Language API schema
        Map<String, Object> requestBody = Map.of(
                "contents", new Object[]{
                        Map.of(
                                "role", "user",
                                "parts", new Object[]{
                                        Map.of("text", prompt)
                                }
                        )
                }
        );

        String primaryUrl = appendApiKey(GEMINI_API_URL, GEMINI_API_KEY);
        System.out.println("Using Gemini API URL: " + primaryUrl);

        // Try primary URL with retries
        try {
            return callWithRetries(primaryUrl, requestBody, maxAttempts, baseBackoffMs);
        } catch (WebClientResponseException last) {
            // If primary fails after retries and fallback is configured, try fallback once with limited retries
            if (GEMINI_API_FALLBACK_URL != null && !GEMINI_API_FALLBACK_URL.isBlank()) {
                String fallbackUrl = appendApiKey(GEMINI_API_FALLBACK_URL, GEMINI_API_KEY);
                log.warn("Primary model failed after retries (status {}). Trying fallback model URL...", last.getStatusCode().value());
                return callWithRetries(fallbackUrl, requestBody, Math.max(2, maxAttempts / 2), baseBackoffMs);
            }
            throw last;
        }
    }

    private String callWithRetries(String url, Map<String, Object> body, int attempts, long baseBackoff) {
        for (int attempt = 1; attempt <= attempts; attempt++) {
            try {
                String json = webClient.post()
                        .uri(url)
                        .header("Content-Type", "application/json")
                        .header("Accept", "application/json")
                        .bodyValue(body)
                        .retrieve()
                        .bodyToMono(String.class)
                        .block();
                return json != null ? json : "";
            } catch (WebClientResponseException e) {
                int status = e.getStatusCode().value();
                log.error("Gemini API request failed with status {} and body: {}", status, e.getResponseBodyAsString());
                if ((status == 503 || status == 429) && attempt < attempts) {
                    long sleepMs = computeBackoff(e, baseBackoff, attempt);
                    long jitter = ThreadLocalRandom.current().nextLong(0, baseBackoff + 1);
                    long totalSleep = sleepMs + jitter;
                    log.warn("Transient error ({}). Retrying attempt {}/{} after {} ms...", status, attempt + 1, attempts, totalSleep);
                    sleepQuietly(totalSleep);
                    continue;
                }
                throw e;
            }
        }
        return ""; // should not reach
    }

    private long computeBackoff(WebClientResponseException e, long baseBackoffMs, int attempt) {
        try {
            String retryAfter = e.getHeaders() != null ? e.getHeaders().getFirst("Retry-After") : null;
            if (retryAfter != null) {
                String trimmed = retryAfter.trim();
                try {
                    long seconds = Long.parseLong(trimmed);
                    return Duration.ofSeconds(seconds).toMillis();
                } catch (NumberFormatException nfe) {
                    try {
                        ZonedDateTime when = ZonedDateTime.parse(trimmed, DateTimeFormatter.RFC_1123_DATE_TIME);
                        long millis = Duration.between(ZonedDateTime.now(), when).toMillis();
                        return Math.max(millis, baseBackoffMs);
                    } catch (Exception ignored2) { /* fall through */ }
                }
            }
        } catch (Exception ignored) {}
        return baseBackoffMs * (1L << (attempt - 1));
    }

    private void sleepQuietly(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException ie) {
            Thread.currentThread().interrupt();
        }
    }

    private String appendApiKey(String baseUrl, String apiKey) {
        if (baseUrl == null || baseUrl.isBlank()) return baseUrl;
        String delimiter = baseUrl.contains("?") ? "&" : "?";
        // Avoid duplicating key if already present
        if (baseUrl.contains("key=")) return baseUrl;
        return baseUrl + delimiter + "key=" + apiKey;
    }
}
