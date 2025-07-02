package com.ai.companion;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@MapperScan("com.ai.companion.mapper")
@ComponentScan(basePackages = "com.ai.companion", 
               includeFilters = @ComponentScan.Filter(
                   type = org.springframework.context.annotation.FilterType.REGEX,
                   pattern = "com\\.ai\\.companion\\.(UserController|ChatHistoryController|UserService|UserServiceImpl|UserMapper|config\\..*|utils\\..*)"
               ))
public class MyApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

}
