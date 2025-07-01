#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试头像上传API的脚本
"""

import requests
import json
import base64

# API基础URL
BASE_URL = "http://localhost:8081/api"

def test_avatar_upload():
    """测试头像上传API"""
    print("=== 测试头像上传API ===")
    
    # 1. 测试健康检查
    print("\n1. 测试健康检查...")
    try:
        response = requests.get(f"{BASE_URL}/user/health")
        print(f"健康检查状态: {response.status_code}")
        print(f"响应内容: {response.text}")
    except Exception as e:
        print(f"健康检查失败: {e}")
        return
    
    # 2. 创建一个简单的base64图片数据（1x1像素的PNG）
    print("\n2. 创建测试图片数据...")
    # 1x1像素的透明PNG图片的base64数据
    png_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    image_data = f"data:image/png;base64,{png_base64}"
    
    # 3. 测试base64头像上传
    print("\n3. 测试base64头像上传...")
    try:
        payload = {
            "imageData": image_data
        }
        response = requests.post(
            f"{BASE_URL}/user/100000001/avatar/base64",
            json=payload,
            headers={'Content-Type': 'application/json'}
        )
        print(f"头像上传状态: {response.status_code}")
        print(f"响应内容: {response.text}")
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print("✅ 头像上传成功!")
                print(f"头像URL: {result.get('data')}")
            else:
                print("❌ 头像上传失败!")
                print(f"错误信息: {result.get('message')}")
        else:
            print("❌ 头像上传请求失败!")
            
    except Exception as e:
        print(f"头像上传失败: {e}")
    
    # 4. 验证用户信息是否更新
    print("\n4. 验证用户信息更新...")
    try:
        response = requests.get(f"{BASE_URL}/user/100000001")
        print(f"获取用户信息状态: {response.status_code}")
        print(f"响应内容: {response.text}")
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                user_info = result.get('data', {})
                avatar_url = user_info.get('userAvatar', '')
                print(f"用户头像URL: {avatar_url}")
                if avatar_url and avatar_url != '/avatars/default.png':
                    print("✅ 用户头像已更新!")
                else:
                    print("❌ 用户头像未更新!")
            else:
                print("❌ 获取用户信息失败!")
        else:
            print("❌ 获取用户信息请求失败!")
            
    except Exception as e:
        print(f"获取用户信息失败: {e}")

if __name__ == "__main__":
    test_avatar_upload() 