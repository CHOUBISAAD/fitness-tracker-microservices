package org.choubi.activityservice.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.choubi.activityservice.dto.ActivityRequest;
import org.choubi.activityservice.dto.ActivityResponse;
import org.choubi.activityservice.microRequestInterface.UserServiceInterface;
import org.choubi.activityservice.model.Activity;
import org.choubi.activityservice.repository.ActivityRepository;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActivityService {

    private final ActivityRepository activityRepository;
    private final UserServiceInterface userService;
    private final RabbitTemplate rabbitTemplate;

    @Value("${rabbitmq.exchanges.name}")
    private String exchangeName;
    @Value("${rabbitmq.routing.key}")
    private String routingKey;



    public ActivityResponse trackActivity(ActivityRequest activityRequest) {
        Activity activity = Activity.builder()
                .userId(activityRequest.getUserId())
                .type(activityRequest.getActivityType())
                .duration(activityRequest.getDuration())
                .caloriesBurned(activityRequest.getCaloriesBurned())
                .startTime(activityRequest.getStartTime())
                .additionalMetrics(activityRequest.getAdditionalMetrics())
                .build();

        Activity savedActivity = activityRepository.save(activity);
        try{
            rabbitTemplate.convertAndSend(exchangeName, routingKey, savedActivity);
        }catch (Exception e){
            log.error("Failed to send message to RabbitMQ: {}", e.getMessage());
        }
        return new ActivityResponse(savedActivity);
    }


    public List<ActivityResponse> getUserActivities(String userId) {
        if(!userService.validate(userId)){
            return null;
        }
        List<Activity> activities = activityRepository.findByUserId(userId);
        return activities.stream()
                .map(ActivityResponse::new)
                .collect(Collectors.toList());
    }

    public ActivityResponse getActivityById(String activityId) {
        return activityRepository.findById(activityId).map(ActivityResponse::new).orElseThrow();
    }
}
