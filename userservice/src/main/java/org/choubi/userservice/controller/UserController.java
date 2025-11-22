package org.choubi.userservice.controller;

import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.choubi.userservice.dto.UserCreationRequest;
import org.choubi.userservice.dto.UserResponse;
import org.choubi.userservice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable String id) {
        UserResponse userResponse = userService.getUserById(id);
        if(userResponse == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(userResponse);
    }

    @PostMapping("/register")
    public ResponseEntity<UserResponse> registerUser(
            @Valid @RequestBody UserCreationRequest userCreationRequest) {
        UserResponse userResponse = userService.registerUser(userCreationRequest);
        if(userResponse == null) {
            log.error("User creation failed");
            return ResponseEntity.internalServerError().build();
        }
        return ResponseEntity.ok(userResponse);
    }

    @GetMapping("/validate/{id}")
    public Boolean validate(@PathVariable String id) {
        System.out.println("Validating user with id: " + id);
        Boolean exists = userService.existsByKeycloakId(id);
        System.out.println("User exists: " + exists);
        return exists;
    }

}
