package com.ai.companion.controller;

import com.ai.companion.dto.SendVerificationCodeRequest;
import com.ai.companion.dto.VerifyCodeRequest;
import com.ai.companion.service.AuthService;
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

    @PostMapping("/send-code")
    public ResponseEntity<String> sendVerificationCode(@RequestBody SendVerificationCodeRequest request) {
        if (request.getEmail() == null || request.getEmail().isEmpty()) {
            return ResponseEntity.badRequest().body("邮箱不能为空");
        }
        authService.sendVerificationCode(request.getEmail());
        return ResponseEntity.ok("验证码已发送，请查收");
    }

    @PostMapping("/verify-code")
    public ResponseEntity<String> verifyCode(@RequestBody VerifyCodeRequest request) {
        if (request.getEmail() == null || request.getEmail().isEmpty() ||
            request.getVerificationCode() == null || request.getVerificationCode().isEmpty()) {
            return ResponseEntity.badRequest().body("邮箱和验证码不能为空");
        }
        if (authService.verifyCode(request.getEmail(), request.getVerificationCode())) {
            // 在实际应用中，这里会生成JWT token或创建用户会话
            return ResponseEntity.ok("验证成功，登录/注册成功");
        } else {
            return ResponseEntity.badRequest().body("验证码错误或已失效");
        }
    }
} 