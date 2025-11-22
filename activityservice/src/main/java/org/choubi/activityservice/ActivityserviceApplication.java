package org.choubi.activityservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class ActivityserviceApplication {

    public static void main(String[] args) {
        SpringApplication.run(ActivityserviceApplication.class, args);
    }

}
