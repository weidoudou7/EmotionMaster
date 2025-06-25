package com.ai.companion.mapper;

import com.ai.companion.entity.Planet;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PlanetMapper {
    /**
     * 根据ID查询星球
     * 
     * @param id 星球ID
     * @return 星球实体
     */
    Planet selectById(@Param("id") Integer id);

    /**
     * 根据用户ID查询星球
     * 
     * @param userId 用户ID
     * @return 星球实体
     */
    Planet selectByUserId(@Param("userId") Integer userId);

    /**
     * 插入新星球
     * 
     * @param planet 星球实体
     * @return 影响的行数
     */
    int insertPlanet(Planet planet);

    /**
     * 更新星球信息
     * 
     * @param planet 星球实体
     * @return 影响的行数
     */
    int updatePlanet(Planet planet);

    /**
     * 根据ID删除星球
     * 
     * @param id 星球ID
     * @return 影响的行数
     */
    int deletePlanet(@Param("id") Integer id);

    /**
     * 查询所有星球
     * 
     * @return 星球列表
     */
    List<Planet> selectAll();
}