#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试网络文章聚合功能
"""

import requests
import json

# API基础URL
BASE_URL = "http://localhost:8080"

def test_deep_analysis():
    """测试深度解析文章生成"""
    print("=== 测试深度解析文章生成 ===")
    
    url = f"{BASE_URL}/ai/article/deep-analysis"
    params = {
        "prompt": "2024年心理健康最新研究"
    }
    
    try:
        response = requests.get(url, params=params)
        print(f"状态码: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"成功: {data.get('success')}")
            print(f"消息: {data.get('message')}")
            
            if data.get('data') and data['data'].get('content'):
                content = data['data']['content']
                print(f"文章长度: {len(content)} 字符")
                print(f"文章开头: {content[:200]}...")
                
                # 检查是否包含网络搜索相关提示
                if "网络搜索" in content or "来源" in content or "聚合" in content:
                    print("✅ 文章包含网络搜索聚合内容")
                else:
                    print("⚠️ 文章可能未包含网络搜索聚合内容")
            else:
                print("❌ 未获取到文章内容")
        else:
            print(f"❌ 请求失败: {response.text}")
            
    except Exception as e:
        print(f"❌ 测试失败: {e}")

def test_tech_enjoy():
    """测试技术分享文章生成"""
    print("\n=== 测试技术分享文章生成 ===")
    
    url = f"{BASE_URL}/ai/article/tech-enjoy"
    params = {
        "prompt": "鸿蒙HarmonyOS最新技术更新"
    }
    
    try:
        response = requests.get(url, params=params)
        print(f"状态码: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"成功: {data.get('success')}")
            print(f"消息: {data.get('message')}")
            
            if data.get('data') and data['data'].get('content'):
                content = data['data']['content']
                print(f"文章长度: {len(content)} 字符")
                print(f"文章开头: {content[:200]}...")
                
                # 检查是否包含网络搜索相关提示
                if "网络搜索" in content or "来源" in content or "聚合" in content:
                    print("✅ 文章包含网络搜索聚合内容")
                else:
                    print("⚠️ 文章可能未包含网络搜索聚合内容")
            else:
                print("❌ 未获取到文章内容")
        else:
            print(f"❌ 请求失败: {response.text}")
            
    except Exception as e:
        print(f"❌ 测试失败: {e}")

def test_industry_observation():
    """测试行业观察文章生成"""
    print("\n=== 测试行业观察文章生成 ===")
    
    url = f"{BASE_URL}/ai/article/industry-observation"
    params = {
        "prompt": "心理健康行业投资趋势"
    }
    
    try:
        response = requests.get(url, params=params)
        print(f"状态码: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"成功: {data.get('success')}")
            print(f"消息: {data.get('message')}")
            
            if data.get('data') and data['data'].get('content'):
                content = data['data']['content']
                print(f"文章长度: {len(content)} 字符")
                print(f"文章开头: {content[:200]}...")
                
                # 检查是否包含网络搜索相关提示
                if "网络搜索" in content or "来源" in content or "聚合" in content:
                    print("✅ 文章包含网络搜索聚合内容")
                else:
                    print("⚠️ 文章可能未包含网络搜索聚合内容")
            else:
                print("❌ 未获取到文章内容")
        else:
            print(f"❌ 请求失败: {response.text}")
            
    except Exception as e:
        print(f"❌ 测试失败: {e}")

if __name__ == "__main__":
    print("开始测试网络文章聚合功能...")
    print("请确保后端服务正在运行在 http://localhost:8080")
    print()
    
    test_deep_analysis()
    test_tech_enjoy()
    test_industry_observation()
    
    print("\n=== 测试完成 ===")
    print("如果所有测试都显示'✅ 文章包含网络搜索聚合内容'，说明功能修改成功！") 