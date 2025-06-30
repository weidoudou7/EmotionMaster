package com.ai.companion.controller;

import com.ai.companion.entity.Dynamic;
import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.service.DynamicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dynamic")
@CrossOrigin(origins = "*")
public class DynamicController {

    @Autowired
    private DynamicService dynamicService;

    /**
     * 创建新动态
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
    public ApiResponse<List<Dynamic>> getUserDynamics(@PathVariable String userUID) {
        try {
            List<Dynamic> dynamics = dynamicService.getUserDynamics(userUID);
            return ApiResponse.success("获取用户动态成功", dynamics);
        } catch (Exception e) {
            return ApiResponse.error("获取用户动态失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户公开的动态
     */
    @GetMapping("/user/{userUID}/public")
    public ApiResponse<List<Dynamic>> getUserPublicDynamics(@PathVariable String userUID) {
        try {
            List<Dynamic> dynamics = dynamicService.getUserPublicDynamics(userUID);
            return ApiResponse.success("获取用户公开动态成功", dynamics);
        } catch (Exception e) {
            return ApiResponse.error("获取用户公开动态失败: " + e.getMessage());
        }
    }

    /**
     * 获取所有公开的动态
     */
    @GetMapping("/public")
    public ApiResponse<List<Dynamic>> getAllPublicDynamics() {
        try {
            List<Dynamic> dynamics = dynamicService.getAllPublicDynamics();
            return ApiResponse.success("获取公开动态成功", dynamics);
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
}