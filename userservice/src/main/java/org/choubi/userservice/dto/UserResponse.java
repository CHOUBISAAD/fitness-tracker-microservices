package org.choubi.userservice.dto;

import lombok.Data;
import org.choubi.userservice.model.User;

import java.time.LocalDateTime;
import java.util.Date;

@Data
public class UserResponse {
    private String id;
    private String email;
    private String firstName;
    private String lastName;
    private String role;
    private LocalDateTime createdDate;
    private LocalDateTime updatedDate;
    private String keycloakId;


    public UserResponse(User user) {
        this.id = user.getId();
        this.email = user.getEmail();
        this.firstName = user.getFirstName();
        this.lastName = user.getLastName();
        this.role = user.getRole().name();
        this.createdDate = user.getCreatedAt();
        this.updatedDate = user.getUpdatedAt();
        this.keycloakId = user.getKeycloakId();
    }
}
