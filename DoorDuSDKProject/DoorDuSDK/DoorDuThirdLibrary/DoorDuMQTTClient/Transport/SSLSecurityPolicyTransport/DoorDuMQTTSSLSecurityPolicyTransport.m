//
//  DoorDuMQTTSSLSecurityPolicyTransport.m
//  DoorDuMQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import "DoorDuMQTTSSLSecurityPolicyTransport.h"
#import "DoorDuMQTTSSLSecurityPolicyEncoder.h"
#import "DoorDuMQTTSSLSecurityPolicyDecoder.h"

@interface DoorDuMQTTSSLSecurityPolicyTransport()
@property (strong, nonatomic) DoorDuMQTTSSLSecurityPolicyEncoder *encoder;
@property (strong, nonatomic) DoorDuMQTTSSLSecurityPolicyDecoder *decoder;

@end

@implementation DoorDuMQTTSSLSecurityPolicyTransport
@synthesize state;
@synthesize delegate;

- (instancetype)init {
    self = [super init];
    self.securityPolicy = nil;
    return self;
}

- (void)open {
    self.state = DoorDuMQTTTransportOpening;

    NSError* connectError;

    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.host, self.port, &readStream, &writeStream);

    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);

    if (self.tls) {
        NSMutableDictionary *sslOptions = [[NSMutableDictionary alloc] init];
        
        // delegate certificates verify operation to our secure policy.
        // by disabling chain validation, it becomes our responsibility to verify that the host at the other end can be trusted.
        // the server's certificates will be verified during DoorDuMQTT encoder/decoder processing.
        [sslOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
                       forKey:(NSString*)kCFStreamSSLLevel];
        [sslOptions setObject:[NSNumber numberWithBool:NO]
                       forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
        
        if (self.certificates) {
            [sslOptions setObject:self.certificates
                           forKey:(NSString *)kCFStreamSSLCertificates];
        }
        
        if(!CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, (__bridge CFDictionaryRef)(sslOptions))){
            connectError = [NSError errorWithDomain:@"DoorDuMQTT"
                                               code:errSSLInternal
                                           userInfo:@{NSLocalizedDescriptionKey : @"Fail to init ssl input stream!"}];
        }
        if(!CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, (__bridge CFDictionaryRef)(sslOptions))){
            connectError = [NSError errorWithDomain:@"DoorDuMQTT"
                                               code:errSSLInternal
                                           userInfo:@{NSLocalizedDescriptionKey : @"Fail to init ssl output stream!"}];
        }
    }
    
    if(!connectError){
        self.encoder = [[DoorDuMQTTSSLSecurityPolicyEncoder alloc] init];
        self.encoder.stream = CFBridgingRelease(writeStream);
        self.encoder.securityPolicy = self.tls ? self.securityPolicy : nil;
        self.encoder.securityDomain = self.tls ? self.host : nil;
        self.encoder.runLoop = self.runLoop;
        self.encoder.runLoopMode = self.runLoopMode;
        self.encoder.delegate = self;
        [self.encoder open];
        
        self.decoder = [[DoorDuMQTTSSLSecurityPolicyDecoder alloc] init];
        self.decoder.stream =  CFBridgingRelease(readStream);
        self.decoder.securityPolicy = self.tls ? self.securityPolicy : nil;
        self.decoder.securityDomain = self.tls ? self.host : nil;
        self.decoder.runLoop = self.runLoop;
        self.decoder.runLoopMode = self.runLoopMode;
        self.decoder.delegate = self;
        [self.decoder open];
        
    } else {
        [self close];
    }
}

@end
