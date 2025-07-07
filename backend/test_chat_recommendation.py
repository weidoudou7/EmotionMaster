#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Chat页面混合推荐和角色切换功能测试脚本
测试混合推荐算法和左右滑切换AI角色功能
"""

import requests
import json
import time
from typing import List, Dict, Any

# 配置
BASE_URL = "http://localhost:8081/api"
TEST_USER_ID = 574  # 测试用户ID

class ChatRecommendationTester:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json'
        })

    def test_hybrid_recommendations(self) -> List[Dict[str, Any]]:
        """测试混合推荐算法"""
        print("🧪 测试混合推荐算法...")
        
        try:
            url = f"{BASE_URL}/recommendation/hybrid"
            params = {
                'userId': TEST_USER_ID,
                'limit': 10
            }
            
            response = self.session.get(url, params=params, timeout=15)
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    recommendations = data.get('data', [])
                    print(f"✅ 混合推荐成功，获取到 {len(recommendations)} 个推荐角色")
                    
                    for i, role in enumerate(recommendations[:3]):  # 只显示前3个
                        print(f"  {i+1}. {role.get('roleName', 'Unknown')} - {role.get('roleType', 'Unknown')}")
                    
                    return recommendations
                else:
                    print(f"❌ 混合推荐失败: {data.get('message', 'Unknown error')}")
            else:
                print(f"❌ HTTP错误: {response.status_code}")
                
        except requests.exceptions.Timeout:
            print("❌ 请求超时")
        except Exception as e:
            print(f"❌ 测试失败: {e}")
        
        return []

    def test_popular_roles(self) -> List[Dict[str, Any]]:
        """测试热门角色API"""
        print("🔥 测试热门角色API...")
        
        try:
            url = f"{BASE_URL}/ai-roles/popular"
            params = {'limit': 5}
            
            response = self.session.get(url, params=params, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    popular_roles = data.get('data', [])
                    print(f"✅ 热门角色获取成功，数量: {len(popular_roles)}")
                    return popular_roles
                else:
                    print(f"❌ 热门角色获取失败: {data.get('message', 'Unknown error')}")
            else:
                print(f"❌ HTTP错误: {response.status_code}")
                
        except Exception as e:
            print(f"❌ 测试失败: {e}")
        
        return []

    def test_user_behavior_recording(self, role_id: int, action_type: str = "view"):
        """测试用户行为记录"""
        print(f"📊 测试用户行为记录: {action_type} 角色 {role_id}")
        
        try:
            url = f"{BASE_URL}/recommendation/behavior"
            data = {
                'userId': TEST_USER_ID,
                'roleId': role_id,
                'actionType': action_type,
                'score': 1.0
            }
            
            response = self.session.post(url, json=data, timeout=10)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    print(f"✅ 行为记录成功: {action_type}")
                else:
                    print(f"❌ 行为记录失败: {result.get('message', 'Unknown error')}")
            else:
                print(f"❌ HTTP错误: {response.status_code}")
                
        except Exception as e:
            print(f"❌ 测试失败: {e}")

    def test_conversation_creation(self, ai_role_id: int) -> str:
        """测试对话创建"""
        print(f"💬 测试对话创建: AI角色 {ai_role_id}")
        
        try:
            url = f"{BASE_URL}/conversations/find-or-create"
            data = {
                'userId': TEST_USER_ID,
                'aiRoleId': ai_role_id,
                'title': f'与AI角色{ai_role_id}的对话'
            }
            
            response = self.session.post(url, json=data, timeout=10)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    conversation = result.get('data', {})
                    conversation_id = conversation.get('id')
                    print(f"✅ 对话创建成功，ID: {conversation_id}")
                    return str(conversation_id)
                else:
                    print(f"❌ 对话创建失败: {result.get('message', 'Unknown error')}")
            else:
                print(f"❌ HTTP错误: {response.status_code}")
                
        except Exception as e:
            print(f"❌ 测试失败: {e}")
        
        return ""

    def test_chat_message(self, conversation_id: str, message: str):
        """测试发送聊天消息"""
        print(f"💭 测试发送聊天消息: {message[:20]}...")
        
        try:
            url = f"{BASE_URL}/chat/featured"
            data = {
                'message': message,
                'conversationId': conversation_id,
                'description': '测试角色描述'
            }
            
            response = self.session.post(url, json=data, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    ai_response = result.get('data', '')
                    print(f"✅ AI回复成功: {ai_response[:50]}...")
                    return ai_response
                else:
                    print(f"❌ AI回复失败: {result.get('message', 'Unknown error')}")
            else:
                print(f"❌ HTTP错误: {response.status_code}")
                
        except Exception as e:
            print(f"❌ 测试失败: {e}")
        
        return ""

    def test_role_switching_simulation(self):
        """模拟角色切换流程"""
        print("🔄 模拟角色切换流程...")
        
        # 1. 获取推荐角色
        recommendations = self.test_hybrid_recommendations()
        if not recommendations:
            print("❌ 无法获取推荐角色，使用热门角色")
            recommendations = self.test_popular_roles()
        
        if not recommendations:
            print("❌ 无法获取任何角色，测试终止")
            return
        
        # 2. 模拟角色切换
        for i, role in enumerate(recommendations[:3]):  # 测试前3个角色
            role_id = role.get('id')
            role_name = role.get('roleName', 'Unknown')
            
            print(f"\n🎭 切换到角色 {i+1}: {role_name}")
            
            # 记录查看行为
            self.test_user_behavior_recording(role_id, "view")
            
            # 创建对话
            conversation_id = self.test_conversation_creation(role_id)
            if conversation_id:
                # 发送测试消息
                test_message = f"你好，我是测试用户，很高兴认识你！"
                self.test_chat_message(conversation_id, test_message)
                
                # 记录聊天行为
                self.test_user_behavior_recording(role_id, "chat")
                
                # 模拟切换延迟
                time.sleep(1)
        
        print("\n✅ 角色切换模拟完成")

    def test_performance_metrics(self):
        """测试性能指标"""
        print("⚡ 测试性能指标...")
        
        # 测试推荐响应时间
        start_time = time.time()
        recommendations = self.test_hybrid_recommendations()
        end_time = time.time()
        
        response_time = (end_time - start_time) * 1000  # 转换为毫秒
        print(f"📊 混合推荐响应时间: {response_time:.2f}ms")
        
        if response_time < 5000:
            print("✅ 响应时间优秀 (< 5秒)")
        elif response_time < 10000:
            print("⚠️ 响应时间一般 (5-10秒)")
        else:
            print("❌ 响应时间过慢 (> 10秒)")

    def run_full_test(self):
        """运行完整测试"""
        print("🚀 开始Chat页面混合推荐和角色切换功能测试")
        print("=" * 60)
        
        # 1. 性能测试
        self.test_performance_metrics()
        print()
        
        # 2. 基础功能测试
        self.test_hybrid_recommendations()
        print()
        
        self.test_popular_roles()
        print()
        
        # 3. 用户行为测试
        test_role_id = 364  # 测试角色ID
        self.test_user_behavior_recording(test_role_id, "view")
        self.test_user_behavior_recording(test_role_id, "chat")
        self.test_user_behavior_recording(test_role_id, "like")
        print()
        
        # 4. 角色切换模拟
        self.test_role_switching_simulation()
        print()
        
        print("=" * 60)
        print("🎉 测试完成！")

def main():
    """主函数"""
    tester = ChatRecommendationTester()
    
    try:
        tester.run_full_test()
    except KeyboardInterrupt:
        print("\n⏹️ 测试被用户中断")
    except Exception as e:
        print(f"\n❌ 测试过程中发生错误: {e}")

if __name__ == "__main__":
    main() 