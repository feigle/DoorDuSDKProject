//
//  DoorDuAudioPlayer.m
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuAudioPlayer.h"
#import "DoorDuCommonHeader.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>

//资源路径常量
static NSString *const kDoorDuAudioPlayerBundleName     = @"DoorDuSDK.bundle";
static NSString *const kDoorDuAudioPlayerAudioDirName   = @"audio";

//静态单例变量
static DoorDuAudioPlayer *theDoorDuAudioPlayer = nil;

#pragma mark - DoorDuAudioPlayer
@interface DoorDuAudioPlayer () {
    
    AVAudioPlayer *_audioPlayer;//语音播放器
    NSTimer *_vibrateTimer;//振动定时器
}

@end

@implementation DoorDuAudioPlayer

#pragma mark -
#pragma mark (获取单例)
+ (instancetype)sharedInstance {
    
    @synchronized (theDoorDuAudioPlayer) {
        
        if (!theDoorDuAudioPlayer) {
            
            theDoorDuAudioPlayer = [[DoorDuAudioPlayer alloc] init];
        }
        
        return theDoorDuAudioPlayer;
    }
}

#pragma mark -
#pragma mark (构造)
- (id)init {
    
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

#pragma mark -
#pragma mark (析构)
- (void)dealloc {
    
    _audioPlayer = nil;
    
    if (_vibrateTimer) {
        
        [_vibrateTimer invalidate];
        _vibrateTimer = nil;
    }
}

#pragma mark -
#pragma mark (播放指定路径的语音文件)
- (void)playAudioFileWithPath:(NSString *)path looping:(BOOL)looping {
    
    if (!path
        || [path isEqualToString:@""]
        || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        return;
    }
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    if (theDoorDuAudioPlayer->_audioPlayer) {
        
        [theDoorDuAudioPlayer->_audioPlayer stop];
        theDoorDuAudioPlayer->_audioPlayer = nil;
    }
    
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    theDoorDuAudioPlayer->_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (theDoorDuAudioPlayer->_audioPlayer && !error) {
        
        /*
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:nil];*/
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        if (looping) {
            
            [theDoorDuAudioPlayer->_audioPlayer setNumberOfLoops:10];
            
        }else {
            
            [theDoorDuAudioPlayer->_audioPlayer setNumberOfLoops:0];
        }
        
        [theDoorDuAudioPlayer->_audioPlayer setVolume:1.0];
        [theDoorDuAudioPlayer->_audioPlayer setMeteringEnabled:YES];
        [theDoorDuAudioPlayer->_audioPlayer prepareToPlay];
        [theDoorDuAudioPlayer->_audioPlayer play];
    }
}

#pragma mark -
#pragma mark (播放振动)
- (void)playVibrate:(BOOL)looping {
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    if (theDoorDuAudioPlayer->_vibrateTimer) {
        
        [theDoorDuAudioPlayer->_vibrateTimer invalidate];
        theDoorDuAudioPlayer->_vibrateTimer = nil;
    }
    
    theDoorDuAudioPlayer->_vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                                           target:theDoorDuAudioPlayer
                                                                         selector:@selector(playVibrate)
                                                                         userInfo:nil
                                                                          repeats:looping];
    [theDoorDuAudioPlayer->_vibrateTimer fire];
}

#pragma mark -
#pragma mark (播放一次振动)
- (void)playVibrate {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark -
#pragma mark (停止播放语音文件和振动)
- (void)stopPlayAudioAndVibrate {
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:theDoorDuAudioPlayer];
    
    if (theDoorDuAudioPlayer->_vibrateTimer) {
        
        [theDoorDuAudioPlayer->_vibrateTimer invalidate];
        theDoorDuAudioPlayer->_vibrateTimer = nil;
    }
    
    if(theDoorDuAudioPlayer->_audioPlayer && theDoorDuAudioPlayer->_audioPlayer.playing) {
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:nil];
        
        [theDoorDuAudioPlayer->_audioPlayer stop];
    }
}

