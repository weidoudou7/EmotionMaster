package com.ai.companion.service.impl;

import com.ai.companion.entity.Planet;
import com.ai.companion.entity.vo.PlanetVO;
import com.ai.companion.mapper.PlanetMapper;
import com.ai.companion.service.PlanetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PlanetServiceImpl implements PlanetService {
    @Autowired
    private PlanetMapper planetMapper;

    @Override
    public PlanetVO getPlanetVOByUserId(Integer userId) {
        Planet planet = planetMapper.selectByUserId(userId);
        if (planet == null) {
            return null;
        }
        // TODO: 这里应聚合成长进度、生态、科技、文化等数据，暂用默认值
        PlanetVO vo = new PlanetVO();
        vo.setId(planet.getId());
        vo.setUserId(planet.getUserId());
        vo.setName(planet.getName());
        vo.setDescription("一个充满活力和希望的星球");
        vo.setLevel(planet.getLevel());
        vo.setImage("/resources/base/media/QQ1222.jpg");
        vo.setEcoPercent(78);
        vo.setTechPercent(65);
        vo.setCulturePercent(82);
        vo.setTalkHours(12.5);
        vo.setTalkTarget(20.0);
        vo.setTaskCount(28);
        vo.setTaskTarget(50);
        vo.setExplorePercent(42);
        vo.setUnlockedRewards(new String[]{"星球皮肤", "特殊装饰"});
        vo.setLockedRewards(new String[]{"火箭飞船"});
        vo.setAppearance(planet.getAppearance());
        vo.setUnlockedItems(planet.getUnlockedItems());
        return vo;
    }
} 