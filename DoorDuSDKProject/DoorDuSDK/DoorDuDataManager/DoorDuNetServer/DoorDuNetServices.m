//
//  DoorDuSDKRequestServices.m
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuNetServices.h"
#import "DoorDuDataService.h"
#import "DoorDuError.h"
#import <UIKit/UIImage.h>

@implementation DoorDuNetServices

+ (NSURLSessionDataTask *)getDoorDuSDKData:(DoorDuBaseRequestParam *)param
                                  bodyType:(Class)bodyType
                                   success:(void (^)(DoorDuBaseResponse *object))success
                                   failure:(void (^)(DoorDuError *error))failure
{
    
    NSURLSessionDataTask *task = [[DoorDuDataService services] getDoorDuSDKData:param success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)task.response;
        if (success) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                DoorDuBaseResponse *response = [[DoorDuBaseResponse alloc] initWithDictionary:responseObject bodyType:bodyType];
                
                //状态码如果为200，表示正常返回数据
                if (httpResponse.statusCode == DoorDuErrorCodeReqSuccess) {
                    response.code = 200;
                    success(response);
                }else {
                    //错误状态码
                    DoorDuError *err = [DoorDuError new];
                    //小于0为初始化值
                    err.message = response.message;
                    err.errorCode = ((response.code < 0) ? httpResponse.statusCode : response.code);
                    if (failure) {
                        failure(err);
                    }
                }
            }else if ([responseObject isKindOfClass:[UIImage class]]) {
                
                DoorDuBaseResponse *response = [DoorDuBaseResponse new];
                response.code = 200;
                response.message = @"获取图片成功";
                response.body = [NSMutableArray array];
                [response.body addObject:responseObject];
                success(response);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSInteger code = error.code;
        DoorDuError *err = [DoorDuError new];
        err.errorCode = ((code > 0) ? code : error.code);
        
        if (failure) {
            failure(err);
        }
    }];
    
    return task;
}

+ (void)configCommonRequestHearderParams:(NSDictionary *)requestHeaderParams
{
    [DoorDuDataService services].requestHeaderParams = requestHeaderParams;
}

+ (void)cancelAllTask
{
    [[DoorDuDataService services] cancelAllTask];
}

@end
