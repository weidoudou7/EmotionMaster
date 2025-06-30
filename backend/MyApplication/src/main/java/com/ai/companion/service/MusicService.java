package com.ai.companion.service;

public interface MusicService {
    /**
     * 获取网易云音乐播放链接
     * @param musicId 歌曲ID
     * @return 音频播放URL
     */
    String getMusicPlayUrl(String musicId);
} 