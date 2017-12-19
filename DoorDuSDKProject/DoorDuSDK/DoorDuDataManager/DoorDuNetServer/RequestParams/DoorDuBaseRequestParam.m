//
//  DoorDuBaseRequestParam.m
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuBaseRequestParam.h"
#import "DoorDuAFNetworking.h"
#import "DoorDuGlobleConfig.h"

@implementation DoorDuBaseRequestParam

- (id)init
{
    self = [super init];
    if (self)
    {
        _domain = [DoorDuGlobleConfig sharedInstance].httpUrlStr;
        _path = [self buildRequestPath];
    }
    return self;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        _domain = [DoorDuGlobleConfig sharedInstance].httpUrlStr;
        _path = path;
    }
    return self;
}

- (DoorDuBaseRequestParam *)initWithDomain:(NSString *)domain path:(NSString *)path
{
    self = [super init];
    if (self)
    {
        _domain = domain;
        if (!path || path.length == 0) {
            _path = [self buildRequestPath];
        }else {
            _path = path;
        }
    }
    return self;
}

- (NSString *)buildRequestPath
{
    return nil;
}

- (DoorDuResponseDataType)buildResponseType
{
    return DoorDuResponseTypeJson;
}

- (DoorDuRequestMethod)buildRequestMethod
{
    return DoorDuRequestTypeGet;
}

- (DoorDuRequestType)buildRequestType
{
    return DoorDuRequestTypeData;
}

- (float)buildRequestTimeout
{
    return DoorDuHttpsRequestTimeOut;
}

- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    return dic;
}

@end
