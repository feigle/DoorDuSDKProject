//
//  DoorDuCommonTypes.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/NSObject.h>
#import <CommonCrypto/CommonCrypto.h>

#pragma mark - DoorDuCommonTypes
@interface DoorDuCommonTypes : NSObject

/*!
 * @method  gainDeviceVersion
 * @brief   获取设备版本.
 * @return  设备版本.
 */
+ (NSString *)gainDeviceVersion;

/*!
 * @method  gainPlatformString
 * @brief   获取平台版本.
 * @return  平台版本.
 */
+ (NSString *)gainPlatformString;

/*!
 * @method  AES128EncryptWithString
 * @brief   AES128加密.
 CBC模式，No padding.
 * @param   string  需要加密的字符串.
 * @param   key     16位长度的字符串.
 * @param   iv      16位长度的字符串.
 * @return  加密后的NSString.
 */
+ (NSString *)AES128EncryptWithString:(NSString *)string
                                  key:(NSString *)key
                                   iv:(NSString *)iv;



/*!
 * @method  AES128DecryptWithString
 * @brief   AES128解密.
 CBC模式，No padding.
 * @param   string  需要解密的字符串.
 * @param   key     16位长度的字符串.
 * @param   iv      16位长度的字符串.
 * @return  解密后的NSString.
 */
+ (NSString *)AES128DecryptWithString:(NSString *)string
                                  key:(NSString *)key
                                   iv:(NSString *)iv;

/*!
 * @method  md5Crypt16WithString
 * @brief   NSString的md5-16位加密.
 * @param   string  需要md5的字符串.
 * @return  md5后的NSString.
 */
+ (NSString *)md5Crypt16WithString:(NSString *)string;

/*!
 * @method  md5Crypt16WithData
 * @brief   NSData的md5-16位加密.
 * @param   data    需要md5的NSData.
 * @return  md5后的NSString.
 */
+ (NSString *)md5Crypt16WithData:(NSData *)data;

@end
