package com.ai.companion.controller;

import com.ai.companion.entity.Dynamic;
import com.ai.companion.entity.User;
import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.entity.vo.CreateDynamicRequest;
import com.ai.companion.entity.vo.DynamicVO;
import com.ai.companion.entity.vo.UserInfoVO;
import com.ai.companion.service.DynamicService;
import com.ai.companion.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/dynamic")
@CrossOrigin(origins = "http://localhost:8080", allowCredentials = "true")
public class DynamicController {

    @Autowired
    private DynamicService dynamicService;
    
    @Autowired
    private UserService userService;

    /**
     * 创建新动态（使用CreateDynamicRequest）
     */
    @PostMapping("/create/{userUID}")
    public ApiResponse<DynamicVO> createDynamic(@PathVariable String userUID,
            @RequestBody CreateDynamicRequest request) {
        try {
            // 设置默认值
            String visibility = request.getVisibility() != null ? request.getVisibility() : "public";
            List<String> images = request.getImages() != null ? request.getImages() : List.of();
            List<String> topicTags = request.getTopicTags() != null ? request.getTopicTags() : List.of();
            
            // 如果isPrivate为true，设置可见性为private
            if (request.getIsPrivate() != null && request.getIsPrivate()) {
                visibility = "private";
            }
            
            Dynamic dynamic = dynamicService.createDynamic(userUID, request.getContent(), images, topicTags, visibility);
            
            // 获取用户信息
            UserInfoVO userInfoVO = userService.getUserInfo(userUID);
            
            // 转换为 DynamicVO
            DynamicVO dynamicVO = DynamicVO.fromDynamic(dynamic, userInfoVO);
            
            return ApiResponse.success("动态创建成功", dynamicVO);
        } catch (Exception e) {
            return ApiResponse.error("创建动态失败: " + e.getMessage());
        }
    }

