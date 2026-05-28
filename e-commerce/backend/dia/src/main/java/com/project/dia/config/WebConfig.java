package com.project.dia.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements  WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/upload/**") // 브라우저에서 접근할 URL
                .addResourceLocations("file:///C:/Users/a001/Desktop/kh_project/kh_project(final)/dia-project/e-commerce/backend/upload/");
        // 실제 파일이 있는 공유 폴더 경로
    }

}
