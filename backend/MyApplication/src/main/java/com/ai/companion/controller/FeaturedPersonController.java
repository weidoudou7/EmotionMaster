package com.ai.companion.controller;

import com.ai.companion.dto.FeaturedPersonDto;
import com.ai.companion.entity.AiRole;
import com.ai.companion.service.FeaturedPersonService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * RESTful API控制器，负责处理与特色人物(FeaturedPerson)相关的HTTP请求
 * 提供对特色人物资源的增删改查操作
 */
@RestController
@RequestMapping("/featured-people")
public class FeaturedPersonController {

    private final FeaturedPersonService service;

    /**
     * 通过构造函数注入FeaturedPersonService
     * @param service 特色人物业务逻辑服务
     */
    public FeaturedPersonController(FeaturedPersonService service) {
        this.service = service;
    }

    /**
     * 获取所有特色人物列表
     * HTTP方法: GET
     * 请求路径: /api/featured-people
     * @return 包含所有特色人物DTO的列表，HTTP状态码200
     */
    @GetMapping("/all")
    public ResponseEntity<List<AiRole>> getAllFeaturedPersons() {
        List<AiRole> dtos = service.getAllFeaturedPersons();
        return ResponseEntity.ok(dtos);
    }

    /**
     * 根据ID获取单个特色人物
     * HTTP方法: GET
     * 请求路径: /api/featured-people/{id}
     * @param id 特色人物ID
     * @return 若存在则返回特色人物DTO和HTTP 200状态码，否则返回HTTP 404状态码
     */
    @GetMapping("/{id}")
    public ResponseEntity<FeaturedPersonDto> getFeaturedPersonById(@PathVariable Long id) {
        return service.getFeaturedPersonById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * 创建新的特色人物
     * HTTP方法: POST
     * 请求路径: /api/featured-people
     * 请求体: 包含特色人物信息的JSON
     * @param dto 特色人物数据传输对象
     * @return 返回新创建的特色人物DTO和HTTP 201状态码
     */
    @PostMapping("/create")
    public ResponseEntity<FeaturedPersonDto> createFeaturedPerson(@RequestBody FeaturedPersonDto dto) {
        FeaturedPersonDto createdDto = service.createFeaturedPerson(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdDto);
    }

    /**
     * 更新现有特色人物
     * HTTP方法: PUT
     * 请求路径: /api/featured-people/{id}
     * 请求体: 包含更新信息的特色人物JSON
     * @param id 要更新的特色人物ID
     * @param dto 包含更新信息的特色人物DTO
     * @return 若存在则返回更新后的特色人物DTO和HTTP 200状态码，否则返回HTTP 404状态码
     */
    @PutMapping("/{id}")
    public ResponseEntity<FeaturedPersonDto> updateFeaturedPerson(
            @PathVariable Long id,
            @RequestBody FeaturedPersonDto dto
    ) {
        return service.updateFeaturedPerson(id, dto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * 删除特色人物
     * HTTP方法: DELETE
     * 请求路径: /api/featured-people/{id}
     * @param id 要删除的特色人物ID
     * @return 若删除成功返回HTTP 204状态码，若不存在则返回HTTP 404状态码
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFeaturedPerson(@PathVariable Long id) {
        boolean deleted = service.deleteFeaturedPerson(id);
        return deleted ?
                ResponseEntity.noContent().build() :
                ResponseEntity.notFound().build();
    }
}