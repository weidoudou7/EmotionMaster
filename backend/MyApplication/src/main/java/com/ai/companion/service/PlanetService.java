package com.ai.companion.service;

import com.ai.companion.entity.vo.PlanetVO;

public interface PlanetService {
    /**
     * 获取用户的星球信息（聚合VO）
     */
    PlanetVO getPlanetVOByUserId(Integer userId);
} 