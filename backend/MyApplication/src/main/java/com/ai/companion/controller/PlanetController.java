package com.ai.companion.controller;

import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.entity.vo.PlanetVO;
import com.ai.companion.service.PlanetService;
import com.ai.companion.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/planet")
@CrossOrigin(origins = "*")
public class PlanetController {
    @Autowired
    private PlanetService planetService;
    @Autowired
    private UserMapper userMapper;

    /**
     * 获取用户的星球信息
     */
    @GetMapping("/{userId}")
    public ApiResponse<PlanetVO> getPlanet(@PathVariable Integer userId) {
        PlanetVO vo = planetService.getPlanetVOByUserId(userId);
        if (vo == null) {
            return ApiResponse.error("未找到该用户的星球信息");
        }
        return ApiResponse.success("获取星球信息成功", vo);
    }

    /**
     * 通过userUID获取用户的星球信息
     */
    @GetMapping("/uid/{userUID}")
    public ApiResponse<PlanetVO> getPlanetByUserUID(@PathVariable String userUID) {
        // 这里假设有UserMapper可用
        // 1. 通过userUID查userId
        // 2. 再查星球
        Integer userId = null;
        try {
            com.ai.companion.entity.User user = userMapper.selectByUID(userUID);
            if (user == null) {
                return ApiResponse.error("未找到该用户");
            }
            userId = user.getId();
        } catch (Exception e) {
            return ApiResponse.error("查询用户失败: " + e.getMessage());
        }
        PlanetVO vo = planetService.getPlanetVOByUserId(userId);
        if (vo == null) {
            return ApiResponse.error("未找到该用户的星球信息");
        }
        return ApiResponse.success("获取星球信息成功", vo);
    }
} 