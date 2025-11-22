package org.choubi.activityservice.controller;

import org.choubi.activityservice.dto.ActivityRequest;
import org.choubi.activityservice.dto.ActivityResponse;
import org.choubi.activityservice.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/activities")
public class ActivityController {

    @Autowired
    private ActivityService activityService;

    @PostMapping
    public ResponseEntity<ActivityResponse> trackActivity(@RequestBody ActivityRequest activityRequest,@RequestHeader ("X-USER-ID") String userId) {
        System.out.println("Received activity tracking request: " + activityRequest);
        if (userId != null)
            activityRequest.setUserId(userId);

        return ResponseEntity.ok(activityService.trackActivity(activityRequest));
    }

    @GetMapping
    public ResponseEntity<List<ActivityResponse>> getUserActivities(@RequestHeader("X-USER-ID") String userId) {
        List<ActivityResponse> activityResponse = activityService.getUserActivities(userId);
        if(activityResponse==null){
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(activityResponse);
    }

    @GetMapping("/{activityId}")
    public ResponseEntity<ActivityResponse> getActivityById(@PathVariable String activityId) {
        return ResponseEntity.ok(activityService.getActivityById(activityId));
    }
}
