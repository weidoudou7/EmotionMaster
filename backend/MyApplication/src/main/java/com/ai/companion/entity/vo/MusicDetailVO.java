package com.ai.companion.entity.vo;

import lombok.Data;

@Data
public class MusicDetailVO {
    private String name;        // 歌曲名称
    private String artist;      // 歌手名字
    private String duration;    // 歌曲时长（格式 mm:ss）
    private String coverUrl;    // 专辑封面
} 