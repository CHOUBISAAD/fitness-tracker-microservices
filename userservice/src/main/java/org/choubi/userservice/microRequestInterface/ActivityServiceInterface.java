package org.choubi.userservice.microRequestInterface;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name = "activity-service")
public interface ActivityServiceInterface {

//    @PostMapping("/api/activities")
//    public ResponseEntity<ActivityResponse> trackActivity(@RequestBody ActivityRequest activityRequest);
//
//    @GetMapping("/api/activities")
//    public ResponseEntity<List<ActivityResponse>> getUserActivities(@RequestHeader("X-USER-ID") String userId);
//
//    @GetMapping("/api/activities/{activityId}")
//    public ResponseEntity<ActivityResponse> getActivityById(@PathVariable String activityId);
}