    /**
     * 创建新动态（兼容旧接口）
     */
    @PostMapping("/create")
    public ApiResponse<Dynamic> createDynamic(@RequestParam String userUID,
            @RequestParam String content,
            @RequestParam(required = false) List<String> images,
            @RequestParam(required = false) List<String> topicTags,
            @RequestParam(defaultValue = "public") String visibility) {
        try {
            Dynamic dynamic = dynamicService.createDynamic(userUID, content, images, topicTags, visibility);
            return ApiResponse.success("动态创建成功", dynamic);
        } catch (Exception e) {
            return ApiResponse.error("创建动态失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户的所有动态
     */
    @GetMapping("/user/{userUID}")
    public ApiResponse<List<DynamicVO>> getUserDynamics(@PathVariable String userUID) {
        try {
            List<Dynamic> dynamics = dynamicService.getUserDynamics(userUID);
            
            // 获取用户信息
            UserInfoVO userInfoVO = userService.getUserInfo(userUID);
            
            // 转换为 DynamicVO 列表
            List<DynamicVO> dynamicVOs = dynamics.stream()
                .map(dynamic -> DynamicVO.fromDynamic(dynamic, userInfoVO))
                .toList();
            
            return ApiResponse.success("获取用户动态成功", dynamicVOs);
        } catch (Exception e) {
            return ApiResponse.error("获取用户动态失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户公开的动态
     */
    @GetMapping("/user/{userUID}/public")
    public ApiResponse<List<DynamicVO>> getUserPublicDynamics(@PathVariable String userUID) {
        try {
            List<Dynamic> dynamics = dynamicService.getUserPublicDynamics(userUID);
            
            // 获取用户信息
            UserInfoVO userInfoVO = userService.getUserInfo(userUID);
            
            // 转换为 DynamicVO 列表
            List<DynamicVO> dynamicVOs = dynamics.stream()
                .map(dynamic -> DynamicVO.fromDynamic(dynamic, userInfoVO))
                .toList();
            
            return ApiResponse.success("获取用户公开动态成功", dynamicVOs);
        } catch (Exception e) {
            return ApiResponse.error("获取用户公开动态失败: " + e.getMessage());
        }
    }

    /**
     * 获取所有公开的动态（分页）
     */
    @GetMapping("/public")
    public ApiResponse<List<DynamicVO>> getAllPublicDynamics(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            List<Dynamic> dynamics = dynamicService.getAllPublicDynamics(page, size);
            
            // 获取所有动态的用户信息并转换为 DynamicVO
            List<DynamicVO> dynamicVOs = dynamics.stream()
                .map(dynamic -> {
                    try {
                        UserInfoVO userInfoVO = userService.getUserInfoById(dynamic.getUserId());
                        return DynamicVO.fromDynamic(dynamic, userInfoVO);
                    } catch (Exception e) {
                        // 如果获取用户信息失败，使用不包含用户信息的版本
                        return DynamicVO.fromDynamic(dynamic);
                    }
                })
                .toList();
            
            return ApiResponse.success("获取公开动态成功", dynamicVOs);
        } catch (Exception e) {
            return ApiResponse.error("获取公开动态失败: " + e.getMessage());
        }
    }

    /**
     * 根据可见性获取动态
     */
    @GetMapping("/visibility/{visibility}")
    public ApiResponse<List<Dynamic>> getDynamicsByVisibility(@PathVariable String visibility) {
        try {
            List<Dynamic> dynamics = dynamicService.getDynamicsByVisibility(visibility);
            return ApiResponse.success("获取动态成功", dynamics);
        } catch (Exception e) {
            return ApiResponse.error("获取动态失败: " + e.getMessage());
        }
    }

    /**
     * 获取热门动态
     */
    @GetMapping("/hot")
    public ApiResponse<List<Dynamic>> getHotDynamics(@RequestParam(defaultValue = "10") Integer limit) {
        try {
            List<Dynamic> dynamics = dynamicService.getHotDynamics(limit);
            return ApiResponse.success("获取热门动态成功", dynamics);
        } catch (Exception e) {
            return ApiResponse.error("获取热门动态失败: " + e.getMessage());
        }
    }

    /**
     * 根据话题标签获取动态
     */
    @GetMapping("/topic/{topicTag}")
    public ApiResponse<List<Dynamic>> getDynamicsByTopicTag(@PathVariable String topicTag) {
        try {
            List<Dynamic> dynamics = dynamicService.getDynamicsByTopicTag(topicTag);
            return ApiResponse.success("获取话题动态成功", dynamics);
        } catch (Exception e) {
            return ApiResponse.error("获取话题动态失败: " + e.getMessage());
        }
    }

    /**
     * 根据ID获取动态
     */
    @GetMapping("/{id}")
    public ApiResponse<Dynamic> getDynamicById(@PathVariable Integer id) {
        try {
            Dynamic dynamic = dynamicService.getDynamicById(id);
            if (dynamic == null) {
                return ApiResponse.error("动态不存在");
            }
            return ApiResponse.success("获取动态成功", dynamic);
        } catch (Exception e) {
            return ApiResponse.error("获取动态失败: " + e.getMessage());
        }
    }

    /**
     * 更新动态
     */
    @PutMapping("/{id}")
    public ApiResponse<Boolean> updateDynamic(@PathVariable Integer id,
            @RequestParam String userUID,
            @RequestParam String content,
            @RequestParam(required = false) List<String> images,
            @RequestParam(required = false) List<String> topicTags,
            @RequestParam(defaultValue = "public") String visibility) {
        try {
            boolean success = dynamicService.updateDynamic(id, userUID, content, images, topicTags, visibility);
            if (success) {
                return ApiResponse.success("动态更新成功", true);
            } else {
                return ApiResponse.error("动态更新失败，可能是权限不足或动态不存在");
            }
        } catch (Exception e) {
            return ApiResponse.error("更新动态失败: " + e.getMessage());
        }
    }

    /**
     * 删除动态
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Boolean> deleteDynamic(@PathVariable Integer id, @RequestParam String userUID) {
        try {
            boolean success = dynamicService.deleteDynamic(id, userUID);
            if (success) {
                return ApiResponse.success("动态删除成功", true);
            } else {
                return ApiResponse.error("动态删除失败，可能是权限不足或动态不存在");
            }
        } catch (Exception e) {
            return ApiResponse.error("删除动态失败: " + e.getMessage());
        }
    }

    /**
     * 点赞动态
     */
    @PostMapping("/{id}/like")
    public ApiResponse<Boolean> likeDynamic(@PathVariable Integer id) {
        try {
            boolean success = dynamicService.likeDynamic(id);
            if (success) {
                return ApiResponse.success("点赞成功", true);
            } else {
                return ApiResponse.error("点赞失败，动态可能不存在");
            }
        } catch (Exception e) {
            return ApiResponse.error("点赞失败: " + e.getMessage());
        }
    }

    /**
     * 取消点赞动态
     */
    @PostMapping("/{id}/unlike")
    public ApiResponse<Boolean> unlikeDynamic(@PathVariable Integer id) {
        try {
            boolean success = dynamicService.unlikeDynamic(id);
            if (success) {
                return ApiResponse.success("取消点赞成功", true);
            } else {
                return ApiResponse.error("取消点赞失败，动态可能不存在或点赞数已为0");
            }
        } catch (Exception e) {
            return ApiResponse.error("取消点赞失败: " + e.getMessage());
        }
    }

    /**
     * 健康检查接口
     * @return 服务状态
     */
    @GetMapping("/health")
    public ApiResponse<String> health() {
        return ApiResponse.success("动态服务运行正常", "OK");
    }
}