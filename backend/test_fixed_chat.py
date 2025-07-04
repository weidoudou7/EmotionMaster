#!/usr/bin/env python3
"""
测试修复后的聊天接口
"""

import requests
import json
import time

# API基础URL
BASE_URL = "http://localhost:8081/api"

def test_featured_chat_without_userid():
    """测试不带userId参数的特色聊天接口"""
    print("🧪 测试不带userId参数的特色聊天接口...")
    
    try:
        # 发送聊天请求，不传递userId参数
        response = requests.get(
            f"{BASE_URL}/ai/featured_chat",
            params={
                "desc": "你是一个专业的心理咨询师，擅长倾听和给予建议。",
                "prompt": "你好，我今天心情不太好",
                "chatId": "test_chat_no_userid"
            }
        )
        
        print(f"📡 响应状态码: {response.status_code}")
        print(f"📡 响应内容: {response.text[:200]}...")  # 只显示前200个字符
        
        if response.status_code == 200:
            print("✅ 不带userId参数的聊天请求成功!")
            return True
        else:
            print(f"❌ 不带userId参数的聊天请求失败: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ 请求异常: {e}")
        return False

def test_featured_chat_with_userid():
    """测试带userId参数的特色聊天接口"""
    print("\n🧪 测试带userId参数的特色聊天接口...")
    
    try:
        # 发送聊天请求，传递userId参数
        response = requests.get(
            f"{BASE_URL}/ai/featured_chat",
            params={
                "desc": "你是一个友好的AI助手，擅长聊天和回答问题。",
                "prompt": "请介绍一下你自己",
                "chatId": "test_chat_with_userid",
                "userId": 405
            }
        )
        
        print(f"📡 响应状态码: {response.status_code}")
        print(f"📡 响应内容: {response.text[:200]}...")  # 只显示前200个字符
        
        if response.status_code == 200:
            print("✅ 带userId参数的聊天请求成功!")
            return True
        else:
            print(f"❌ 带userId参数的聊天请求失败: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ 请求异常: {e}")
        return False

def check_saved_messages():
    """检查保存的消息"""
    print("\n🔍 检查保存的消息...")
    
    # 检查会话1的消息（假设这是创建的会话ID）
    conversation_ids = [1, 2]  # 检查前两个会话
    
    for conv_id in conversation_ids:
        try:
            response = requests.get(
                f"{BASE_URL}/ai/message/list",
                params={"conversationId": conv_id}
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get("success"):
                    messages = result.get("data", [])
                    print(f"📝 会话 {conv_id} 有 {len(messages)} 条消息:")
                    for i, msg in enumerate(messages[-2:], 1):  # 显示最后2条消息
                        print(f"  {i}. [{msg.get('senderType')}] {msg.get('content')[:50]}...")
                        print(f"     时间: {msg.get('timestamp')}")
                        print(f"     情感分值: {msg.get('sentimentScore')}")
                        print(f"     话题标签: {msg.get('topicTag')}")
                        print()
                else:
                    print(f"❌ 获取会话 {conv_id} 消息失败: {result.get('message')}")
            else:
                print(f"❌ 获取会话 {conv_id} 消息HTTP错误: {response.status_code}")
                
        except Exception as e:
            print(f"❌ 检查会话 {conv_id} 消息异常: {e}")

def main():
    """主函数"""
    print("🚀 开始测试修复后的聊天接口...")
    print(f"🌐 API基础URL: {BASE_URL}")
    
    # 测试不带userId参数的聊天
    test_featured_chat_without_userid()
    time.sleep(2)  # 等待一下，让消息保存完成
    
    # 测试带userId参数的聊天
    test_featured_chat_with_userid()
    time.sleep(2)  # 等待一下，让消息保存完成
    
    # 检查保存的消息
    check_saved_messages()
    
    print("\n🎉 测试完成!")

if __name__ == "__main__":
    main() 