package org.choubi.activityservice.dto;

import lombok.Data;
import org.choubi.activityservice.model.ActivityType;

import java.time.LocalDateTime;
import java.util.Map;

@Data
public class ActivityRequest {
    private String userId;
    private ActivityType activityType;
    private Integer duration; // in minutes
    private Integer caloriesBurned;
    private LocalDateTime startTime; // ISO 8601 format
    private Map<String,Object> additionalMetrics;


}