#pragma mark -
#pragma mark (播放来电铃声)
- (void)playIncomingAudio:(BOOL)looping {
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    //根据音频文件名称，在DoorDuSDK.bundle/audio目录下寻找音频文件
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *audioDirPath = [[resourcePath stringByAppendingPathComponent:kDoorDuAudioPlayerBundleName] stringByAppendingPathComponent:kDoorDuAudioPlayerAudioDirName];
    NSString *audioFilePath = [audioDirPath stringByAppendingPathComponent:DOORDU_INCOMING_AUDIO];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {

        return;
    }
    
    //播放
    [theDoorDuAudioPlayer playAudioFileWithPath:audioFilePath looping:looping];
}

#pragma mark -
#pragma mark (播放呼出铃声)
- (void)playOutgoingAudio:(BOOL)looping {
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    //根据音频文件名称，在DoorDuSDK.bundle/audio目录下寻找音频文件
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *audioDirPath = [[resourcePath stringByAppendingPathComponent:kDoorDuAudioPlayerBundleName] stringByAppendingPathComponent:kDoorDuAudioPlayerAudioDirName];
    NSString *audioFilePath = [audioDirPath stringByAppendingPathComponent:DOORDU_OUTGOING_AUDIO];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
        
        return;
    }
    
    //播放
    [theDoorDuAudioPlayer playAudioFileWithPath:audioFilePath looping:looping];
}

#pragma mark -
#pragma mark (播放信息铃声)
- (void)playMessageAudio:(BOOL)looping {
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    //根据音频文件名称，在DoorDuSDK.bundle/audio目录下寻找音频文件
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *audioDirPath = [[resourcePath stringByAppendingPathComponent:kDoorDuAudioPlayerBundleName] stringByAppendingPathComponent:kDoorDuAudioPlayerAudioDirName];
    NSString *audioFilePath = [audioDirPath stringByAppendingPathComponent:DOORDU_MESSAGE_AUDIO];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
        
        return;
    }
    
    //播放
    [theDoorDuAudioPlayer playAudioFileWithPath:audioFilePath looping:looping];
}

#pragma mark -
#pragma mark (播放按键铃声)
- (void)playButtonAudio:(BOOL)looping {
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    //根据音频文件名称，在DoorDuSDK.bundle/audio目录下寻找音频文件
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *audioDirPath = [[resourcePath stringByAppendingPathComponent:kDoorDuAudioPlayerBundleName] stringByAppendingPathComponent:kDoorDuAudioPlayerAudioDirName];
    NSString *audioFilePath = [audioDirPath stringByAppendingPathComponent:DOORDU_BUTTON_AUDIO];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
        
        return;
    }
    
    //播放
    [theDoorDuAudioPlayer playAudioFileWithPath:audioFilePath looping:looping];
}

/*!
 * @method  playBusyAudio
 * @brief   播放正忙铃声.
 * @param   looping 是否重复播放.
 * @return  void.
 */
- (void)playBusyAudio:(BOOL)looping {
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    //根据音频文件名称，在DoorDuSDK.bundle/audio目录下寻找音频文件
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *audioDirPath = [[resourcePath stringByAppendingPathComponent:kDoorDuAudioPlayerBundleName] stringByAppendingPathComponent:kDoorDuAudioPlayerAudioDirName];
    NSString *audioFilePath = [audioDirPath stringByAppendingPathComponent:DOORDU_BUSY_AUDIO];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
        
        return;
    }
    
    //播放
    [theDoorDuAudioPlayer playAudioFileWithPath:audioFilePath looping:looping];
}
/*!
 * @method  playBusyAudio
 * @brief   播放正忙铃声.
 * @param   looping 是否重复播放.
 * @return  void.
 */
- (void)playDoorisBusyAudio:(BOOL)looping {
    
    if (!theDoorDuAudioPlayer) {
        
        return;
    }
    
    //根据音频文件名称，在DoorDuSDK.bundle/audio目录下寻找音频文件
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *audioDirPath = [[resourcePath stringByAppendingPathComponent:kDoorDuAudioPlayerBundleName] stringByAppendingPathComponent:kDoorDuAudioPlayerAudioDirName];
    NSString *audioFilePath = [audioDirPath stringByAppendingPathComponent:DOORDU_DOORBUSY_AUDIO];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
        
        return;
    }
    
    //播放
    [theDoorDuAudioPlayer playAudioFileWithPath:audioFilePath looping:looping];
}

@end
