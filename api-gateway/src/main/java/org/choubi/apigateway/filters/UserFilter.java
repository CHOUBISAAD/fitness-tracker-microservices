package org.choubi.apigateway.filters;

import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.choubi.apigateway.dto.UserCreationRequest;
import org.choubi.apigateway.services.UserService;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

@Slf4j
@RequiredArgsConstructor
@Component
public class UserFilter implements WebFilter {

    private final UserService userService;


    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        log.info("UserFilter filtering");

        String userId = exchange.getRequest().getHeaders().getFirst("X-USER-ID");
        String token = exchange.getRequest().getHeaders().getFirst("Authorization");

        UserCreationRequest userCreationRequest = getUserdetails(token);

        if (userId == null && userCreationRequest != null)
            userId = userCreationRequest.getKeycloakId();

        // If we don't have the required info, just continue the chain
        if (token == null || userId == null) {
            return chain.filter(exchange);
        }

        String finalUserId = userId;

        Mono<Boolean> isValidUserMono = Mono.fromCallable(() -> userService.validate(finalUserId))
                .subscribeOn(Schedulers.boundedElastic())
                .defaultIfEmpty(false);

        return isValidUserMono
                .flatMap(isValidUser -> {
                    Mono<Void> registration = Mono.empty();
                    if (!isValidUser && userCreationRequest != null) {
                        log.info("Registering new user with id {}", finalUserId);
                        registration = Mono.fromCallable(() -> userService.registerUser(userCreationRequest))
                                .subscribeOn(Schedulers.boundedElastic())
                                .then();
                    } else {
                        log.info("User with id {} already exists", finalUserId);
                    }
                    return registration.then(Mono.defer(() -> {
                        ServerHttpRequest mutatedrequest = exchange.getRequest().mutate()
                                .header("X-USER-ID", finalUserId)
                                .headers(httpHeaders -> {
                                    if (token != null) httpHeaders.set("Authorization", token);
                                })
                                .build();
                        return chain.filter(exchange.mutate().request(mutatedrequest).build());
                    }));
                });
    }

    private UserCreationRequest getUserdetails(String token){
        try {
            if (token == null) return null;
            String tokenWithoutBearer = token.replace("Bearer ", "");
            SignedJWT jwt = SignedJWT.parse(tokenWithoutBearer);
            JWTClaimsSet jwtClaimsSet = jwt.getJWTClaimsSet();
            UserCreationRequest userCreationRequest = new UserCreationRequest();
            userCreationRequest.setEmail(jwtClaimsSet.getStringClaim("email"));
            userCreationRequest.setFirstName(jwtClaimsSet.getStringClaim("given_name"));
            userCreationRequest.setLastName(jwtClaimsSet.getStringClaim("family_name"));
            userCreationRequest.setKeycloakId(jwtClaimsSet.getStringClaim("sub"));
            userCreationRequest.setPassword("changeme");
            return userCreationRequest;
        } catch (Exception e) {
            log.error("Error extracting user details from token: {}", e.getMessage());
            return null;
        }
    }
}
