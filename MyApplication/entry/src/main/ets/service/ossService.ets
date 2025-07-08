// OSS服务类 - 用于处理阿里云OSS对象存储
import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import { Config } from '../common/config';
import { AvatarUploadRequest, AvatarUploadResponse } from '../common/types';

// 定义接口
interface OSSConfig {
  endpoint: string;
  bucketName: string;
  accessKeyId: string;
  accessKeySecret: string;
  region: string;
}

interface OSSHeaders {
  'Content-Type': string;
  'Content-Length': string;
  'Authorization': string;
}

interface OSSRequestData {
  userId: string;
  imageData: string;
  fileName: string;
}

interface OSSResponse {
  ossUrl: string;
}

interface OSSHttpRequestOptions {
  method: http.RequestMethod;
  header: OSSHeaders;
  extraData: string;
  readTimeout: number;
  connectTimeout: number;
}

interface OSSBackendHeader {
  'Content-Type': string;
}

interface OSSBackendRequestOptions {
  method: http.RequestMethod;
  header: OSSBackendHeader;
  extraData: string;
  readTimeout: number;
  connectTimeout: number;
}

interface BackendOSSResponseData {
  ossUrl: string;
}

interface BackendOSSResponse {
  success: boolean;
  message: string;
  data?: BackendOSSResponseData;
}

export class OSSService {
  private static instance: OSSService;
  private ossConfig: OSSConfig = {
    endpoint: 'https://oss-cn-hangzhou.aliyuncs.com', // 替换为你的OSS endpoint
    bucketName: 'your-bucket-name', // 替换为你的bucket名称
    accessKeyId: 'your-access-key-id', // 替换为你的AccessKey ID
    accessKeySecret: 'your-access-key-secret', // 替换为你的AccessKey Secret
    region: 'cn-hangzhou' // 替换为你的region
  };

  private constructor() {}

  public static getInstance(): OSSService {
    if (!OSSService.instance) {
      OSSService.instance = new OSSService();
    }
    return OSSService.instance;
  }

  /**
   * 上传图片文件到OSS
   * @param filePath 本地文件路径
   * @param fileName 文件名（可选，如果不提供则使用时间戳生成）
   * @returns Promise<string> 返回OSS访问URL
   */
  async uploadImageToOSS(filePath: string, fileName?: string): Promise<string> {
    try {
      console.log('☁️ [OSS] 开始上传图片到OSS');
      console.log('☁️ [OSS] 文件路径:', filePath);
      console.log('☁️ [OSS] 文件名:', fileName);

      // 读取文件内容
      const fileContent = await this.readFileAsBase64(filePath);
      console.log('☁️ [OSS] 文件读取成功，大小:', fileContent.length, '字符');

      // 生成文件名
      const finalFileName = fileName || this.generateFileName(filePath);
      console.log('☁️ [OSS] 最终文件名:', finalFileName);

      // 构建OSS上传URL
      const uploadUrl = `${this.ossConfig.endpoint}/${this.ossConfig.bucketName}/${finalFileName}`;
      console.log('☁️ [OSS] 上传URL:', uploadUrl);

      // 创建HTTP请求
      const httpRequest = http.createHttp();
      
      // 构建请求头
      const headers: OSSHeaders = {
        'Content-Type': this.getContentType(filePath),
        'Content-Length': fileContent.length.toString(),
        'Authorization': this.generateOSSAuthorization('PUT', finalFileName, this.getContentType(filePath))
      };

      console.log('☁️ [OSS] 请求头:', headers);

      // 发送PUT请求上传文件
      const requestOptions: OSSHttpRequestOptions = {
        method: http.RequestMethod.PUT,
        header: headers,
        extraData: fileContent,
        readTimeout: 30000,
        connectTimeout: 30000
      };
      const response = await httpRequest.request(uploadUrl, requestOptions);

      httpRequest.destroy();

      console.log('☁️ [OSS] 上传响应状态码:', response.responseCode);
      console.log('☁️ [OSS] 上传响应头:', response.header);

      if (response.responseCode === 200) {
        // 构建访问URL
        const accessUrl = `https://${this.ossConfig.bucketName}.${this.ossConfig.endpoint.replace('https://', '')}/${finalFileName}`;
        console.log('☁️ [OSS] 上传成功，访问URL:', accessUrl);
        return accessUrl;
      } else {
        console.error('☁️ [OSS] 上传失败，状态码:', response.responseCode);
        console.error('☁️ [OSS] 响应内容:', response.result);
        throw new Error(`OSS上传失败，状态码: ${response.responseCode}`);
      }
    } catch (error) {
      console.error('☁️ [OSS] 上传图片到OSS失败:', error);
      throw new Error(`OSS上传失败: ${error.message || error}`);
    }
  }

  /**
   * 读取文件并转换为base64
   */
  private async readFileAsBase64(filePath: string): Promise<string> {
    try {
      console.log('📁 [OSS] 开始读取文件:', filePath);
      
      // 打开文件
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      console.log('📁 [OSS] 文件打开成功');

      // 获取文件大小
      const stat = fs.statSync(file.fd);
      console.log('📁 [OSS] 文件大小:', stat.size, '字节');

      if (stat.size === 0) {
        fs.closeSync(file);
        throw new Error('文件大小为0');
      }

      // 读取文件内容
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      console.log('📁 [OSS] 文件读取成功');

      // 关闭文件
      fs.closeSync(file);

      // 转换为base64
      const base64 = this.arrayBufferToBase64(buffer);
      console.log('📁 [OSS] base64转换完成，长度:', base64.length);

      return base64;
    } catch (error) {
      console.error('📁 [OSS] 读取文件失败:', error);
      throw new Error(`读取文件失败: ${error.message || error}`);
    }
  }

