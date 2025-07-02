package com.ai.companion.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FeaturedPerson {
    private Long id;
    private String image;
    private String name;
    private String desc;
    private String authorName;
    private String authorAvatar;
    private String views;


}