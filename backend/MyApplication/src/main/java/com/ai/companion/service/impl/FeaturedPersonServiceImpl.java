package com.ai.companion.service.impl;

import com.ai.companion.entity.AiRole;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.service.FeaturedPersonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class FeaturedPersonServiceImpl implements FeaturedPersonService {

    private final AiRoleMapper aiRoleMapper;

    @Autowired
    public FeaturedPersonServiceImpl(AiRoleMapper aiRoleMapper) {
        this.aiRoleMapper = aiRoleMapper;
    }

    @Override
    public List<AiRole> getAllFeaturedPersons() {
        // 直接返回查询到的所有AiRole实体
        return aiRoleMapper.selectAll();
    }

    @Override
    public Optional<AiRole> getRoleById(Long id) {
        // 注意类型转换：Long转Integer（因为实体类id是Integer类型）
        AiRole role = aiRoleMapper.selectById(id.intValue());
        return Optional.ofNullable(role);
    }

    @Override
    public AiRole createRole(AiRole role) {
        // 设置默认创建时间（如果前端未传递）
        if (role.getCreatedAt() == null) {
            role.setCreatedAt(LocalDateTime.now());
        }
        // 插入数据库
        aiRoleMapper.insertAiRole(role);
        // 返回包含自增ID的实体
        return role;
    }

    @Override
    public Optional<AiRole> updateRole(Long id, AiRole role) {
        // 先查询原实体是否存在
        AiRole existingRole = aiRoleMapper.selectById(id.intValue());
        if (existingRole == null) {
            return Optional.empty();
        }
        // 确保更新的是指定ID的实体（防止前端传递错误ID）
        role.setId(id.intValue());
        // 保留原创建时间（避免被覆盖）
        role.setCreatedAt(existingRole.getCreatedAt());
        // 执行更新
        aiRoleMapper.updateAiRole(role);
        // 返回更新后的实体
        return Optional.of(aiRoleMapper.selectById(id.intValue()));
    }

    @Override
    public boolean deleteRole(Long id) {
        // 执行删除并返回结果
        int result = aiRoleMapper.deleteAiRole(id.intValue());
        return result > 0;
    }

    @Override
    public List<AiRole> getRolesByType(String type) {
        // 按角色类型查询并返回结果
        List<AiRole> roles = aiRoleMapper.selectByRoleType(type);
        // 限制最多返回20条数据，确保有足够的角色展示
        if (roles.size() > 20) {
            return roles.subList(0, 20);
        }
        return roles;
    }
}