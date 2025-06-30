"""
后端API示例代码 - 支持人物类型特点的聊天系统
使用Python Flask框架示例，你可以根据实际技术栈调整
"""

import json
import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import openai  # 或其他AI服务

app = Flask(__name__)
CORS(app)

# 加载人物类型配置
def load_character_personalities():
    """加载人物类型配置文件"""
    try:
        with open('character_personalities.json', 'r', encoding='utf-8') as f:
            return json.load(f)['character_personalities']
    except FileNotFoundError:
        print("警告: character_personalities.json 文件未找到，使用默认配置")
        return {
            "default": {
                "name": "AI助手",
                "personality": "我是一个友好的AI助手，乐于帮助用户解决问题。",
                "conversation_style": "friendly, helpful, informative, patient",
                "language": "Chinese",
                "specialties": ["问题解答", "信息提供", "友好交流", "技术支持"],
                "greeting": "你好！我是AI助手，很高兴为你服务。有什么我可以帮助你的吗？",
                "system_prompt": "你是一个友好的AI助手，乐于帮助用户解决问题。说话要友好、耐心、有礼貌，提供有用的信息和帮助。"
            }
        }

# 全局变量存储人物配置
CHARACTER_PERSONALITIES = load_character_personalities()

# 聊天历史存储（实际项目中应该使用数据库）
chat_histories = {}

@app.route('/api/ai/chat/<identity>', methods=['POST'])
def chat_with_ai(identity):
    """
    AI聊天接口
    参数:
    - identity: 人物类型标识
    - prompt: 用户输入的消息
    - chatId: 聊天会话ID
    """
    try:
        # 获取请求参数
        prompt = request.args.get('prompt', '')
        chat_id = request.args.get('chatId', 'default')
        
        if not prompt:
            return jsonify({
                'success': False,
                'message': '用户消息不能为空',
                'data': ''
            }), 400
        
        # 获取人物配置
        character_config = CHARACTER_PERSONALITIES.get(identity, CHARACTER_PERSONALITIES['default'])
        
        # 构建系统提示词
        system_prompt = character_config['system_prompt']
        
        # 获取聊天历史
        chat_history = chat_histories.get(chat_id, [])
        
        # 构建完整的对话上下文
        messages = [
            {"role": "system", "content": system_prompt}
        ]
        
        # 添加历史对话（限制长度，避免token过多）
        for msg in chat_history[-10:]:  # 只保留最近10条消息
            messages.append({
                "role": "user" if msg['is_user'] else "assistant",
                "content": msg['content']
            })
        
        # 添加当前用户消息
        messages.append({"role": "user", "content": prompt})
        
        # 调用AI服务（这里使用OpenAI示例，你可以替换为其他AI服务）
        ai_response = call_ai_service(messages, character_config)
        
        # 保存对话历史
        chat_histories[chat_id] = chat_history + [
            {"is_user": True, "content": prompt},
            {"is_user": False, "content": ai_response}
        ]
        
        # 限制历史记录长度
        if len(chat_histories[chat_id]) > 20:
            chat_histories[chat_id] = chat_histories[chat_id][-20:]
        
        return jsonify({
            'success': True,
            'message': 'success',
            'data': ai_response
        })
        
    except Exception as e:
        print(f"聊天API错误: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'聊天失败: {str(e)}',
            'data': ''
        }), 500

def call_ai_service(messages, character_config):
    """
    调用AI服务
    这里使用OpenAI示例，你可以替换为其他AI服务
    """
    try:
        # 设置OpenAI API密钥（实际项目中应该从环境变量获取）
        openai.api_key = os.getenv('OPENAI_API_KEY', 'your-api-key-here')
        
        # 调用OpenAI API
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",  # 或其他模型
            messages=messages,
            max_tokens=1000,
            temperature=0.7,
            presence_penalty=0.1,
            frequency_penalty=0.1
        )
        
        return response.choices[0].message.content.strip()
        
    except Exception as e:
        print(f"AI服务调用失败: {str(e)}")
        # 返回默认回复
        return f"抱歉，我现在无法回复。{character_config.get('name', 'AI助手')}正在休息中，请稍后再试。"

@app.route('/api/ai/identities', methods=['GET'])
def get_ai_identities():
    """获取所有可用的AI身份列表"""
    try:
        identities = list(CHARACTER_PERSONALITIES.keys())
        return jsonify({
            'success': True,
            'message': 'success',
            'data': identities
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'获取身份列表失败: {str(e)}',
            'data': []
        }), 500

@app.route('/api/user/health', methods=['GET'])
def health_check():
    """健康检查接口"""
    return jsonify({
        'success': True,
        'message': 'Service is healthy',
        'data': 'OK'
    })

@app.route('/api/character/<identity>', methods=['GET'])
def get_character_info(identity):
    """获取特定人物的详细信息"""
    try:
        character_info = CHARACTER_PERSONALITIES.get(identity, CHARACTER_PERSONALITIES['default'])
        return jsonify({
            'success': True,
            'message': 'success',
            'data': character_info
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'获取人物信息失败: {str(e)}',
            'data': {}
        }), 500

if __name__ == '__main__':
    # 重新加载人物配置
    CHARACTER_PERSONALITIES = load_character_personalities()
    
    print("可用的AI身份:")
    for identity, config in CHARACTER_PERSONALITIES.items():
        print(f"- {identity}: {config['personality']}")
    
    # 启动服务器
    app.run(host='0.0.0.0', port=8081, debug=True) 