//
//  DoorDuBaseResponse.m
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuBaseResponse.h"
#import "DoorDuError.h"
#import "DoorDuLog.h"

@implementation DoorDuBaseModel

- (id)initWithDictionary:(NSDictionary*)jsonDic
{
    if ((self = [super init]))
    {
        [self setValuesForKeysWithDictionary:jsonDic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    DoorDuLogVerbose(@"Undefined Key:%@ in %@",key,[self class]);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)    {
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


@end

@implementation DoorDuBaseResponse

- (id)initWithDictionary:(NSDictionary*)jsonDic bodyType:(Class)bodyType
{
    if ((self = [super init]))
    {
        if (!jsonDic || ![jsonDic isKindOfClass:[NSDictionary class]]) {
            // json数据格式不正确，返回500
            self.code = 500;
            self.message = @"数据格式错误";
        }else {
            _bodyType = bodyType;
            [self setValuesForKeysWithDictionary:jsonDic];
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"code"])
    {
        if ([value isKindOfClass:[NSNumber class]]) {
            self.code = [value integerValue];
        }else {
            // 用于表示初始化值
            self.code = -1;
        }
    }else if ([key isEqualToString:@"message"]) {
        self.message = value;
    }else if ([key isEqualToString:@"data"] && self.bodyType){
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([value isKindOfClass:[NSArray class]]) {
            
            for (NSMutableDictionary *dic in value)
            {
                [array addObject:[[self.bodyType alloc] initWithDictionary:dic]];
            }

        }else if ([value isKindOfClass:[NSDictionary class]]) {
            
            [array addObject:[[self.bodyType alloc] initWithDictionary:value]];
        }
        self.body = array;
    }
    else {
        [super setValue:value forKey:key];
    }
}

@end
