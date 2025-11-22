package org.choubi.userservice.service;

import org.choubi.userservice.dto.UserCreationRequest;
import org.choubi.userservice.dto.UserResponse;
import org.choubi.userservice.model.User;
import org.choubi.userservice.model.UserRole;
import org.choubi.userservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public UserResponse getUserById(String id) {
        User user = userRepository.findById(id).orElse(null);
        return user != null ? new UserResponse(user) : null;
    }

    public boolean existsByKeycloakId(String keycloakId) {
        if (keycloakId == null) return false;
        User user = userRepository.findByKeycloakId((keycloakId)).orElse(null);
        if (user == null) return false;
        return userRepository.existsByKeycloakId(user.getKeycloakId());
    }

    public UserResponse registerUser(UserCreationRequest userCreationRequest) {

        if(userRepository.existsByEmail(userCreationRequest.getEmail())) {
            User existing = userRepository.findByEmail(userCreationRequest.getEmail());
            if (userCreationRequest.getKeycloakId() != null && (existing.getKeycloakId() == null || existing.getKeycloakId().isBlank())) {
                existing.setKeycloakId(userCreationRequest.getKeycloakId());
                existing = userRepository.save(existing);
            }
            return new UserResponse(existing);
        }

        User user = new User();
        user.setEmail(userCreationRequest.getEmail());
        user.setPassword(userCreationRequest.getPassword());
        user.setFirstName(userCreationRequest.getFirstName());
        user.setLastName(userCreationRequest.getLastName());
        user.setKeycloakId(userCreationRequest.getKeycloakId());
        user.setRole(UserRole.USER);
        User savedUser = userRepository.save(user);
        return new UserResponse(savedUser);

    }




}
