package org.choubi.userservice.repository;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import org.choubi.userservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User,String> {
    boolean existsByEmail(String email);

    boolean existsByKeycloakId(String keycloakId);

    User findByEmail(@NotBlank(message = "Email cannot be blank") @Email(message = "Invalid email format") String email);

    Optional<User> findByKeycloakId(String keycloakId);
}
