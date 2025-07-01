package com.ai.companion.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FeaturedPerson {
    private Long id;
    private String image;
    private String name;
    private String description;
    private String authorName;
    private String authorAvatar;
    private String views;
}