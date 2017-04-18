//
//  DoorDuMQTTCFSocketTransport.m
//  DoorDuMQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import "DoorDuMQTTCFSocketTransport.h"

@interface DoorDuMQTTCFSocketTransport()
@property (strong, nonatomic) DoorDuMQTTCFSocketEncoder *encoder;
@property (strong, nonatomic) DoorDuMQTTCFSocketDecoder *decoder;
@end

@implementation DoorDuMQTTCFSocketTransport
@synthesize state;
@synthesize delegate;
@synthesize runLoop;
@synthesize runLoopMode;

- (instancetype)init {
    self = [super init];
    self.host = @"localhost";
    self.port = 1883;
    self.tls = false;
    self.certificates = nil;
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
        
        [sslOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
                       forKey:(NSString*)kCFStreamSSLLevel];
        
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
        self.encoder.delegate = nil;
        self.encoder = [[DoorDuMQTTCFSocketEncoder alloc] init];
        self.encoder.stream = CFBridgingRelease(writeStream);
        self.encoder.runLoop = self.runLoop;
        self.encoder.runLoopMode = self.runLoopMode;
        self.encoder.delegate = self;
        [self.encoder open];
        
        self.decoder.delegate = nil;
        self.decoder = [[DoorDuMQTTCFSocketDecoder alloc] init];
        self.decoder.stream =  CFBridgingRelease(readStream);
        self.decoder.runLoop = self.runLoop;
        self.decoder.runLoopMode = self.runLoopMode;
        self.decoder.delegate = self;
        [self.decoder open];
        
    } else {
        [self close];
    }
}

- (void)close {
    self.state = DoorDuMQTTTransportClosing;

    if (self.encoder) {
        [self.encoder close];
        self.encoder.delegate = nil;
    }
    
    if (self.decoder) {
        [self.decoder close];
        self.decoder.delegate = nil;
    }
}

- (BOOL)send:(nonnull NSData *)data {
    return [self.encoder send:data];
}

- (void)decoder:(DoorDuMQTTCFSocketDecoder *)sender didReceiveMessage:(nonnull NSData *)data {
    [self.delegate DoorDuMQTTTransport:self didReceiveMessage:data];
}

- (void)decoder:(DoorDuMQTTCFSocketDecoder *)sender didFailWithError:(NSError *)error {
    //self.state = DoorDuMQTTTransportClosing;
    //[self.delegate DoorDuMQTTTransport:self didFailWithError:error];
}
- (void)encoder:(DoorDuMQTTCFSocketEncoder *)sender didFailWithError:(NSError *)error {
    self.state = DoorDuMQTTTransportClosing;
    [self.delegate DoorDuMQTTTransport:self didFailWithError:error];
}

- (void)decoderdidClose:(DoorDuMQTTCFSocketDecoder *)sender {
    self.state = DoorDuMQTTTransportClosed;
    [self.delegate DoorDuMQTTTransportDidClose:self];
}
- (void)encoderdidClose:(DoorDuMQTTCFSocketEncoder *)sender {
    //self.state = DoorDuMQTTTransportClosed;
    //[self.delegate DoorDuMQTTTransportDidClose:self];
}

- (void)decoderDidOpen:(DoorDuMQTTCFSocketDecoder *)sender {
    //self.state = DoorDuMQTTTransportOpen;
    //[self.delegate DoorDuMQTTTransportDidOpen:self];
}
- (void)encoderDidOpen:(DoorDuMQTTCFSocketEncoder *)sender {
    self.state = DoorDuMQTTTransportOpen;
    [self.delegate DoorDuMQTTTransportDidOpen:self];
}

+ (NSArray *)clientCertsFromP12:(NSString *)path passphrase:(NSString *)passphrase {
    if (!path) {
        return nil;
    }
    
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:path];
    if (!pkcs12data) {
        return nil;
    }
    
    if (!passphrase) {
        return nil;
    }
    CFArrayRef keyref = NULL;
    OSStatus importStatus = SecPKCS12Import((__bridge CFDataRef)pkcs12data,
                                            (__bridge CFDictionaryRef)[NSDictionary
                                                                       dictionaryWithObject:passphrase
                                                                       forKey:(__bridge id)kSecImportExportPassphrase],
                                            &keyref);
    if (importStatus != noErr) {
        return nil;
    }
    
    CFDictionaryRef identityDict = CFArrayGetValueAtIndex(keyref, 0);
    if (!identityDict) {
        return nil;
    }
    
    SecIdentityRef identityRef = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                      kSecImportItemIdentity);
    if (!identityRef) {
        return nil;
    };
    
    SecCertificateRef cert = NULL;
    OSStatus status = SecIdentityCopyCertificate(identityRef, &cert);
    if (status != noErr) {
        return nil;
    }
    
    NSArray *clientCerts = [[NSArray alloc] initWithObjects:(__bridge id)identityRef, (__bridge id)cert, nil];
    return clientCerts;
}

@end
