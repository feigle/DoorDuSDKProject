//
//  DoorDuAudioPlayer.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - DoorDuAudioPlayer
@interface DoorDuAudioPlayer : NSObject

/*!
 * @method  sharedInstance
 * @brief   获取单例.
 * @return  instancetype.
 */
+ (instancetype)sharedInstance;

/*!
 * @method  playAudioFileWithPath:looping:
 * @brief   播放指定路径的语音文件.
 * @param   path    语音文件的绝对路径.
 * @param   looping 是否重复播放.
 */
- (void)playAudioFileWithPath:(NSString *)path looping:(BOOL)looping;

/*!
 * @method  playVibrate:
 * @brief   播放振动.
 * @param   looping 是否重复播放.
 */
- (void)playVibrate:(BOOL)looping;

/*!
 * @method  stopPlayAudioAndVibrate
 * @brief   停止播放语音文件和振动.
 */
- (void)stopPlayAudioAndVibrate;

/*!
 * @method  playIncomingAudio
 * @brief   播放来电铃声.
 * @param   looping 是否重复播放.
 */
- (void)playIncomingAudio:(BOOL)looping;

/*!
 * @method  playOutgoingAudio
 * @brief   播放呼出铃声.
 * @param   looping 是否重复播放.
 */
- (void)playOutgoingAudio:(BOOL)looping;

/*!
 * @method  playMessageAudio
 * @brief   播放信息铃声.
 * @param   looping 是否重复播放.
 */
- (void)playMessageAudio:(BOOL)looping;

/*!
 * @method  playButtonAudio
 * @brief   播放按键铃声.
 * @param   looping 是否重复播放.
 */
- (void)playButtonAudio:(BOOL)looping;

/*!
 * @method  playBusyAudio
 * @brief   播放正忙铃声.
 * @param   looping 是否重复播放.
 */
- (void)playBusyAudio:(BOOL)looping;

- (void)playDoorisBusyAudio:(BOOL)looping;

@end
