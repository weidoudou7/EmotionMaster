package com.ai.companion.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "xunfei")
public class XunfeiConfig {

    private String appId;
    private String apiKey;
    private String apiSecret;
    private String ttsUrl = "https://tts-api.xfyun.cn/v2/tts";

    // getter 和 setter
    public String getAppId() { return appId; }
    public void setAppId(String appId) { this.appId = appId; }
    public String getApiKey() { return apiKey; }
    public void setApiKey(String apiKey) { this.apiKey = apiKey; }
    public String getApiSecret() { return apiSecret; }
    public void setApiSecret(String apiSecret) { this.apiSecret = apiSecret; }
    public String getTtsUrl() { return ttsUrl; }
    public void setTtsUrl(String ttsUrl) { this.ttsUrl = ttsUrl; }
}
