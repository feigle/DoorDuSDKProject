//
//  DoorDuSDKRequestServices.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuBaseRequestParam.h"
#import "DoorDuError.h"
#import "DoorDuBaseResponse.h"

@interface DoorDuNetServices : NSObject

/*! @brief 网络对外接口，通过param获取指定业务参数
 *
 * @param      param      请求业务参数
 * @param      bodyType   返回对象业务类型(如无返回类型，传nil)
 * @param      success    成功回调函数
 * @param      failure    失败回调函数
 * @result 当前网络请求任务
 */
+ (NSURLSessionDataTask *)getDoorDuSDKData:(DoorDuBaseRequestParam *)param
                                  bodyType:(Class)bodyType
                                   success:(void (^)(DoorDuBaseResponse *responseObj))success
                                   failure:(void (^)(DoorDuError *error))failure;

/**
 配置请求同通用参数

 @param requestHeaderParams 通用参数
 */
+ (void)configCommonRequestHearderParams:(NSDictionary *)requestHeaderParams;

/**
 取消当前所有网络任务
 */
+ (void)cancelAllTask;

@end










