package com.ai.companion.service;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.util.Random;
import java.util.concurrent.TimeUnit;

@Service
public class AuthService {

    // private final Map<String, String> verificationCodes = new ConcurrentHashMap<>();

    private final Random random = new Random();

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    private static final String VERIFICATION_CODE_PREFIX = "email_verification_code:";
    private static final long VERIFICATION_CODE_EXPIRATION_MINUTES = 5;

    /**
     * 生成并发送验证码 (通过邮件)，并存储到 Redis
     * @param email 邮箱地址
     * @return 生成的验证码
     */
    public String sendVerificationCode(String email) {
        String code = String.format("%06d", random.nextInt(999999));
        String key = VERIFICATION_CODE_PREFIX + email;

        stringRedisTemplate.opsForValue().set(key, code, VERIFICATION_CODE_EXPIRATION_MINUTES, TimeUnit.MINUTES);

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("1731695011@qq.com"); // 请替换为你的QQ邮箱地址
        message.setTo(email);
        message.setSubject("您的验证码");
        message.setText("您的验证码是：" + code + "，请在" + VERIFICATION_CODE_EXPIRATION_MINUTES + "分钟内输入。");

        try {
            mailSender.send(message);
            System.out.println("发送验证码邮件到 " + email + ": " + code + " 并已存入 Redis，有效期 " + VERIFICATION_CODE_EXPIRATION_MINUTES + " 分钟。");
        } catch (Exception e) {
            System.err.println("发送邮件失败到 " + email + ": " + e.getMessage());
            return null;
        }
        return code;
    }

    /**
     * 验证验证码 (从 Redis 获取并验证)
     * @param email 邮箱地址
     * @param code 用户输入的验证码
     * @return true if verification successful, false otherwise
     */
    public boolean verifyCode(String email, String code) {
        String key = VERIFICATION_CODE_PREFIX + email;

        String storedCode = stringRedisTemplate.opsForValue().get(key);

        if (storedCode != null && storedCode.equals(code)) {
            stringRedisTemplate.delete(key);
            return true;
        }
        return false;
    }
} 