from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from pydantic import BaseModel, validator
import json
import requests
import phonenumbers
from phonenumbers import carrier, geocoder, timezone
from typing import Dict, Any, List
import uvicorn
import time
from collections import defaultdict
import asyncio
from functools import wraps
import re

app = FastAPI(
    title="GhostTrack API",
    description="OSINT工具API - IP追踪、手机号码追踪、用户名追踪",
    version="2.0.0"
)

# 简单的内存限流器
class RateLimiter:
    def __init__(self):
        self.requests = defaultdict(list)
        self.max_requests = 10  # 每分钟最大请求数
        self.window = 60  # 时间窗口(秒)
    
    def is_allowed(self, client_ip: str) -> bool:
        now = time.time()
        # 清理过期请求
        self.requests[client_ip] = [
            req_time for req_time in self.requests[client_ip] 
            if now - req_time < self.window
        ]
        
        # 检查是否超过限制
        if len(self.requests[client_ip]) >= self.max_requests:
            return False
        
        # 记录新请求
        self.requests[client_ip].append(now)
        return True

rate_limiter = RateLimiter()

# 限流中间件
@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    client_ip = request.client.host
    
    # 跳过健康检查和根路径
    if request.url.path in ["/", "/health"]:
        response = await call_next(request)
        return response
    
    if not rate_limiter.is_allowed(client_ip):
        raise HTTPException(
            status_code=429, 
            detail="请求过于频繁，请稍后再试"
        )
    
    response = await call_next(request)
    return response

# 添加CORS中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应该限制具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 数据模型
class IPTrackRequest(BaseModel):
    ip_address: str
    
    @validator('ip_address')
    def validate_ip(cls, v):
        if not v or len(v.strip()) == 0:
            raise ValueError('IP地址不能为空')
        
        ip = v.strip()
        # 简单的IP格式验证
        ip_pattern = re.compile(
            r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
            r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        )
        
        if not ip_pattern.match(ip):
            raise ValueError('无效的IP地址格式')
        
        # 防止内网IP和特殊IP的查询
        parts = ip.split('.')
        first_octet = int(parts[0])
        second_octet = int(parts[1])
        
        # 私有IP地址范围
        if (
            first_octet == 10 or
            (first_octet == 172 and 16 <= second_octet <= 31) or
            (first_octet == 192 and second_octet == 168) or
            first_octet == 127 or
            first_octet == 0 or
            first_octet >= 224
        ):
            raise ValueError('不支持查询私有IP、内网IP或特殊IP地址')
        
        return ip

class PhoneTrackRequest(BaseModel):
    phone_number: str
    
    @validator('phone_number')
    def validate_phone(cls, v):
        if not v or len(v.strip()) == 0:
            raise ValueError('手机号码不能为空')
        
        phone = v.strip()
        # 限制手机号码长度
        if len(phone) > 20:
            raise ValueError('手机号码过长')
        
        # 基本格式验证：必须以+开头，后面只能是数字
        if not re.match(r'^\+[1-9]\d{1,14}$', phone):
            raise ValueError('手机号码格式错误，请使用国际格式（以+开头）')
        
        return phone

class UsernameTrackRequest(BaseModel):
    username: str
    
    @validator('username')
    def validate_username(cls, v):
        if not v or len(v.strip()) == 0:
            raise ValueError('用户名不能为空')
        
        username = v.strip()
        
        if len(username) > 50:
            raise ValueError('用户名过长')
        
        # 用户名基本安全验证：只允许字母、数字、下划线、连字符和点
        if not re.match(r'^[a-zA-Z0-9._-]+$', username):
            raise ValueError('用户名只能包含字母、数字、下划线、连字符和点')
        
        return username

# API路由
@app.get("/")
async def root():
    return {"message": "GhostTrack API v2.0", "status": "running"}

@app.get("/health")
async def health_check():
    """API健康检查"""
    return {
        "status": "healthy", 
        "timestamp": time.time(),
        "version": "2.0.0"
    }

@app.get("/api/my-ip")
async def get_my_ip():
    """获取当前服务器的公网IP"""
    try:
        response = requests.get('https://api.ipify.org/', timeout=10)
        response.raise_for_status()
        ip_address = response.text.strip()
        return {"ip": ip_address, "success": True}
    except requests.RequestException as e:
        raise HTTPException(status_code=500, detail=f"获取IP失败: {str(e)}")

