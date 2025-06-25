package com.ai.companion.mapper;

import com.ai.companion.entity.AiRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AiRoleMapper {
    /**
     * 根据ID查询AI角色
     * 
     * @param id 角色ID
     * @return AI角色实体
     */
    AiRole selectById(@Param("id") Integer id);

    /**
     * 根据用户ID查询AI角色列表
     * 
     * @param userId 用户ID
     * @return AI角色列表
     */
    List<AiRole> selectByUserId(@Param("userId") Integer userId);

    /**
     * 插入新AI角色
     * 
     * @param aiRole AI角色实体
     * @return 影响的行数
     */
    int insertAiRole(AiRole aiRole);

    /**
     * 更新AI角色信息
     * 
     * @param aiRole AI角色实体
     * @return 影响的行数
     */
    int updateAiRole(AiRole aiRole);

    /**
     * 根据ID删除AI角色
     * 
     * @param id 角色ID
     * @return 影响的行数
     */
    int deleteAiRole(@Param("id") Integer id);

    /**
     * 查询所有AI角色
     * 
     * @return AI角色列表
     */
    List<AiRole> selectAll();
}