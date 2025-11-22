package org.choubi.activityservice.dto;

import lombok.Data;
import org.choubi.activityservice.model.Activity;
import org.choubi.activityservice.model.ActivityType;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;
import java.util.Map;

@Data
public class ActivityResponse {
    private String id;
    private String userId;
    private ActivityType type;
    private Integer duration;
    private Integer caloriesBurned;
    private LocalDateTime startTime;
    private Map<String,Object> additionalMetrics;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public ActivityResponse(Activity activity) {
        if (activity != null) {
            this.id = activity.getId();
            this.userId = activity.getUserId();
            this.type = activity.getType();
            this.duration = activity.getDuration();
            this.caloriesBurned = activity.getCaloriesBurned();
            this.startTime = activity.getStartTime();
            this.additionalMetrics = activity.getAdditionalMetrics();
            this.createdAt = activity.getCreatedAt();
            this.updatedAt = activity.getUpdatedAt();
        }
    }
}
