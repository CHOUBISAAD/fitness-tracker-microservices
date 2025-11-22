package org.choubi.aiservice.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.choubi.aiservice.model.Activity;
import org.choubi.aiservice.model.Recommendation;
import org.choubi.aiservice.repository.RecommendationRepository;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ActivityMessageListener {

    private final ActivityAIService activityService;
    private final RecommendationRepository recommendationRepository;

    @RabbitListener(queues = "activity.queue")
    public void handleActivityMessage(Activity activity) {
        log.info("Received activity message: {}" , activity);
        try {
            Recommendation recommendation = activityService.generateActivityRecommendation(activity);
            recommendationRepository.save(recommendation);
            log.info("Generated Recommendation : {}" , recommendation);
        } catch (Exception e) {
            log.error("Failed to generate recommendation for activity {}: {}", activity.getId(), e.getMessage(), e);
            // Swallow exception so the message isn't requeued endlessly; consider routing to a DLQ instead.
        }
    }
}
