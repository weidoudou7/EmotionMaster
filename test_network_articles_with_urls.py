#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试AI文章链接功能
验证AI是否能正确返回文章链接而不是聚合内容
"""

import requests
import json
import time

# 后端API配置
BASE_URL = "http://localhost:8080"
API_ENDPOINTS = {
    "deep": "/api/articles/generate/deep",
    "tech": "/api/articles/generate/tech", 
    "industry": "/api/articles/generate/industry"
}

def test_article_generation(article_type, title):
    """测试文章生成功能"""
    print(f"\n{'='*60}")
    print(f"测试 {article_type} 类型文章生成")
    print(f"标题: {title}")
    print(f"{'='*60}")
    
    url = f"{BASE_URL}{API_ENDPOINTS[article_type]}"
    
    payload = {
        "title": title
    }
    
    try:
        print(f"发送请求到: {url}")
        print(f"请求参数: {json.dumps(payload, ensure_ascii=False, indent=2)}")
        
        response = requests.post(url, json=payload, timeout=30)
        
        print(f"\n响应状态码: {response.status_code}")
        print(f"响应头: {dict(response.headers)}")
        
        if response.status_code == 200:
            try:
                result = response.json()
                print(f"\n响应内容:")
                print(json.dumps(result, ensure_ascii=False, indent=2))
                
                # 检查是否返回了文章链接格式
                if "data" in result and "content" in result["data"]:
                    content = result["data"]["content"]
                    print(f"\n文章内容长度: {len(content)} 字符")
                    
                    # 尝试解析为JSON格式
                    try:
                        parsed_content = json.loads(content)
                        if "articles" in parsed_content and isinstance(parsed_content["articles"], list):
                            print(f"✅ 成功解析为文章链接格式!")
                            print(f"找到 {len(parsed_content['articles'])} 篇文章")
                            
                            for i, article in enumerate(parsed_content["articles"]):
                                print(f"\n文章 {i+1}:")
                                print(f"  标题: {article.get('title', 'N/A')}")
                                print(f"  作者: {article.get('author', 'N/A')}")
                                print(f"  发布时间: {article.get('publishTime', 'N/A')}")
                                print(f"  网站: {article.get('website', 'N/A')}")
                                print(f"  URL: {article.get('url', 'N/A')}")
                                print(f"  简介: {article.get('summary', 'N/A')[:100]}...")
                        else:
                            print("❌ 返回的不是文章链接格式")
                            print("内容预览:")
                            print(content[:500] + "..." if len(content) > 500 else content)
                    except json.JSONDecodeError:
                        print("❌ 返回的不是JSON格式，可能是聚合内容")
                        print("内容预览:")
                        print(content[:500] + "..." if len(content) > 500 else content)
                else:
                    print("❌ 响应格式不正确")
                    print(f"完整响应: {result}")
                    
            except json.JSONDecodeError as e:
                print(f"❌ 响应不是有效的JSON: {e}")
                print(f"原始响应: {response.text}")
        else:
            print(f"❌ 请求失败: {response.status_code}")
            print(f"错误信息: {response.text}")
            
    except requests.exceptions.Timeout:
        print("❌ 请求超时")
    except requests.exceptions.ConnectionError:
        print("❌ 连接失败，请确保后端服务正在运行")
    except Exception as e:
        print(f"❌ 请求异常: {e}")

def main():
    """主测试函数"""
    print("🧪 开始测试AI文章链接功能")
    print("="*60)
    
    # 测试深度解析专栏
    test_cases = [
        ("deep", "现代人的心理健康挑战"),
        ("deep", "压力管理的最新方法"),
        ("tech", "鸿蒙HarmonyOS开发技术动态"),
        ("tech", "ArkTS状态管理最佳实践"),
        ("industry", "2024年心理健康行业趋势"),
        ("industry", "AI技术在心理健康领域的应用")
    ]
    
    for article_type, title in test_cases:
        test_article_generation(article_type, title)
        time.sleep(2)  # 避免请求过于频繁
    
    print(f"\n{'='*60}")
    print("🎉 测试完成!")
    print("="*60)
    print("\n测试说明:")
    print("1. 如果AI返回JSON格式的文章链接，说明功能正常")
    print("2. 如果返回聚合内容，说明AI没有按照新的指令执行")
    print("3. 前端需要能够解析JSON格式并抓取文章内容")
    print("4. 建议检查AI的提示词是否正确更新")

if __name__ == "__main__":
    main() 