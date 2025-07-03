package com.ai.companion.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FeaturedPersonDto {
    private Long id;
    private String image;
    private String name;
    private String desc;
    private String authorName;
    private String authorAvatar;
    private String views;
}