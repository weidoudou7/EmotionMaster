package com.ai.companion.utils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Base64;  // 使用Java标准库
import java.util.Date;
import java.util.TimeZone;

public class XunfeiSignUtil {

    /**
     * 生成讯飞 WebAPI 签名和授权信息
     */
    public static String[] generateAuthInfo(String apiKey, String apiSecret, String url)
            throws NoSuchAlgorithmException, InvalidKeyException, UnsupportedEncodingException, URISyntaxException {

        // 获取当前时间戳（RFC1123格式）
        SimpleDateFormat format = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z");
        format.setTimeZone(TimeZone.getTimeZone("GMT"));
        String date = format.format(new Date());

        // 构建签名原始字符串
        URI uri = new URI(url);
        String host = uri.getHost();
        String dateStr = "date: " + date;
        String stringToSign = "host: " + host + "\n" + dateStr;

        // 使用 HMAC-SHA256 算法生成签名
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(apiSecret.getBytes("UTF-8"), "HmacSHA256"));
        byte[] signData = mac.doFinal(stringToSign.getBytes("UTF-8"));
        String signature = Base64.getEncoder().encodeToString(signData);  // 使用Java标准库

        // 构建授权信息
        String authorization = String.format("api_key=\"%s\", algorithm=\"%s\", headers=\"%s\", signature=\"%s\"",
                apiKey, "hmac-sha256", "host date", signature);

        return new String[]{date, authorization};
    }
}