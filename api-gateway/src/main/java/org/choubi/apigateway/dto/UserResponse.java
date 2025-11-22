package org.choubi.apigateway.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
public class UserResponse {
    private String id;
    private String email;
    private String firstName;
    private String lastName;
    private String role;
    private LocalDateTime createdDate;
    private LocalDateTime updatedDate;
    private String keycloakId;
}
