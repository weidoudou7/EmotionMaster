package com.ai.companion.mapper;

import com.ai.companion.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper {
    /**
     * 根据用户UID查询用户信息
     * 
     * @param userUID 用户唯一标识符
     * @return 用户实体
     */
    User selectByUID(@Param("userUID") String userUID);

    /**
     * 插入新用户
     * 
     * @param user 用户实体
     * @return 影响的行数
     */
    int insertUser(User user);

    /**
     * 更新用户信息
     * 
     * @param user 用户实体
     * @return 影响的行数
     */
    int updateUser(User user);

    /**
     * 根据用户UID删除用户
     * 
     * @param userUID 用户唯一标识符
     * @return 影响的行数
     */
    int deleteUser(@Param("userUID") String userUID);

    /**
     * 查询所有用户
     * 
     * @return 用户列表
     */
    List<User> selectAll();
}