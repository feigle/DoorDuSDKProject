//
//  DoorDuBaseResponse.h
//  DoorDuSDK
//
//  Created by feigle on 2017/3/8.
//  Copyright © 2017年 DoorDu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoorDuBaseModel : NSObject<NSCopying>

- (id)initWithDictionary:(NSDictionary*)jsonDic;

@end


/**
 DoorDuBaseResponse为数据模型基础类
 */
@interface DoorDuBaseResponse : DoorDuBaseModel

/**
 业务数据类型，必须为DoorDuBaseModel的子类
 */
@property (nonatomic,strong) id bodyType;

/**
 保存业务数据容器
 */
@property (nonatomic,strong) NSMutableArray *body;

/**
 状态码，默认值为-1
 */
@property (nonatomic,assign) NSInteger code;

/**
 状态码，描述
 */
@property (nonatomic,strong) NSString *message;


/**
 用于实例化数据对象

 @param jsonDic 数据字典内容
 @param bodyType 业务数据类型
 @return 返回实例化业务对象
 */
- (id)initWithDictionary:(NSDictionary*)jsonDic bodyType:(Class)bodyType;

@end
