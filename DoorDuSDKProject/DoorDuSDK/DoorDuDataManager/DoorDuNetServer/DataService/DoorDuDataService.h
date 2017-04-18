//
//  DataService.h
//  DataApi
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuBaseRequestParam.h"

@interface DoorDuDataService : NSObject

/**
 请求头通用参数
 */
@property (nonatomic,strong) NSDictionary *requestHeaderParams;

+ (instancetype)services;

- (NSURLSessionDataTask *)getDoorDuSDKData:(DoorDuBaseRequestParam *)param success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)cancelAllTask;

@end
