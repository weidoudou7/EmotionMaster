package com.ai.companion.controller;

import com.ai.companion.dto.SendVerificationCodeRequest;
import com.ai.companion.dto.VerifyCodeRequest;
import com.ai.companion.service.AuthService;
import com.ai.companion.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;
    private final UserService userService;

    @PostMapping("/send-code")
    public ResponseEntity<String> sendVerificationCode(@RequestBody SendVerificationCodeRequest request) {
        if (request.getEmail() == null || request.getEmail().isEmpty()) {
            return ResponseEntity.badRequest().body("邮箱不能为空");
        }
        authService.sendVerificationCode(request.getEmail());
        return ResponseEntity.ok("验证码已发送，请查收");
    }

    @PostMapping("/verify-code")
    public ResponseEntity<com.ai.companion.entity.vo.ApiResponse<com.ai.companion.entity.vo.UserInfoVO>> verifyCode(@RequestBody com.ai.companion.dto.VerifyCodeRequest request) {
        if (request.getEmail() == null || request.getEmail().isEmpty() ||
            request.getVerificationCode() == null || request.getVerificationCode().isEmpty()) {
            return ResponseEntity.badRequest().body(com.ai.companion.entity.vo.ApiResponse.error("邮箱和验证码不能为空"));
        }
        if (authService.verifyCode(request.getEmail(), request.getVerificationCode())) {
            // 验证码通过后，注册或登录用户
            com.ai.companion.entity.vo.UserInfoVO userInfo = userService.createOrLoginUserByEmail(request.getEmail());
            System.out.println("插入新用户：" + request.getEmail());
            return ResponseEntity.ok(com.ai.companion.entity.vo.ApiResponse.success("登录/注册成功", userInfo));
        } else {
            return ResponseEntity.badRequest().body(com.ai.companion.entity.vo.ApiResponse.error("验证码错误或已失效"));
        }
    }
} 