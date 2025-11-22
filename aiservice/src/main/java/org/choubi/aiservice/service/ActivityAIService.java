package org.choubi.aiservice.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.choubi.aiservice.model.Activity;
import org.choubi.aiservice.model.Recommendation;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class ActivityAIService {
    private final GeminiService geminiService;

    public Recommendation generateActivityRecommendation(Activity activity) {
        String prompt = createPromptForActivity(activity);
        log.info("Generating activity recommendation for prompt: {}", prompt);
        String response;
        try {
            response = geminiService.getGeminiResponse(prompt);
        } catch (WebClientResponseException e) {
            // On transient errors (e.g., 503/429) or other HTTP errors, fall back to a default recommendation
            log.error("Gemini API call failed: status={}, message={}", e.getStatusCode().value(), e.getMessage());
            return generateDefaultRecommendation(activity);
        } catch (Exception e) {
            log.error("Unexpected error when calling Gemini API: {}", e.getMessage(), e);
            return generateDefaultRecommendation(activity);
        }
        log.info("Received response from GeminiService: {}", response);
        Recommendation processedResponse = proccessAIResponse(activity,response);
        log.info("Processed AI response: {}", processedResponse);
        return processedResponse;
    }

    public Recommendation proccessAIResponse(Activity activity,String aiResponse)  {

        ObjectMapper mapper = new ObjectMapper();
        try{
            // Parse the raw Gemini API JSON
            JsonNode root = mapper.readTree(aiResponse);
            JsonNode textNode = root.path("candidates")
                    .path(0)
                    .path("content")
                    .path("parts")
                    .path(0)
                    .path("text");

            if (textNode.isMissingNode() || textNode.isNull()) {
                log.error("AI response missing candidates[0].content.parts[0].text; using default recommendation");
                return generateDefaultRecommendation(activity);
            }

            String text = textNode.asText();
            // Strip markdown code fences like ```json ... ``` or ``` ... ```
            String cleaned = text.trim()
                    .replaceFirst("^```(?i:json)?\\s*", "")
                    .replaceFirst("\\s*```$", "")
                    .trim();

            // Validate and normalize to compact JSON
            try {
                JsonNode JsonContent = mapper.readTree(cleaned);

                StringBuilder analysis = new StringBuilder();
                JsonNode analysisNode = JsonContent.path("analysis");
                addAnalysisSection(analysisNode, analysis,"overall","Overall Analysis :");
                addAnalysisSection(analysisNode, analysis,"pace","\nPace Analysis :");
                addAnalysisSection(analysisNode, analysis,"heartRate","\n Heart Rate Analysis");
                addAnalysisSection(analysisNode, analysis,"caloriesBurned","\n Calories Burned Analysis :");

                List<String> improvements = new ArrayList<>();
                JsonNode improvementsNode = JsonContent.path("improvements");
                extractImprovements(improvementsNode, improvements);

                List<String> suggestions = new ArrayList<>();
                JsonNode suggestionsNode = JsonContent.path("suggestions");
                extractSuggestions(suggestionsNode, suggestions);

                List<String> safetyTips = new ArrayList<String>();
                JsonNode safetyNode = JsonContent.path("safety");
                extractSafetyTips(safetyNode, safetyTips);

                Recommendation recommendation = Recommendation.builder()
                        .activityId(activity.getId())
                        .userId(activity.getUserId())
                        .activityType(activity.getType().toString())
                        .recommendation(analysis.toString())
                        .improvements(improvements)
                        .suggestions(suggestions)
                        .safety(safetyTips)
                        .createdAt(LocalDateTime.now())
                        .build();

                return recommendation;

            } catch (JsonProcessingException e) {
                // If it's not valid JSON after cleaning, return default recommendation
                log.warn("Inner AI text is not valid JSON after cleaning; using default recommendation. Error: {}", e.getMessage());
                return generateDefaultRecommendation(activity);
            }

        }catch(JsonProcessingException e){
            log.error("Failed to parse AI response: {}", e.getMessage(), e);
            return generateDefaultRecommendation(activity);
        }
    }

    public Recommendation generateDefaultRecommendation(Activity activity) {
        String defaultText = "Based on your recent activity, maintain a consistent pace and monitor your heart rate to optimize performance. Consider incorporating interval training to enhance endurance and calorie burn. Always ensure proper hydration and warm-up routines to prevent injuries.";
        return Recommendation.builder()
                .activityId(activity.getId())
                .userId(activity.getUserId())
                .activityType(activity.getType().toString())
                .recommendation(defaultText)
                .improvements(new ArrayList<>())
                .suggestions(new ArrayList<>())
                .safety(new ArrayList<>())
                .createdAt(LocalDateTime.now())
                .build();
    }

    private void extractSafetyTips(JsonNode safetyNode, List<String> safetyTips) {
        if(safetyNode.isArray()){
            safetyNode.forEach(tip->{
                if (tip.isTextual()) {
                    safetyTips.add(tip.asText());
                } else if (tip.isObject()) {
                    // if AI returns objects, try a 'text' field fallback
                    String val = tip.path("text").asText(null);
                    if (val != null) safetyTips.add(val);
                }
            });
        }
    }

    private void extractSuggestions(JsonNode suggestionsNode, List<String> suggestions) {
        if(suggestionsNode.isArray()){
            suggestionsNode.forEach(suggestion->{
                String workout = suggestion.path("workout").asText();
                String description = suggestion.path("description").asText();
                suggestions.add(String.format("%s : %s", workout, description));
            });
        }
    }

    private void extractImprovements(JsonNode improvementsNode, List<String> improvements) {
        if (improvementsNode.isArray()) {
            for (JsonNode improvement : improvementsNode) {
                String area = improvement.path("area").asText();
                String recommendation = improvement.path("recommendation").asText();
                improvements.add(String.format("%s : %s", area, recommendation));
            }
        }

    }

    private void addAnalysisSection(JsonNode jsonContent, StringBuilder recommandation, String node, String prefix) {
        recommandation.append(prefix)
                .append(jsonContent.path(node).asText());
    }

    private String createPromptForActivity(Activity activity) {
        return String.format("""
                Analyze this fitness activity and provide detailed recommendations in the following EXACT JSON format:
                {
                    "analysis":{
                        "overall":"Overall analysis here",
                        "pace":"Pace analysis here",
                        "heartRate":"Heart rate analysis here",
                        "caloriesBurned":"Calories analysis here"
                    },
                    "improvements":[
                        {
                           "area":"Area to improve",
                           "recommendation":"Detailed recommendation"
                        }
                    ],
                    "suggestions":[
                        {
                           "workout":"Workout name",
                           "description":"Detailed Workout description"
                        }
                    ],
                    "safety":[
                       "Safety point 1",
                       "Safety point 2"
                    ]
                }
                
                Analyze this activity:
                Type: %s
                Duration: %d minutes
                Calories Burned: %d
                Additional Metrics: %s
                
                Provide detailed analysis focusing on performance, improvements, next workout suggestions, and safety tips.
                Respond with ONLY the JSON object above; do not include code fences or any extra text.
                """,
                activity.getType(),
                activity.getDuration(),
                activity.getCaloriesBurned(),
                activity.getAdditionalMetrics()
        );
    }
}
