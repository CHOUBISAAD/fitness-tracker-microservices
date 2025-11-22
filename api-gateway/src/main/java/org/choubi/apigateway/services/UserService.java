package org.choubi.apigateway.services;

import jakarta.validation.Valid;
import org.choubi.apigateway.config.FeignConfig;
import org.choubi.apigateway.dto.UserCreationRequest;
import org.choubi.apigateway.dto.UserResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "user-service", url = "${user.service.url:}", path = "/users", configuration = FeignConfig.class)
public interface UserService {
    @PostMapping("/register")
    UserResponse registerUser(@Valid @RequestBody UserCreationRequest userCreationRequest);

    @GetMapping("/validate/{id}")
    Boolean validate(@PathVariable String id);
}
