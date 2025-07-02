package com.ai.companion.service;

import com.ai.companion.dto.FeaturedPersonDto;
import com.ai.companion.entity.AiRole;

import java.util.List;
import java.util.Optional;

/**
 * 特色人物业务服务接口
 * 定义了对特色人物数据进行管理的核心业务方法，包括查询、创建、更新和删除操作
 * 接口方法返回DTO对象，用于与前端进行数据传输
 */
public interface FeaturedPersonService {

    /**
     * 获取所有特色人物列表
     * @return 包含所有特色人物信息的DTO列表
     */
    List<AiRole> getAllFeaturedPersons();

    /**
     * 根据ID获取单个特色人物信息
     * @param id 特色人物唯一标识
     * @return 包含特色人物信息的DTO对象（如果存在）
     */
    Optional<FeaturedPersonDto> getFeaturedPersonById(Long id);

    /**
     * 创建新的特色人物
     * @param dto 包含特色人物信息的DTO对象
     * @return 创建成功后的特色人物DTO对象，包含生成的ID
     */
    FeaturedPersonDto createFeaturedPerson(FeaturedPersonDto dto);

    /**
     * 更新现有特色人物信息
     * @param id 要更新的特色人物ID
     * @param dto 包含更新信息的DTO对象
     * @return 更新后的特色人物DTO对象（如果存在）
     */
    Optional<FeaturedPersonDto> updateFeaturedPerson(Long id, FeaturedPersonDto dto);

    /**
     * 根据ID删除特色人物
     * @param id 要删除的特色人物ID
     * @return 删除操作结果（true表示成功，false表示未找到对应ID）
     */
    boolean deleteFeaturedPerson(Long id);

    // 新增按类型查询的方法
    List<FeaturedPersonDto> getFeaturedPersonsByType(String type);
}