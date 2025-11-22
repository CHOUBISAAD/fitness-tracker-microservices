package org.choubi.apigateway.usermodel;


import lombok.Data;

import java.time.LocalDateTime;

@Data
public class User {

    private String id;
    private String keycloakId;
    private String email;
    private String password;
    private String firstName;
    private String lastName;
    private UserRole role;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