  /**
   * 生成文件名
   */
  private generateFileName(originalPath: string): string {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000);
    const extension = originalPath.split('.').pop() || 'jpg';
    return `avatars/${timestamp}_${random}.${extension}`;
  }

  /**
   * 获取文件MIME类型
   */
  private getContentType(filePath: string): string {
    const extension = filePath.split('.').pop()?.toLowerCase() || 'jpeg';
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /**
   * 生成OSS授权头
   */
  private generateOSSAuthorization(method: string, resource: string, contentType: string): string {
    // 这里需要实现OSS签名算法
    // 为了安全考虑，建议在服务端生成签名
    // 这里提供一个简化的示例
    const date = new Date().toUTCString();
    const stringToSign = `${method}\n\n${contentType}\n${date}\n/${this.ossConfig.bucketName}/${resource}`;
    
    // 注意：实际项目中应该使用服务端生成的签名
    // 这里只是示例，实际使用时需要调用后端API获取签名
    return `OSS ${this.ossConfig.accessKeyId}:${this.generateSignature(stringToSign)}`;
  }

  /**
   * 生成签名（简化版本，实际应该使用HMAC-SHA1）
   */
  private generateSignature(stringToSign: string): string {
    // 这里应该使用HMAC-SHA1算法
    // 为了简化，这里返回一个占位符
    // 实际项目中应该调用后端API获取签名
    return 'signature_placeholder';
  }

  /**
   * ArrayBuffer转base64
   */
  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const uint8Array = new Uint8Array(buffer);
    const base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    let result = '';

    for (let i = 0; i < uint8Array.length; i += 3) {
      const byte1 = uint8Array[i];
      const byte2 = i + 1 < uint8Array.length ? uint8Array[i + 1] : 0;
      const byte3 = i + 2 < uint8Array.length ? uint8Array[i + 2] : 0;

      const chunk1 = byte1 >> 2;
      const chunk2 = ((byte1 & 3) << 4) | (byte2 >> 4);
      const chunk3 = ((byte2 & 15) << 2) | (byte3 >> 6);
      const chunk4 = byte3 & 63;

      result += base64Chars.charAt(chunk1);
      result += base64Chars.charAt(chunk2);
      result += i + 1 < uint8Array.length ? base64Chars.charAt(chunk3) : '=';
      result += i + 2 < uint8Array.length ? base64Chars.charAt(chunk4) : '=';
    }

    return result;
  }

  /**
   * 通过后端API上传到OSS（推荐方式）
   */
  async uploadImageViaBackend(filePath: string, userId: string): Promise<string> {
    try {
      console.log('☁️ [OSS] 通过后端API上传图片');
      console.log('☁️ [OSS] 文件路径:', filePath);
      console.log('☁️ [OSS] 用户ID:', userId);

      // 读取文件内容
      const fileContent = await this.readFileAsBase64(filePath);
      console.log('☁️ [OSS] 文件读取成功，大小:', fileContent.length, '字符');

      // 构建请求数据 - 使用B目录中稳定运行的格式
      const requestData: OSSRequestData = {
        userId: userId,
        imageData: fileContent,
        fileName: this.generateFileName(filePath)
      };

      console.log('☁️ [OSS] 请求数据格式:', JSON.stringify({
        userId: userId,
        imageData: fileContent.substring(0, 100) + '...', // 只显示前100个字符用于调试
        fileName: this.generateFileName(filePath)
      }));

      // 调用后端API - 使用B目录中的端点
      const httpRequest = http.createHttp();
      const backendHeader: OSSBackendHeader = {
        'Content-Type': 'application/json'
      };
      const backendRequestOptions: OSSBackendRequestOptions = {
        method: http.RequestMethod.POST,
        header: backendHeader,
        extraData: JSON.stringify(requestData),
        readTimeout: 30000,
        connectTimeout: 30000
      };
      const response = await httpRequest.request(`${Config.getApiBaseUrl()}/api/oss/upload`, backendRequestOptions);

      httpRequest.destroy();

      console.log('☁️ [OSS] 后端API响应状态码:', response.responseCode);

      if (response.responseCode === 200) {
        const resultString: string = response.result as string;
        const result: BackendOSSResponse = JSON.parse(resultString);
        console.log('☁️ [OSS] 后端响应:', resultString);
        console.log('☁️ [OSS] 解析后的响应:', result);
        
        // B目录中的响应格式：result.data.ossUrl
        if (result.success && result.data && result.data.ossUrl) {
          console.log('☁️ [OSS] 上传成功，OSS URL:', result.data.ossUrl);
          return result.data.ossUrl;
        } else {
          console.error('☁️ [OSS] 后端返回失败:', result.message);
          throw new Error(`后端返回失败: ${result.message}`);
        }
      } else {
        console.error('☁️ [OSS] 后端API上传失败，状态码:', response.responseCode);
        console.error('☁️ [OSS] 响应内容:', response.result);
        throw new Error(`后端API上传失败，状态码: ${response.responseCode}`);
      }
    } catch (error) {
      console.error('☁️ [OSS] 通过后端API上传失败:', error);
      throw new Error(`后端API上传失败: ${error.message || error}`);
    }
  }
} 