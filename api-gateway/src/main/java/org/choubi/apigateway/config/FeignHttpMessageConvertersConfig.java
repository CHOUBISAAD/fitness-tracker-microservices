//package org.choubi.apigateway.config;
//
//import com.fasterxml.jackson.databind.ObjectMapper;
//import org.springframework.boot.autoconfigure.http.HttpMessageConverters;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.http.converter.HttpMessageConverter;
//import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
//
//@Configuration
//public class FeignHttpMessageConvertersConfig {
//
//    // Provide an HttpMessageConverters bean so Feign's SpringDecoder can be created
//    // without pulling in spring-web (avoid adding servlet stack to a reactive gateway).
//    @Bean
//    public HttpMessageConverters httpMessageConverters(ObjectMapper objectMapper) {
//        MappingJackson2HttpMessageConverter jackson = new MappingJackson2HttpMessageConverter(objectMapper);
//        return new HttpMessageConverters((HttpMessageConverter<?>) jackson);
//    }
//}
//
