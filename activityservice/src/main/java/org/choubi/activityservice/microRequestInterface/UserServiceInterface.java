package org.choubi.activityservice.microRequestInterface;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "user-service") // matches spring.application.name

public interface UserServiceInterface {
//    @GetMapping("/api/users/{id}")
//    public ResponseEntity<UserResponse> getUser(@PathVariable String id);
//
//    @PostMapping("/api/users/register")
//    public ResponseEntity<UserResponse> registerUser(
//            @Valid @RequestBody UserCreationRequest userCreationRequest) ;
    @GetMapping("/users/validate/{id}")
    public Boolean validate(@PathVariable String id) ;

}
