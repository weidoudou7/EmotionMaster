#!/usr/bin/env python3
"""
测试修改后的featured_chat接口，验证消息自动保存功能
"""

import requests
import json
import time

# API基础URL
BASE_URL = "http://localhost:8081/api"

def test_featured_chat():
    """测试特色聊天接口"""
    print("🧪 测试特色聊天接口...")
    
    try:
        # 发送聊天请求
        response = requests.get(
            f"{BASE_URL}/ai/featured_chat",
            params={
                "desc": "你是一个专业的心理咨询师，擅长倾听和给予建议。",
                "prompt": "我今天心情不太好，能给我一些建议吗？",
                "chatId": "test_chat_001",
                "userId": 405
            }
        )
        
        print(f"📡 响应状态码: {response.status_code}")
        print(f"📡 响应内容: {response.text[:200]}...")  # 只显示前200个字符
        
        if response.status_code == 200:
            print("✅ 特色聊天请求成功!")
            return True
        else:
            print(f"❌ 特色聊天请求失败: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ 请求异常: {e}")
        return False

def check_saved_messages():
    """检查保存的消息"""
    print("\n🔍 检查保存的消息...")
    
    # 检查会话1的消息（假设这是创建的会话ID）
    conversation_id = 1
    
    try:
        response = requests.get(
            f"{BASE_URL}/ai/message/list",
            params={"conversationId": conversation_id}
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get("success"):
                messages = result.get("data", [])
                print(f"📝 会话 {conversation_id} 有 {len(messages)} 条消息:")
                for i, msg in enumerate(messages[-4:], 1):  # 显示最后4条消息
                    print(f"  {i}. [{msg.get('senderType')}] {msg.get('content')[:50]}...")
                    print(f"     时间: {msg.get('timestamp')}")
                    print(f"     情感分值: {msg.get('sentimentScore')}")
                    print(f"     话题标签: {msg.get('topicTag')}")
                    print()
            else:
                print(f"❌ 获取会话 {conversation_id} 消息失败: {result.get('message')}")
        else:
            print(f"❌ 获取会话 {conversation_id} 消息HTTP错误: {response.status_code}")
            
    except Exception as e:
        print(f"❌ 检查会话 {conversation_id} 消息异常: {e}")

def test_multiple_chats():
    """测试多次聊天"""
    print("\n🧪 测试多次聊天...")
    
    chat_messages = [
        "你好，请介绍一下你自己",
        "我今天心情不太好",
        "能给我一些建议吗？"
    ]
    
    for i, message in enumerate(chat_messages, 1):
        print(f"\n--- 第{i}次聊天 ---")
        try:
            response = requests.get(
                f"{BASE_URL}/ai/featured_chat",
                params={
                    "desc": "你是一个友好的AI助手，擅长聊天和回答问题。",
                    "prompt": message,
                    "chatId": "test_chat_002",
                    "userId": 405
                }
            )
            
            if response.status_code == 200:
                print(f"✅ 第{i}次聊天成功!")
            else:
                print(f"❌ 第{i}次聊天失败: {response.status_code}")
                
        except Exception as e:
            print(f"❌ 第{i}次聊天异常: {e}")
        
        time.sleep(1)  # 等待一下，让消息保存完成

def main():
    """主函数"""
    print("🚀 开始测试修改后的featured_chat接口...")
    print(f"🌐 API基础URL: {BASE_URL}")
    
    # 测试特色聊天接口
    test_featured_chat()
    time.sleep(2)  # 等待一下，让消息保存完成
    
    # 检查保存的消息
    check_saved_messages()
    
    # 测试多次聊天
    test_multiple_chats()
    time.sleep(2)  # 等待一下，让消息保存完成
    
    # 再次检查保存的消息
    check_saved_messages()
    
    print("\n🎉 测试完成!")

if __name__ == "__main__":
    main() 