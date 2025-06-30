package com.ai.companion.controller;

import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.service.MusicService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/music")
@RequiredArgsConstructor
public class MusicController {
    private final MusicService musicService;

    @GetMapping("/{musicId}/play-url")
    public ApiResponse<String> getPlayUrl(@PathVariable String musicId) {
        String url = musicService.getMusicPlayUrl(musicId);
        return ApiResponse.success("获取播放链接成功", url);
    }

    @GetMapping("/{musicId}/detail")
    public ApiResponse<com.ai.companion.entity.vo.MusicDetailVO> getMusicDetail(@PathVariable String musicId) {
        com.ai.companion.entity.vo.MusicDetailVO detail = musicService.getMusicDetail(musicId);
        return ApiResponse.success("获取歌曲详情成功", detail);
    }
} 