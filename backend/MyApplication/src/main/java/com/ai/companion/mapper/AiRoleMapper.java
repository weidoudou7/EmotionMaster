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
         * 根据角色类型查询AI角色列表
         * 
         * @param roleType 角色类型
         * @return AI角色列表
         */
        List<AiRole> selectByRoleType(@Param("roleType") String roleType);

        /**
         * 根据作者查询AI角色列表
         * 
         * @param roleAuthor 角色作者
         * @return AI角色列表
         */
        List<AiRole> selectByRoleAuthor(@Param("roleAuthor") String roleAuthor);

        /**
         * 获取热门角色（按浏览量排序）
         * 
         * @param limit 限制数量
         * @return AI角色列表
         */
        List<AiRole> selectHotRoles(@Param("limit") Integer limit);

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

        /**
         * 增加角色浏览量
         * 
         * @param id 角色ID
         * @return 影响的行数
         */
        int incrementViewCount(@Param("id") Integer id);

        /**
         * 更新角色浏览量
         * 
         * @param id        角色ID
         * @param viewCount 浏览量
         * @return 影响的行数
         */
        int updateViewCount(@Param("id") Integer id, @Param("viewCount") Integer viewCount);

        /**
         * 分页查询AI角色
         * 
         * 注意事项：
         * 1. offset参数必须 >= 0，否则MySQL会报SQL语法错误
         * 2. limit建议为正整数，避免全表扫描
         * 3. 仅适用于MySQL数据库
         * 
         * @param offset 偏移量（必须 >= 0）
         * @param limit  限制数量（建议 > 0）
         * @return AI角色列表
         */
        List<AiRole> selectByPage(@Param("offset") Integer offset, @Param("limit") Integer limit);

        /**
         * 根据角色名称模糊查询
         * 
         * @param roleName 角色名称（支持模糊匹配）
         * @return AI角色列表
         */
        List<AiRole> selectByRoleNameLike(@Param("roleName") String roleName);

        /**
         * 根据角色描述模糊查询
         * 
         * @param roleDescription 角色描述（支持模糊匹配）
         * @return AI角色列表
         */
        List<AiRole> selectByRoleDescriptionLike(@Param("roleDescription") String roleDescription);

        /**
         * 复合条件查询AI角色
         * 
         * @param roleType     角色类型（可选）
         * @param roleAuthor   角色作者（可选）
         * @param isTemplate   是否为模板（可选）
         * @param minViewCount 最小浏览量（可选）
         * @return AI角色列表
         */
        List<AiRole> selectByConditions(@Param("roleType") String roleType,
                        @Param("roleAuthor") String roleAuthor,
                        @Param("isTemplate") Boolean isTemplate,
                        @Param("minViewCount") Integer minViewCount);

        /**
         * 获取最新创建的AI角色
         * 
         * @param limit 限制数量
         * @return AI角色列表
         */
        List<AiRole> selectLatestRoles(@Param("limit") Integer limit);

        /**
         * 获取用户创建的模板角色
         * 
         * @param userId 用户ID
         * @return AI角色列表
         */
        List<AiRole> selectTemplateRolesByUserId(@Param("userId") Integer userId);

        /**
         * 获取系统预设角色
         * 
         * @return AI角色列表
         */
        List<AiRole> selectSystemRoles();

        /**
         * 获取社区分享角色
         * 
         * @param limit 限制数量
         * @return AI角色列表
         */
        List<AiRole> selectCommunityRoles(@Param("limit") Integer limit);

        /**
         * 根据创建时间范围查询
         * 
         * @param startTime 开始时间
         * @param endTime   结束时间
         * @return AI角色列表
         */
        List<AiRole> selectByCreateTimeRange(@Param("startTime") String startTime,
                        @Param("endTime") String endTime);

        /**
         * 统计用户创建的角色数量
         * 
         * @param userId 用户ID
         * @return 角色数量
         */
        int countByUserId(@Param("userId") Integer userId);

        /**
         * 统计各类型角色数量
         * 
         * @param roleType 角色类型
         * @return 角色数量
         */
        int countByRoleType(@Param("roleType") String roleType);

        /**
         * 统计总角色数量
         * 
         * @return 总角色数量
         */
        int countAll();

        /**
         * 获取平均浏览量
         * 
         * @return 平均浏览量
         */
        Double getAverageViewCount();

        /**
         * 批量删除角色
         * 
         * @param ids 角色ID列表
         * @return 影响的行数
         */
        int batchDeleteRoles(@Param("ids") List<Integer> ids);

        /**
         * 批量更新角色类型
         * 
         * @param ids      角色ID列表
         * @param roleType 新的角色类型
         * @return 影响的行数
         */
        int batchUpdateRoleType(@Param("ids") List<Integer> ids, @Param("roleType") String roleType);

        /**
         * 检查角色名称是否存在
         * 
         * @param roleName  角色名称
         * @param excludeId 排除的角色ID（用于更新时检查）
         * @return 是否存在
         */
        boolean existsByRoleName(@Param("roleName") String roleName, @Param("excludeId") Integer excludeId);

        /**
         * 根据多个ID查询角色
         * 
         * @param ids 角色ID列表
         * @return AI角色列表
         */
        List<AiRole> selectByIds(@Param("ids") List<Integer> ids);

        /**
         * 获取用户最受欢迎的角色（按浏览量排序）
         * 
         * @param userId 用户ID
         * @param limit  限制数量
         * @return AI角色列表
         */
        List<AiRole> selectPopularRolesByUserId(@Param("userId") Integer userId, @Param("limit") Integer limit);

        /**
         * 搜索角色（支持名称和描述的模糊搜索）
         * 
         * @param keyword 搜索关键词
         * @param limit   限制数量
         * @return AI角色列表
         */
        List<AiRole> searchRoles(@Param("keyword") String keyword, @Param("limit") Integer limit);

        /**
         * 统计模板角色数量
         * 
         * @param isTemplate 是否为模板
         * @return 模板角色数量
         */
        int countByIsTemplate(@Param("isTemplate") Boolean isTemplate);

        /**
         * 统计所有角色浏览量总和
         * 
         * @return 浏览量总和
         */
        Integer sumViewCount();

        /**
         * 统计本周新增角色数量
         * 
         * @return 本周新增角色数量
         */
        int countNewRolesThisWeek();
}