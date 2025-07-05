package com.ai.companion.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;
import java.nio.file.Path;

public class BaiduASRTest {
    // 替换为你的API Key和Secret Key
    private static final String API_KEY = "SyIVlTYJbs85YS5Y3bs5kwLJ";
    private static final String SECRET_KEY = "ho2emtpiYJWvdJlTSlUg7dFdeAVcEfwx";
    // 音频文件路径，请使用MP3格式
    private static final String AUDIO_FILE_PATH = "D:\\下载\\16k2.wav";

    private static final long MAX_AUDIO_SIZE = 10 * 1024 * 1024; // 10MB

    private static String cachedAccessToken = null;
    private static long tokenExpireTime = 0;

    public static void stt(String[] args) {
        try {
//            // 获取AccessToken
//            String accessToken = getAccessToken(API_KEY, SECRET_KEY);
//            System.out.println("获取的AccessToken: " + accessToken);

            // 检查音频文件
            Path audioPath = Paths.get(AUDIO_FILE_PATH);
            long fileSize = Files.size(audioPath);
            if (fileSize > MAX_AUDIO_SIZE) {
                throw new Exception("音频文件过大，最大支持10MB");
            }

            // 读取音频文件并转换为Base64
            byte[] audioData = Files.readAllBytes(Paths.get(AUDIO_FILE_PATH));
            String base64Audio = Base64.getEncoder().encodeToString(audioData);
            System.out.println("音频Base64长度: " + base64Audio.length());


            // 获取AccessToken
            String accessToken = getAccessToken(API_KEY, SECRET_KEY);
            System.out.println("获取的AccessToken: " + accessToken);
            System.out.println("AccessToken长度: " + accessToken.length()); // 正常长度约为240字符
            // 调用语音识别API
            String resultJson = recognizeSpeech(accessToken, base64Audio,audioData);

            // 解析JSON结果获取文字内容
            String recognizedText = parseRecognitionResult(resultJson);
            System.out.println("识别结果文本: " + recognizedText);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    // 手动解析识别结果JSON
    private static String parseRecognitionResult(String jsonResponse) throws Exception {
        System.out.println("API原始响应: " + jsonResponse);  // 新增这行
        // 检查错误码
        int errNoStart = jsonResponse.indexOf("\"err_no\":") + 9;
        int errNoEnd = jsonResponse.indexOf(",", errNoStart);
        int errNo = Integer.parseInt(jsonResponse.substring(errNoStart, errNoEnd).trim());

        if (errNo != 0) {
            int errMsgStart = jsonResponse.indexOf("\"err_msg\":\"") + 11;
            int errMsgEnd = jsonResponse.indexOf("\"", errMsgStart);
            String errMsg = jsonResponse.substring(errMsgStart, errMsgEnd);
            throw new Exception("识别失败，错误码: " + errNo + ", 错误信息: " + errMsg);
        }

        // 提取result数组中的第一个元素（核心修改部分）
        int resultStart = jsonResponse.indexOf("\"result\":[") + 10;  // 定位到"result":["
        if (resultStart == 9) {  // 未找到result字段
            return "未识别到语音内容";
        }

        // 提取第一个引号内的文本（识别结果）
        int textStart = resultStart + 1;  // 跳过第一个"
        int textEnd = jsonResponse.indexOf("\"", textStart);  // 找到第二个"
        if (textEnd == -1) {
            return "未识别到语音内容";
        }

        return jsonResponse.substring(textStart, textEnd);  // 返回提取的文本
    }

    /**
     * 获取AccessToken
     */
//    private static String getAccessToken(String apiKey, String secretKey) throws Exception {
//        long currentTime = System.currentTimeMillis() / 1000;
//
//        if (cachedAccessToken != null && tokenExpireTime > currentTime + 300) {
//            return cachedAccessToken;
//        }
//
//        String url = "https://aip.baidubce.com/oauth/2.0/token" +
//                "?grant_type=client_credentials" +
//                "&client_id=" + apiKey +
//                "&client_secret=" + secretKey;
//
//        URL obj = new URL(url);
//        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
//        con.setRequestMethod("GET");
//
//        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
//        String inputLine;
//        StringBuilder response = new StringBuilder();
//
//        while ((inputLine = in.readLine()) != null) {
//            response.append(inputLine);
//        }
//        in.close();
//
//        String jsonResponse = response.toString();
//        System.out.println("获取Token响应: " + jsonResponse); // 调试用
//
//        // 解析access_token
//        int tokenStart = jsonResponse.indexOf("\"access_token\":\"") + 15;
//        if (tokenStart == 14) {
//            throw new Exception("获取AccessToken失败: " + jsonResponse);
//        }
//        int tokenEnd = jsonResponse.indexOf("\"", tokenStart);
//        String accessToken = jsonResponse.substring(tokenStart, tokenEnd);
//
//        // 解析expires_in（有效期，单位秒）
//        int expiresStart = jsonResponse.indexOf("\"expires_in\":") + 13;
//        int expiresEnd = jsonResponse.indexOf(",", expiresStart);
//        if (expiresEnd == -1) {
//            expiresEnd = jsonResponse.indexOf("}", expiresStart);
//        }
//        long expiresIn = Long.parseLong(jsonResponse.substring(expiresStart, expiresEnd).trim());
//        tokenExpireTime = currentTime + expiresIn;
//
//        cachedAccessToken = accessToken;
//        return accessToken;
//    }
    private static String getAccessToken(String apiKey, String secretKey) throws Exception {
        long currentTime = System.currentTimeMillis() / 1000;

        if (cachedAccessToken != null && tokenExpireTime > currentTime + 300) {
            return cachedAccessToken;
        }

        String url = "https://aip.baidubce.com/oauth/2.0/token" +
                "?grant_type=client_credentials" +
                "&client_id=" + apiKey +
                "&client_secret=" + secretKey;

        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
        con.setRequestMethod("GET");

        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();

        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        String jsonResponse = response.toString();
        System.out.println("获取Token响应: " + jsonResponse);

        // 使用更健壮的JSON解析方式
        try {
            // 使用简单的JSON解析提取access_token
            int tokenStart = jsonResponse.indexOf("\"access_token\":\"");
            if (tokenStart == -1) {
                throw new Exception("无法找到access_token字段");
            }
            tokenStart += 16; // "\"access_token\":\""的长度
            int tokenEnd = jsonResponse.indexOf("\"", tokenStart);
            if (tokenEnd == -1) {
                throw new Exception("access_token字段格式不正确");
            }
            String accessToken = jsonResponse.substring(tokenStart, tokenEnd);

            // 解析expires_in
            int expiresStart = jsonResponse.indexOf("\"expires_in\":");
            if (expiresStart == -1) {
                throw new Exception("无法找到expires_in字段");
            }
            expiresStart += 13;
            int expiresEnd = jsonResponse.indexOf(",", expiresStart);
            if (expiresEnd == -1) {
                expiresEnd = jsonResponse.indexOf("}", expiresStart);
            }
            long expiresIn = Long.parseLong(jsonResponse.substring(expiresStart, expiresEnd).trim());

            tokenExpireTime = currentTime + expiresIn;
            cachedAccessToken = accessToken;

            System.out.println("成功获取AccessToken: " + accessToken.substring(0, 10) + "..."); // 打印部分token用于调试
            return accessToken;
        } catch (Exception e) {
            throw new Exception("解析AccessToken失败: " + e.getMessage() + "，原始响应: " + jsonResponse);
        }
    }

    // 新增方法：从WAV文件头中获取采样率和声道数
    private static int[] getWavInfo(byte[] wavData) throws Exception {
        int[] info = new int[2];  // [采样率, 声道数]

        // 检查是否为WAV文件（RIFF头）
        if (wavData.length < 44 ||
                !(wavData[0] == 'R' && wavData[1] == 'I' && wavData[2] == 'F' && wavData[3] == 'F')) {
            throw new Exception("不是有效的WAV文件格式");
        }

        // 读取采样率（字节24-27）
        info[0] = (wavData[27] & 0xFF) << 24 |
                (wavData[26] & 0xFF) << 16 |
                (wavData[25] & 0xFF) << 8 |
                (wavData[24] & 0xFF);

        // 读取声道数（字节22-23）
        info[1] = (wavData[23] & 0xFF) << 8 |
                (wavData[22] & 0xFF);

        return info;
    }
    /**
     * 调用语音识别API
     */
    private static String recognizeSpeech(String accessToken, String base64Audio, byte[] audioData) throws Exception {
        String url = "https://vop.baidu.com/server_api";
        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();

        // 设置请求头
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/json");

        // 获取WAV文件信息
        int[] wavInfo = getWavInfo(audioData);
        int sampleRate = wavInfo[0];  // 确保这行存在且未被注释
        int channels = wavInfo[1];

        System.out.println("检测到WAV文件参数：采样率=" + sampleRate + "Hz，声道数=" + channels);

//        // 构建请求体
//        StringBuilder requestBody = new StringBuilder();
//        requestBody.append("{\"format\":\"mp3\",\"rate\":16000,\"channel\":1,")
//                .append("\"cuid\":\"test_cuid\",\"token\":\"").append(accessToken).append("\",")
//                .append("\"dev_pid\":1536,\"len\":").append(base64Audio.length()).append(",")
//                .append("\"speech\":\"").append(base64Audio).append("\"}");
// 构建请求体（使用WAV格式和自动检测的参数）
        StringBuilder requestBody = new StringBuilder();
        requestBody.append("{\"format\":\"wav\",")  // 格式为wav
                .append("\"rate\":").append(sampleRate).append(",")  // 使用文件实际采样率
                .append("\"channel\":").append(channels).append(",")  // 使用文件实际声道数
                .append("\"cuid\":\"test_cuid\",")
                .append("\"token\":\"").append(accessToken).append("\",")
                .append("\"dev_pid\":1536,")
                .append("\"len\":").append(audioData.length).append(",")  // 原始字节长度
                .append("\"speech\":\"").append(base64Audio).append("\"}");


        //System.out.println("请求体内容: " + requestBody); // 打印请求体用于调试
        System.out.println("请求体长度: " + requestBody.length()); // 调试用

        con.setDoOutput(true);
        con.getOutputStream().write(requestBody.toString().getBytes("UTF-8"));

        int responseCode = con.getResponseCode();
        if (responseCode != 200) {
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(con.getErrorStream()));
            StringBuilder errorResponse = new StringBuilder();
            String errorLine;

            while ((errorLine = errorReader.readLine()) != null) {
                errorResponse.append(errorLine);
            }
            errorReader.close();

            throw new Exception("API请求失败，状态码: " + responseCode + ", 错误信息: " + errorResponse.toString());
        }

        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
        StringBuilder response = new StringBuilder();
        String inputLine;

        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        return response.toString();
    }
}