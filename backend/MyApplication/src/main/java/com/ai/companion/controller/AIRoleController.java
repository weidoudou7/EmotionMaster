package com.ai.companion.controller;

import com.ai.companion.entity.AiRole;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.entity.vo.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/ai/role")
public class AIRoleController {

    private final AiRoleMapper aiRoleMapper;

    @Autowired
    public AIRoleController(AiRoleMapper aiRoleMapper){this.aiRoleMapper = aiRoleMapper;}





    @RequestMapping("/featured4types")
    public ApiResponse<Map<String, List<AiRole>>> getfeatured4types(){
        String[] types = {"动漫","可爱","科幻","写实"};
        Map<String, List<AiRole>> featured4typesRoles = new HashMap<>();
        for(String type : types){
            List<AiRole> roles = aiRoleMapper.selectByRoleType(type);
            if (roles.size() > 9) {
                roles = roles.subList(0, 9);
            }
            featured4typesRoles.put(type, roles);
        }
        return new ApiResponse<>(true, "ok", featured4typesRoles, System.currentTimeMillis());
    }

}
