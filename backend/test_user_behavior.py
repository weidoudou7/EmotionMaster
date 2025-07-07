#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
用户行为记录功能测试脚本
测试混合推荐算法和用户行为记录系统
"""

import requests
import json
import time
from datetime import datetime

# 配置
BASE_URL = "http://localhost:8081/api"
USER_ID = 574  # 测试用户ID
ROLE_ID = 364  # 测试角色ID

def test_user_behavior_recording():
    """测试用户行为记录功能"""
    print("=== 测试用户行为记录功能 ===")
    
    # 测试记录不同类型的用户行为
    behaviors = [
        {"actionType": "view", "score": 0.3, "description": "用户查看角色"},
        {"actionType": "click", "score": 0.5, "description": "用户点击角色"},
        {"actionType": "chat", "score": 1.0, "description": "用户开始聊天"},
        {"actionType": "like", "score": 0.8, "description": "用户点赞角色"},
        {"actionType": "share", "score": 0.6, "description": "用户分享角色"}
    ]
    
    for behavior in behaviors:
        try:
            url = f"{BASE_URL}/user-behavior/record/{behavior['actionType']}"
            params = {
                "userId": USER_ID,
                "roleId": ROLE_ID
            }
            
            response = requests.post(url, params=params)
            print(f"{behavior['description']}: {'✅ 成功' if response.status_code == 200 else '❌ 失败'}")
            
            if response.status_code == 200:
                result = response.json()
                print(f"  响应: {result.get('message', '无消息')}")
            
        except Exception as e:
            print(f"{behavior['description']}: ❌ 异常 - {str(e)}")
        
        time.sleep(0.5)  # 避免请求过快

def test_recommendation_algorithms():
    """测试推荐算法功能"""
    print("\n=== 测试推荐算法功能 ===")
    
    algorithms = [
        {"name": "个性化推荐", "url": "/recommendation/personalized"},
        {"name": "内容推荐", "url": "/recommendation/content-based"},
        {"name": "协同过滤推荐", "url": "/recommendation/collaborative"},
        {"name": "混合推荐", "url": "/recommendation/hybrid"}
    ]
    
    for algo in algorithms:
        try:
            url = f"{BASE_URL}{algo['url']}"
            params = {
                "userId": USER_ID,
                "limit": 5
            }
            
            response = requests.get(url, params=params)
            print(f"{algo['name']}: {'✅ 成功' if response.status_code == 200 else '❌ 失败'}")
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    data = result.get('data', [])
                    print(f"  推荐数量: {len(data)}")
                    if data:
                        print(f"  第一个推荐: {data[0].get('roleName', '未知')}")
                else:
                    print(f"  错误: {result.get('message', '未知错误')}")
            
        except Exception as e:
            print(f"{algo['name']}: ❌ 异常 - {str(e)}")
        
        time.sleep(0.5)

def test_recommendation_explanation():
    """测试推荐解释功能"""
    print("\n=== 测试推荐解释功能 ===")
    
    try:
        # 先获取推荐结果
        url = f"{BASE_URL}/recommendation/hybrid"
        params = {
            "userId": USER_ID,
            "limit": 3
        }
        
        response = requests.get(url, params=params)
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                recommendations = result.get('data', [])
                if recommendations:
                    # 获取推荐角色的ID列表
                    role_ids = [str(role.get('id')) for role in recommendations if role.get('id')]
                    
                    if role_ids:
                        # 获取推荐解释
                        explanation_url = f"{BASE_URL}/recommendation/explanation"
                        explanation_params = {
                            "userId": USER_ID,
                            "roleIds": ",".join(role_ids)
                        }
                        
                        explanation_response = requests.get(explanation_url, params=explanation_params)
                        if explanation_response.status_code == 200:
                            explanation_result = explanation_response.json()
                            if explanation_result.get('success'):
                                explanation = explanation_result.get('data', '无解释')
                                print(f"✅ 推荐解释获取成功")
                                print(f"解释内容: {explanation}")
                            else:
                                print(f"❌ 推荐解释获取失败: {explanation_result.get('message')}")
                        else:
                            print(f"❌ 推荐解释请求失败: {explanation_response.status_code}")
                    else:
                        print("❌ 没有获取到有效的推荐角色ID")
                else:
                    print("❌ 没有获取到推荐结果")
            else:
                print(f"❌ 推荐获取失败: {result.get('message')}")
        else:
            print(f"❌ 推荐请求失败: {response.status_code}")
            
    except Exception as e:
        print(f"❌ 推荐解释测试异常: {str(e)}")

def test_user_behavior_analysis():
    """测试用户行为分析功能"""
    print("\n=== 测试用户行为分析功能 ===")
    
    try:
        # 获取用户行为记录
        url = f"{BASE_URL}/user-behavior/user/{USER_ID}"
        response = requests.get(url)
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                behaviors = result.get('data', [])
                print(f"✅ 用户行为记录获取成功")
                print(f"行为记录数量: {len(behaviors)}")
                
                # 统计行为类型
                action_counts = {}
                for behavior in behaviors:
                    action_type = behavior.get('actionType', 'unknown')
                    action_counts[action_type] = action_counts.get(action_type, 0) + 1
                
                print("行为类型统计:")
                for action_type, count in action_counts.items():
                    print(f"  {action_type}: {count}次")
            else:
                print(f"❌ 用户行为记录获取失败: {result.get('message')}")
        else:
            print(f"❌ 用户行为记录请求失败: {response.status_code}")
            
    except Exception as e:
        print(f"❌ 用户行为分析测试异常: {str(e)}")

def test_popular_roles():
    """测试热门角色功能"""
    print("\n=== 测试热门角色功能 ===")
    
    try:
        url = f"{BASE_URL}/user-behavior/popular-roles"
        params = {"limit": 5}
        
        response = requests.get(url, params=params)
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                popular_roles = result.get('data', [])
                print(f"✅ 热门角色获取成功")
                print(f"热门角色数量: {len(popular_roles)}")
                
                for i, role in enumerate(popular_roles[:3], 1):
                    role_id = role.get('roleId', '未知')
                    action_count = role.get('actionCount', 0)
                    print(f"  {i}. 角色ID: {role_id}, 行为次数: {action_count}")
            else:
                print(f"❌ 热门角色获取失败: {result.get('message')}")
        else:
            print(f"❌ 热门角色请求失败: {response.status_code}")
            
    except Exception as e:
        print(f"❌ 热门角色测试异常: {str(e)}")

def main():
    """主测试函数"""
    print("🚀 开始测试用户行为记录和推荐系统")
    print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"测试用户ID: {USER_ID}")
    print(f"测试角色ID: {ROLE_ID}")
    print("=" * 50)
    
    # 执行各项测试
    test_user_behavior_recording()
    test_recommendation_algorithms()
    test_recommendation_explanation()
    test_user_behavior_analysis()
    test_popular_roles()
    
    print("\n" + "=" * 50)
    print("🎉 测试完成！")
    print(f"完成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main() 