#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试搜索API的脚本
"""

import requests
import json

# API基础URL
BASE_URL = "http://localhost:8081/api"

def test_search_api():
    """测试搜索API"""
    print("=== 测试搜索API ===")
    
    # 1. 测试健康检查
    print("\n1. 测试健康检查...")
    try:
        response = requests.get(f"{BASE_URL}/user/health")
        print(f"健康检查状态: {response.status_code}")
        print(f"响应内容: {response.text}")
    except Exception as e:
        print(f"健康检查失败: {e}")
        return
    
    # 2. 测试测试用户检查
    print("\n2. 测试测试用户检查...")
    try:
        response = requests.get(f"{BASE_URL}/test/user/check")
        print(f"测试用户检查状态: {response.status_code}")
        print(f"响应内容: {response.text}")
    except Exception as e:
        print(f"测试用户检查失败: {e}")
    
    # 3. 测试搜索测试用户
    print("\n3. 测试搜索测试用户...")
    try:
        response = requests.get(f"{BASE_URL}/user/search/100000001")
        print(f"搜索测试用户状态: {response.status_code}")
        print(f"响应内容: {response.text}")
    except Exception as e:
        print(f"搜索测试用户失败: {e}")
    
    # 4. 测试搜索不存在的用户
    print("\n4. 测试搜索不存在的用户...")
    try:
        response = requests.get(f"{BASE_URL}/user/search/999999999")
        print(f"搜索不存在用户状态: {response.status_code}")
        print(f"响应内容: {response.text}")
    except Exception as e:
        print(f"搜索不存在用户失败: {e}")

if __name__ == "__main__":
    test_search_api() 