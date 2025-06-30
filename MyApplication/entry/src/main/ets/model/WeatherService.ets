import http from '@ohos.net.http';

class CityInfo {
  city: string = '';
}

class Forecast {
  type: string = '';
  high: string = '';
  low: string = '';
}

class Yesterday {
  date: string = '';
  high: string = '';
  low: string = '';
  fx: string = '';
  fl: string = '';
  type: string = '';
  notice: string = '';
}

class Today {
  date: string = '';
  high: string = '';
  low: string = '';
  fx: string = '';
  fl: string = '';
  type: string = '';
  notice: string = '';
}

class DataInfo {
  shidu: string = '';
  pm25: number = 0;
  pm10: number = 0;
  quality: string = '';
  wendu: string = '';
  ganmao: string = '';
  forecast: Forecast[] = [];
  yesterday?: Yesterday;
  today?: Today;
}

class SojsonWeatherResponse {
  cityInfo?: CityInfo;
  data?: DataInfo;
  status?: number;
  message?: string;
  time?: string;
}

export async function fetchWeather(cityCode: string): Promise<SojsonWeatherResponse|null> {
  const httpRequest = http.createHttp();
  const url = `http://t.weather.sojson.com/api/weather/city/${cityCode}`;

  try {
    const response = await httpRequest.request(url, {
      method: http.RequestMethod.GET,
      header: {
        'Content-Type': 'application/json'
      },
      connectTimeout: 10000,
      readTimeout: 10000
    });

    if (response.responseCode === 200 && typeof response.result === 'string') {
      const data = JSON.parse(response.result) as SojsonWeatherResponse;
      console.log('sojson天气API返回:', JSON.stringify(data));
      return data;
    } else {
      console.error('请求失败，状态码：', response.responseCode, '内容：', response.result);
      return null;
    }
  } catch (error) {
    console.error('网络请求异常：', JSON.stringify(error));
    return null;
  } finally {
    httpRequest.destroy();
  }
}