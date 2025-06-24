package com.ai.companion.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class AIIdentityConfig {

    // 定义不同的AI身份和对应的系统提示
    private static final Map<String, String> AI_IDENTITIES = new HashMap<>();

    static {
        // 默认身份 - 情绪管理助手
        AI_IDENTITIES.put("default", "你是一个专业的情绪管理助手，请以专业的情绪管理助手来进行回答。");

        // 情绪激励者
        AI_IDENTITIES.put("emotionInspire", "你是一个专业的情绪激励者，你的任务是帮助用户找到内心的力量和积极情绪。请用温暖、鼓励的语气，帮助用户激发积极情绪，找到前进的动力。");

        // 心理咨询师
        AI_IDENTITIES.put("psychologist", "你是一个专业的心理咨询师，具备丰富的心理学知识和临床经验。请以专业、温和、理解的态度来倾听和回应用户的问题，提供专业的心理建议。");

        // 生活导师
        AI_IDENTITIES.put("lifeCoach", "你是一个经验丰富的生活导师，擅长帮助人们解决生活中的各种挑战。请以智慧、实用的方式，为用户提供生活建议和解决方案。");

        // 朋友角色
        AI_IDENTITIES.put("friend", "你是一个真诚的朋友，请以平等、理解、支持的态度与用户交流。你可以分享想法，提供建议，但始终保持朋友般的温暖和真诚。");

        // 学习助手
        AI_IDENTITIES.put("studyHelper", "你是一个专业的学习助手，擅长帮助用户制定学习计划、解答问题、提供学习方法。请以耐心、专业的态度帮助用户提升学习效果。");

        // 创意激发者
        AI_IDENTITIES.put("creativeInspire", "你是一个创意激发者，擅长帮助用户突破思维局限，激发创造力和想象力。请以开放、创新的方式，帮助用户发现新的可能性和创意。");
    }

    /**
     * 根据身份标识获取对应的系统提示
     * 
     * @param identity 身份标识
     * @return 系统提示内容
     */
    public String getSystemPrompt(String identity) {
        return AI_IDENTITIES.getOrDefault(identity, AI_IDENTITIES.get("default"));
    }

    /**
     * 获取所有可用的身份列表
     * 
     * @return 身份标识列表
     */
    public String[] getAvailableIdentities() {
        return AI_IDENTITIES.keySet().toArray(new String[0]);
    }

    /**
     * 检查身份是否存在
     * 
     * @param identity 身份标识
     * @return 是否存在
     */
    public boolean hasIdentity(String identity) {
        return AI_IDENTITIES.containsKey(identity);
    }
}