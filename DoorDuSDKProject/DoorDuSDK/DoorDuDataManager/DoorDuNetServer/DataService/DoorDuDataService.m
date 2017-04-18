//
//  DataService.m
//  DataApi
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuDataService.h"
#import "DoorDuAFNetworking.h"

static DoorDuDataService *doorDutDataInstance = nil;

@interface DoorDuDataService ()

@property (nonatomic,strong,readonly) DoorDuAFHTTPSessionManager *sessionManager;

@end

@implementation DoorDuDataService

+ (instancetype)services
{
    if (doorDutDataInstance == nil) {
        
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            doorDutDataInstance = [[DoorDuDataService alloc] init];
        });
    }
    
    return doorDutDataInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        _sessionManager = [DoorDuAFHTTPSessionManager manager];
    }
    return self;
}

- (void)cancelAllTask
{
    [_sessionManager invalidateSessionCancelingTasks:YES];
}

- (NSURLSessionDataTask *)getDoorDuSDKData:(DoorDuBaseRequestParam *)param success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task = nil;
//    DoorDuRequestType requestType = [param buildRequestType];
    //设置响应序列
    DoorDuResponseDataType responseType = [param buildResponseType];
    DoorDuAFHTTPResponseSerializer *responseSerializer = [self reponseSerializerWithType:responseType];
    _sessionManager.responseSerializer = responseSerializer;
    
    //获取请求头部通用参数
    DoorDuAFHTTPRequestSerializer *requestSerializer = [self requestSerializer];
    
    //设置请求超时时间
    CGFloat requestTimeout = [param buildRequestTimeout];
    _sessionManager.requestSerializer.timeoutInterval = requestTimeout;
    
    DoorDuRequestMethod method = [param buildRequestMethod];
    NSString *urlPath = [NSString stringWithFormat:@"%@%@",[param domain],[param buildRequestPath]];
    NSDictionary *params = [param buildRequestParam];
    switch (method) {
        case DoorDuRequestTypeGet:
            task = [self GET:urlPath parameters:params success:success failure:failure];
            break;
        case DoorDuRequestTypePost:
            task = [self POST:urlPath parameters:params success:success failure:failure];
            break;
        case DoorDuRequestTypePut:
            task = [self PUT:urlPath parameters:params success:success failure:failure];
            break;
        default:
            task = [self GET:urlPath parameters:params success:success failure:failure];    //默认GET请求
            break;
    }
    
    return task;
}

/*配置http请求序列化*/
- (DoorDuAFHTTPRequestSerializer *)requestSerializer
{
    DoorDuAFHTTPRequestSerializer *requestSerializer = [DoorDuAFHTTPRequestSerializer serializer];
    
    [self.requestHeaderParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

        [requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    
    return requestSerializer;
}

/**配置http响应序列化**/
- (DoorDuAFHTTPResponseSerializer *)reponseSerializerWithType:(DoorDuResponseDataType)type
{
    DoorDuAFHTTPResponseSerializer *responseSerializer = nil;
    switch (type) {
        case DoorDuResponseTypeJson:
            responseSerializer = [DoorDuAFJSONResponseSerializer serializer];
            break;
        case DoorDuResponseTypeXml:
            responseSerializer = [DoorDuAFXMLParserResponseSerializer serializer];
            break;
        case DoorDuResponseTypeImage:
            responseSerializer = [DoorDuAFImageResponseSerializer serializer];
            break;
        default:
            responseSerializer = [DoorDuAFJSONResponseSerializer serializer];
            break;
    }
    
    //设置返回状态码区间[0, 600]
    responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 600)];
    return responseSerializer;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
 parameters:(nullable id)parameters
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task = [_sessionManager GET:URLString parameters:parameters progress:nil success:success failure:failure];
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
 parameters:(nullable id)parameters
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task = [_sessionManager POST:URLString parameters:parameters progress:nil success:success failure:failure];
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
    parameters:(nullable id)parameters
       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task = [_sessionManager PUT:URLString parameters:parameters success:success failure:failure];
    [task resume];
    
    return task;
}


@end
