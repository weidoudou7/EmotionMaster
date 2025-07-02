package com.ai.companion.service.impl;

import com.ai.companion.dto.FeaturedPersonDto;
import com.ai.companion.entity.AiRole;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.service.FeaturedPersonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FeaturedPersonServiceImpl implements FeaturedPersonService {

    private final AiRoleMapper aiRoleMapper;

    @Autowired
    public FeaturedPersonServiceImpl(AiRoleMapper aiRoleMapper) {
        this.aiRoleMapper = aiRoleMapper;
    }

    @Override
    public List<AiRole> getAllFeaturedPersons() {
        List<AiRole> roles = aiRoleMapper.selectAll();
        return roles;
    }

    @Override
    public Optional<FeaturedPersonDto> getFeaturedPersonById(Long id) {
        AiRole role = aiRoleMapper.selectById(id.intValue());
        return Optional.ofNullable(role).map(this::convertToDto);
    }

    @Override
    public FeaturedPersonDto createFeaturedPerson(FeaturedPersonDto dto) {
        AiRole role = new AiRole();
        role.setRoleName(dto.getName());
        role.setRoleDescription(dto.getDesc());
        role.setAvatarUrl(dto.getImage());
        role.setRoleAuthor(dto.getAuthorName());
        role.setViewCount(Integer.parseInt(dto.getViews().replaceAll("[^0-9]", "")));
        //role.setCreateTime(new java.util.Date());

        aiRoleMapper.insertAiRole(role);

        // 获取插入后的ID
        if (role.getId() > 0) {
            return convertToDto(role);
        }

        throw new RuntimeException("创建特色人物失败");
    }

    @Override
    public Optional<FeaturedPersonDto> updateFeaturedPerson(Long id, FeaturedPersonDto dto) {
        AiRole role = aiRoleMapper.selectById(id.intValue());
        if (role == null) {
            return Optional.empty();
        }

        role.setRoleName(dto.getName());
        role.setRoleDescription(dto.getDesc());
        role.setAvatarUrl(dto.getImage());
        role.setRoleAuthor(dto.getAuthorName());
        role.setViewCount(Integer.parseInt(dto.getViews().replaceAll("[^0-9]", "")));

        aiRoleMapper.updateAiRole(role);
        return Optional.of(convertToDto(role));
    }

    @Override
    public boolean deleteFeaturedPerson(Long id) {
        int result = aiRoleMapper.deleteAiRole(id.intValue());
        return result > 0;
    }

    private FeaturedPersonDto convertToDto(AiRole role) {
        FeaturedPersonDto dto = new FeaturedPersonDto();
        dto.setId(Long.valueOf(role.getId()));
        dto.setImage(role.getAvatarUrl());
        dto.setName(role.getRoleName());
        dto.setDesc(role.getRoleDescription());
        dto.setAuthorName(role.getRoleAuthor());
        // 注意：这里需要从用户表获取作者头像，暂时使用默认值
        //dto.setAuthorAvatar("https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg");
        //dto.setViews(String.valueOf(role.getViewCount()));

        // 格式化浏览量（添加单位）
        int viewCount = role.getViewCount();
        if (viewCount >= 10000) {
            dto.setViews(String.format("%.1f万", viewCount / 10000.0));
        } else {
            dto.setViews(String.valueOf(viewCount));
        }

        return dto;
    }

    // 添加到 FeaturedPersonServiceImpl 类中
    public List<FeaturedPersonDto> getFeaturedPersonsByType(String type) {
        List<AiRole> roles = aiRoleMapper.selectByRoleType(type);

        // 限制数量为9个
        if (roles.size() > 9) {
            roles = roles.subList(0, 9);
        }

        return roles.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
}