//
//  DoorDuBaseRequestParam.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DoorDuResponseDataType)
{
    DoorDuResponseTypeJson = 0,      //  json
    DoorDuResponseTypeXml = 1,       //  xml
    DoorDuResponseTypeImage = 2,     //  image
};

typedef NS_ENUM(NSUInteger, DoorDuRequestType) {
    DoorDuRequestTypeData = 0,      // 获取数据
    DoorDuRequestTypeDownload = 1,  // 下载 （暂不支持）
    DoorDuRequestTypeUpload = 2     // 上传（暂不支持）
};

typedef NS_ENUM(NSUInteger, DoorDuRequestMethod)
{
    DoorDuRequestTypeGet = 0,
    DoorDuRequestTypePost = 1,
    DoorDuRequestTypePut = 2,
};

#define DoorDuHttpsRequestTimeOut 15.0


/**
 请求参数基础类
 */
@interface DoorDuBaseRequestParam : NSObject

@property (nonatomic,copy) NSString *domain;
@property (nonatomic,copy) NSString *path;

- (DoorDuBaseRequestParam *)initWithDomain:(NSString *)domain path:(NSString *)path;

/**
 构建路径，用于之类重载
 @return 返回请求path   如：v/version
 */
- (NSString *)buildRequestPath;

/**
 构建请求方法（默认GET方法，修改请求方法需要重载方法），用于子类重载
 @return 返回请求方法
 */
- (DoorDuRequestMethod)buildRequestMethod;

/**
 构建请求类型（获取数据，上传，下载，暂时只支持获取数据），用于子类重载
 @return 返回请求类型
 */
- (DoorDuRequestType)buildRequestType;

/**
 构建响应类型（json，xml，image，默认json数据），用于子类重载
 @return 返回响应类型
 */
- (DoorDuResponseDataType)buildResponseType;

/**
 构建响应超时时间（默认25.0s），用于子类重载
 @return 返回请求超时时间
 */
- (float)buildRequestTimeout;

/**
 构建请求参数，用于子类重载
 @return 返回请求参数
 */
- (NSMutableDictionary *)buildRequestParam;

@end