@app.post("/api/track-ip")
async def track_ip(request: IPTrackRequest):
    """IP地址追踪"""
    try:
        # 调用ipwho.is API
        api_url = f"http://ipwho.is/{request.ip_address}"
        response = requests.get(api_url, timeout=15)
        response.raise_for_status()
        
        ip_data = response.json()
        
        # 检查API返回是否成功
        if not ip_data.get('success', True):
            raise HTTPException(status_code=400, detail="无效的IP地址")
        
        # 处理地理坐标
        lat = ip_data.get('latitude', 0)
        lon = ip_data.get('longitude', 0)
        maps_url = f"https://www.google.com/maps/@{lat},{lon},8z" if lat and lon else None
        
        result = {
            "ip": request.ip_address,
            "type": ip_data.get("type"),
            "country": ip_data.get("country"),
            "country_code": ip_data.get("country_code"),
            "city": ip_data.get("city"),
            "continent": ip_data.get("continent"),
            "continent_code": ip_data.get("continent_code"),
            "region": ip_data.get("region"),
            "region_code": ip_data.get("region_code"),
            "latitude": lat,
            "longitude": lon,
            "maps_url": maps_url,
            "is_eu": ip_data.get("is_eu"),
            "postal": ip_data.get("postal"),
            "calling_code": ip_data.get("calling_code"),
            "capital": ip_data.get("capital"),
            "borders": ip_data.get("borders"),
            "flag": ip_data.get("flag", {}).get("emoji"),
            "connection": {
                "asn": ip_data.get("connection", {}).get("asn"),
                "org": ip_data.get("connection", {}).get("org"),
                "isp": ip_data.get("connection", {}).get("isp"),
                "domain": ip_data.get("connection", {}).get("domain")
            },
            "timezone": {
                "id": ip_data.get("timezone", {}).get("id"),
                "abbr": ip_data.get("timezone", {}).get("abbr"),
                "is_dst": ip_data.get("timezone", {}).get("is_dst"),
                "offset": ip_data.get("timezone", {}).get("offset"),
                "utc": ip_data.get("timezone", {}).get("utc"),
                "current_time": ip_data.get("timezone", {}).get("current_time")
            },
            "success": True
        }
        
        return result
        
    except requests.RequestException as e:
        raise HTTPException(status_code=500, detail=f"API请求失败: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"处理失败: {str(e)}")

@app.post("/api/track-phone")
async def track_phone(request: PhoneTrackRequest):
    """手机号码追踪"""
    try:
        default_region = "ID"  # 默认印尼地区
        
        # 解析手机号码
        parsed_number = phonenumbers.parse(request.phone_number, default_region)
        
        # 获取各种信息
        region_code = phonenumbers.region_code_for_number(parsed_number)
        carrier_name = carrier.name_for_number(parsed_number, "en")
        location = geocoder.description_for_number(parsed_number, "id")
        is_valid = phonenumbers.is_valid_number(parsed_number)
        is_possible = phonenumbers.is_possible_number(parsed_number)
        
        # 格式化号码
        international_format = phonenumbers.format_number(
            parsed_number, phonenumbers.PhoneNumberFormat.INTERNATIONAL
        )
        e164_format = phonenumbers.format_number(
            parsed_number, phonenumbers.PhoneNumberFormat.E164
        )
        mobile_format = phonenumbers.format_number_for_mobile_dialing(
            parsed_number, default_region, with_formatting=True
        )
        
        # 号码类型
        number_type = phonenumbers.number_type(parsed_number)
        type_description = "未知类型"
        if number_type == phonenumbers.PhoneNumberType.MOBILE:
            type_description = "手机号码"
        elif number_type == phonenumbers.PhoneNumberType.FIXED_LINE:
            type_description = "固定电话"
        
        # 时区信息
        timezones = timezone.time_zones_for_number(parsed_number)
        timezone_str = ', '.join(timezones) if timezones else "未知"
        
        result = {
            "phone_number": request.phone_number,
            "location": location,
            "region_code": region_code,
            "timezone": timezone_str,
            "carrier": carrier_name,
            "is_valid": is_valid,
            "is_possible": is_possible,
            "international_format": international_format,
            "e164_format": e164_format,
            "mobile_format": mobile_format,
            "national_number": str(parsed_number.national_number),
            "country_code": parsed_number.country_code,
            "type": type_description,
            "success": True
        }
        
        return result
        
    except phonenumbers.NumberParseException as e:
        raise HTTPException(status_code=400, detail=f"手机号码格式错误: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"处理失败: {str(e)}")

@app.post("/api/track-username")
async def track_username(request: UsernameTrackRequest):
    """用户名追踪"""
    try:
        username = request.username
        results = {}
        
        # 社交媒体平台列表
        social_media = [
            {"url": "https://www.facebook.com/{}", "name": "Facebook"},
            {"url": "https://www.twitter.com/{}", "name": "Twitter"},
            {"url": "https://www.instagram.com/{}", "name": "Instagram"},
            {"url": "https://www.linkedin.com/in/{}", "name": "LinkedIn"},
            {"url": "https://www.github.com/{}", "name": "GitHub"},
            {"url": "https://www.pinterest.com/{}", "name": "Pinterest"},
            {"url": "https://www.tumblr.com/{}", "name": "Tumblr"},
            {"url": "https://www.youtube.com/{}", "name": "Youtube"},
            {"url": "https://soundcloud.com/{}", "name": "SoundCloud"},
            {"url": "https://www.snapchat.com/add/{}", "name": "Snapchat"},
            {"url": "https://www.tiktok.com/@{}", "name": "TikTok"},
            {"url": "https://www.behance.net/{}", "name": "Behance"},
            {"url": "https://www.medium.com/@{}", "name": "Medium"},
            {"url": "https://www.quora.com/profile/{}", "name": "Quora"},
            {"url": "https://www.flickr.com/people/{}", "name": "Flickr"},
            {"url": "https://www.twitch.tv/{}", "name": "Twitch"},
            {"url": "https://www.dribbble.com/{}", "name": "Dribbble"},
            {"url": "https://www.telegram.me/{}", "name": "Telegram"}
        ]
        
        found_profiles = []
        not_found_profiles = []
        
        for site in social_media:
            try:
                url = site['url'].format(username)
                response = requests.get(url, timeout=5, allow_redirects=True)
                
                if response.status_code == 200:
                    found_profiles.append({
                        "platform": site['name'],
                        "url": url,
                        "status": "found"
                    })
                else:
                    not_found_profiles.append({
                        "platform": site['name'],
                        "url": url,
                        "status": "not_found"
                    })
                    
            except requests.RequestException:
                not_found_profiles.append({
                    "platform": site['name'],
                    "url": site['url'].format(username),
                    "status": "error"
                })
        
        result = {
            "username": username,
            "found_count": len(found_profiles),
            "total_searched": len(social_media),
            "found_profiles": found_profiles,
            "not_found_profiles": not_found_profiles,
            "success": True
        }
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"处理失败: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)