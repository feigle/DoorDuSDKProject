//
// DoorDuMQTTSessionLegacy.h
// DoorDuMQTTClient.framework
//

/**
 Using DoorDuMQTT in your Objective-C application
 This file contains definitions for DoorDuMQTTio-OBJC backward compatibility
 
 @author Christoph Krey krey.christoph@gmail.com
 @copyright Copyright © 2013-2016, Christoph Krey 
 
 based on Copyright (c) 2011, 2013, 2lemetry LLC
    All rights reserved. This program and the accompanying materials
    are made available under the terms of the Eclipse Public License v1.0
    which accompanies this distribution, and is available at
    http://www.eclipse.org/legal/epl-v10.html
 
 @see http://DoorDuMQTT.org
 */


#import <Foundation/Foundation.h>
#import "DoorDuMQTTSession.h"

@interface DoorDuMQTTSession(Create)

/** convenience initializer
 @param clientId see clientId for description.
 @param userName see username for description.
 @param password see password for description.
 @param keepAliveInterval see keepAliveInterval for description.
 @param cleanSessionFlag see cleanSessionFlag for description.
 @param willFlag see willFlag for description.
 @param willTopic see willTopic for description.
 @param willMsg see willMsg for description.
 @param willQoS see willQos for description.
 @param willRetainFlag see willRetainFlg for description.
 @param protocolLevel see protocolLevel for description.
 @param runLoop see runLoop for description.
 @param runLoopMode see runLoopMode for description.
 @return the initialised DoorDuMQTTSession object
 @exception NSInternalInconsistencyException if the parameters are invalid
 */
- (DoorDuMQTTSession *)initWithClientId:(NSString *)clientId
                         userName:(NSString *)userName
                         password:(NSString *)password
                        keepAlive:(UInt16)keepAliveInterval
                     cleanSession:(BOOL)cleanSessionFlag
                             will:(BOOL)willFlag
                        willTopic:(NSString *)willTopic
                          willMsg:(NSData *)willMsg
                          willQoS:(DoorDuMQTTQosLevel)willQoS
                   willRetainFlag:(BOOL)willRetainFlag
                    protocolLevel:(UInt8)protocolLevel
                          runLoop:(NSRunLoop *)runLoop
                          forMode:(NSString *)runLoopMode;

/** alternative initializer
 @param clientId see initWithClientId for description.
 @param userName see initWithClientId for description.
 @param password see initWithClientId for description.
 @param keepAliveInterval see initWithClientId for description.
 @param cleanSessionFlag see initWithClientId for description.
 @param willFlag see initWithClientId for description.
 @param willTopic see initWithClientId for description.
 @param willMsg see initWithClientId for description.
 @param willQoS see initWithClientId for description.
 @param willRetainFlag see initWithClientId for description.
 @param protocolLevel see initWithClientId for description.
 @param runLoop see initWithClientId for description.
 @param runLoopMode see initWithClientId for description.
 @param securityPolicy see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 @exception NSInternalInconsistencyException if the parameters are invalid
 */
- (DoorDuMQTTSession *)initWithClientId:(NSString *)clientId
                         userName:(NSString *)userName
                         password:(NSString *)password
                        keepAlive:(UInt16)keepAliveInterval
                     cleanSession:(BOOL)cleanSessionFlag
                             will:(BOOL)willFlag
                        willTopic:(NSString *)willTopic
                          willMsg:(NSData *)willMsg
                          willQoS:(DoorDuMQTTQosLevel)willQoS
                   willRetainFlag:(BOOL)willRetainFlag
                    protocolLevel:(UInt8)protocolLevel
                          runLoop:(NSRunLoop *)runLoop
                          forMode:(NSString *)runLoopMode
                   securityPolicy:(DoorDuMQTTSSLSecurityPolicy *) securityPolicy;

/** initialises the DoorDuMQTT session
 *
 * this constructor can specifies SSL securityPolicy. the default value of securityPolicy is nil(which do nothing).
 *
 * if SSL is enabled, by default it only evaluate server's certificates using CA infrastructure, and for most case, this type of check is enough.
 * However, if your app using security model which require pinning SSL certificates to helps prevent man-in-the-middle attacks
 * and other vulnerabilities. you may need to set securityPolicy to properly value(see DoorDuMQTTSSLSecurityPolicy.h for more detail).
 *
 * NOTE: about self-signed server certificates:
 * In CA infrastructure, you may establish a SSL/TLS connection with server which using self-signed certificates
 * by install the certificates into OS keychain(either programmatically or manually). however, this method has some disadvantages:
 *  1. every socket you app created will trust certificates you added.
 *  2. if user choice to remove certificates from keychain, you app need to handling certificates re-adding.
 *
 * If you only want to verify the cert for the socket you are creating and for no other sockets in your app, you need to use
 * DoorDuMQTTSSLSecurityPolicy.
 * And if you use self-signed server certificates, your need to set property: DoorDuMQTTSSLSecurityPolicy.allowInvalidCertificates=YES
 * (see DoorDuMQTTSSLSecurityPolicy.h for more detail).
 *
 * @param clientId The Client Identifier identifies the Client to the Server. If nil, a random clientId is generated.
 * @param userName an NSString object containing the user's name (or ID) for authentication. May be nil.
 * @param password an NSString object containing the user's password. If userName is nil, password must be nil as well.
 * @param keepAliveInterval The Keep Alive is a time interval measured in seconds. The DoorDuMQTTClient ensures that the interval between Control Packets being sent does not exceed the Keep Alive value. In the  absence of sending any other Control Packets, the Client sends a PINGREQ Packet.
 * @param cleanSessionFlag specifies if the server should discard previous session information.
 * @param willFlag If the Will Flag is set to YES this indicates that a Will Message MUST be published by the Server when the Server detects that the Client is disconnected for any reason other than the Client flowing a DISCONNECT Packet.
 * @param willTopic If the Will Flag is set to YES, the Will Topic is a string, nil otherwise.
 * @param willMsg If the Will Flag is set to YES the Will Message must be specified, nil otherwise.
 * @param willQoS specifies the QoS level to be used when publishing the Will Message. If the Will Flag is set to NO, then the Will QoS MUST be set to 0. If the Will Flag is set to YES, the value of Will QoS can be 0 (0x00), 1 (0x01), or 2 (0x02).
 * @param willRetainFlag indicates if the server should publish the Will Messages with retainFlag. If the Will Flag is set to NO, then the Will Retain Flag MUST be set to NO . If the Will Flag is set to YES: If Will Retain is set to NO, the Server MUST publish the Will Message as a non-retained publication [DoorDuMQTT-3.1.2-14]. If Will Retain is set to YES, the Server MUST publish the Will Message as a retained publication [DoorDuMQTT-3.1.2-15].
 * @param protocolLevel specifies the protocol to be used. The value of the Protocol Level field for the version 3.1.1 of the protocol is 4. The value for the version 3.1 is 3.
 * @param runLoop The runLoop where the streams are scheduled. If nil, defaults to [NSRunLoop currentRunLoop].
 * @param runLoopMode The runLoopMode where the streams are scheduled. If nil, defaults to NSRunLoopCommonModes.
 * @param securityPolicy The security policy used to evaluate server trust for secure connections.
 * @param certificates An identity certificate used to reply to a server requiring client certificates according to the description given for SSLSetCertificate(). You may build the certificates array yourself or use the sundry method clientCertFromP12
 * @return the initialised DoorDuMQTTSession object
 * @exception NSInternalInconsistencyException if the parameters are invalid
 *
 * @code
 #import "DoorDuMQTTClient.h"
 
 NSString* certificate = [[NSBundle bundleForClass:[DoorDuMQTTSession class]] pathForResource:@"certificate" ofType:@"cer"];
 DoorDuMQTTSSLSecurityPolicy *securityPolicy = [DoorDuMQTTSSLSecurityPolicy policyWithPinningMode:DoorDuMQTTSSLPinningModeCertificate];
 securityPolicy.pinnedCertificates = @[ [NSData dataWithContentsOfFile:certificate] ];
 securityPolicy.allowInvalidCertificates = YES; // if your certificate is self-signed(which didn't coupled with CA infrastructure)
 
 DoorDuMQTTSession *session = [[DoorDuMQTTSession alloc]
 initWithClientId:@"example-1234"
 userName:@"user"
 password:@"secret"
 keepAlive:60
 cleanSession:YES
 will:YES
 willTopic:@"example/status"
 willMsg:[[@"Client off-line"] dataUsingEncoding:NSUTF8StringEncoding]
 willQoS:2
 willRetainFlag:YES
 protocolLevel:4
 runLoop:[NSRunLoop currentRunLoop]
 forMode:NSRunLoopCommonModes
 securityPolicy:securityPolicy
 certificates:certificates];
 
 [session connectToHost:@"example-1234" port:1883 usingSSL:YES];
 @endcode
 */
- (DoorDuMQTTSession *)initWithClientId:(NSString *)clientId
                         userName:(NSString *)userName
                         password:(NSString *)password
                        keepAlive:(UInt16)keepAliveInterval
                     cleanSession:(BOOL)cleanSessionFlag
                             will:(BOOL)willFlag
                        willTopic:(NSString *)willTopic
                          willMsg:(NSData *)willMsg
                          willQoS:(DoorDuMQTTQosLevel)willQoS
                   willRetainFlag:(BOOL)willRetainFlag
                    protocolLevel:(UInt8)protocolLevel
                          runLoop:(NSRunLoop *)runLoop
                          forMode:(NSString *)runLoopMode
                   securityPolicy:(DoorDuMQTTSSLSecurityPolicy *) securityPolicy
                     certificates:(NSArray *)certificates;

/**
* for DoorDuMQTTio-OBJC backward compatibility
* @param theClientId see initWithClientId for description.
* @return the initialised DoorDuMQTTSession object
* All other parameters are set to defaults
*/
- (id)initWithClientId:(NSString *)theClientId;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theClientId see initWithClientId for description.
 @param theRunLoop see initWithClientId for description.
 @param theRunLoopMode see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 All other parameters are set to defaults
 */
- (id)initWithClientId:(NSString*)theClientId
               runLoop:(NSRunLoop*)theRunLoop
               forMode:(NSString*)theRunLoopMode;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theClientId see initWithClientId for description.
 @param theUsername see initWithClientId for description.
 @param thePassword see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 All other parameters are set to defaults
 */
- (id)initWithClientId:(NSString*)theClientId
              userName:(NSString*)theUsername
              password:(NSString*)thePassword;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theClientId see initWithClientId for description.
 @param theUserName see initWithClientId for description.
 @param thePassword see initWithClientId for description.
 @param theRunLoop see initWithClientId for description.
 @param theRunLoopMode see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 All other parameters are set to defaults
 */
- (id)initWithClientId:(NSString*)theClientId
              userName:(NSString*)theUserName
              password:(NSString*)thePassword
               runLoop:(NSRunLoop*)theRunLoop
               forMode:(NSString*)theRunLoopMode;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theClientId see initWithClientId for description.
 @param theUsername see initWithClientId for description.
 @param thePassword see initWithClientId for description.
 @param theKeepAliveInterval see initWithClientId for description.
 @param cleanSessionFlag see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 All other parameters are set to defaults
 */
- (id)initWithClientId:(NSString*)theClientId
              userName:(NSString*)theUsername
              password:(NSString*)thePassword
             keepAlive:(UInt16)theKeepAliveInterval
          cleanSession:(BOOL)cleanSessionFlag;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theClientId see initWithClientId for description.
 @param theUsername see initWithClientId for description.
 @param thePassword see initWithClientId for description.
 @param theKeepAlive see initWithClientId for description.
 @param theCleanSessionFlag see initWithClientId for description.
 @param theRunLoop see initWithClientId for description.
 @param theMode see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 All other parameters are set to defaults
 */
- (id)initWithClientId:(NSString*)theClientId
              userName:(NSString*)theUsername
              password:(NSString*)thePassword
             keepAlive:(UInt16)theKeepAlive
          cleanSession:(BOOL)theCleanSessionFlag
               runLoop:(NSRunLoop*)theRunLoop
               forMode:(NSString*)theMode;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theClientId see initWithClientId for description.
 @param theUserName see initWithClientId for description.
 @param thePassword see initWithClientId for description.
 @param theKeepAliveInterval see initWithClientId for description.
 @param theCleanSessionFlag see initWithClientId for description.
 @param willTopic see initWithClientId for description.
 @param willMsg see initWithClientId for description.
 @param willQoS see initWithClientId for description.
 @param willRetainFlag see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 All other parameters are set to defaults
 */
- (id)initWithClientId:(NSString*)theClientId
              userName:(NSString*)theUserName
              password:(NSString*)thePassword
             keepAlive:(UInt16)theKeepAliveInterval
          cleanSession:(BOOL)theCleanSessionFlag
             willTopic:(NSString*)willTopic
               willMsg:(NSData*)willMsg
               willQoS:(UInt8)willQoS
        willRetainFlag:(BOOL)willRetainFlag;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theClientId see initWithClientId for description.
 @param theUserName see initWithClientId for description.
 @param thePassword see initWithClientId for description.
 @param theKeepAliveInterval see initWithClientId for description.
 @param theCleanSessionFlag see initWithClientId for description.
 @param willTopic see initWithClientId for description.
 @param willMsg see initWithClientId for description.
 @param willQoS see initWithClientId for description.
 @param willRetainFlag see initWithClientId for description.
 @param theRunLoop see initWithClientId for description.
 @param theRunLoopMode see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 All other parameters are set to defaults
 */
- (id)initWithClientId:(NSString*)theClientId
              userName:(NSString*)theUserName
              password:(NSString*)thePassword
             keepAlive:(UInt16)theKeepAliveInterval
          cleanSession:(BOOL)theCleanSessionFlag
             willTopic:(NSString*)willTopic
               willMsg:(NSData*)willMsg
               willQoS:(UInt8)willQoS
        willRetainFlag:(BOOL)willRetainFlag
               runLoop:(NSRunLoop*)theRunLoop
               forMode:(NSString*)theRunLoopMode;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theClientId see initWithClientId for description.
 @param theKeepAliveInterval see initWithClientId for description.
 @param theConnectMessage has to be constructed using DoorDuMQTTMessage connectMessage...
 @param theRunLoop see initWithClientId for description.
 @param theRunLoopMode see initWithClientId for description.
 @return the initialised DoorDuMQTTSession object
 All other parameters are set to defaults
 */
- (id)initWithClientId:(NSString*)theClientId
             keepAlive:(UInt16)theKeepAliveInterval
        connectMessage:(DoorDuMQTTMessage*)theConnectMessage
               runLoop:(NSRunLoop*)theRunLoop
               forMode:(NSString*)theRunLoopMode;

/** connects to the specified DoorDuMQTT server
 
 @param host specifies the hostname or ip address to connect to. Defaults to @"localhost".
 @param port specifies the port to connect to
 @param usingSSL specifies whether to use SSL or not
 @param connectHandler identifies a block which is executed on successfull or unsuccessfull connect. Might be nil
 error is nil in the case of a successful connect
 sessionPresent indicates in DoorDuMQTT 3.1.1 if persistent session data was present at the server
 
 @return nothing and returns immediately. To check the connect results, register as an DoorDuMQTTSessionDelegate and
 - watch for events
 - watch for connect or connectionRefused messages
 - watch for error messages
 or use the connectHandler block
 
 @code
 #import "DoorDuMQTTClient.h"
 
 DoorDuMQTTSession *session = [[DoorDuMQTTSession alloc] init];
 
 [session connectToHost:@"192.168.0.1" port:1883 usingSSL:NO connectHandler:^(NSError *error, BOOL sessionPresent) {
 if (error) {
 NSLog(@"Error Connect %@", error.localizedDescription);
 } else {
 NSLog(@"Connected sessionPresent:%d", sessionPresent);
 }
 }];
 @endcode
 
 @deprecated as not all connection parameters are supported, use connect
 */

- (void)connectToHost:(NSString *)host
                 port:(UInt32)port
             usingSSL:(BOOL)usingSSL
       connectHandler:(DoorDuMQTTConnectHandler)connectHandler;

/** connects to the specified DoorDuMQTT server
 
 @param host see connectToHost for description
 @param port see connectToHost for description
 @param usingSSL see connectToHost for description
 
 @return see connectToHost for description
 @deprecated as not all connection parameters are supported, use connect
 
 */
- (void)connectToHost:(NSString *)host port:(UInt32)port usingSSL:(BOOL)usingSSL;


/** for DoorDuMQTTio-OBJC backward compatibility
 @param ip see connectToHost for description
 @param port see connectToHost for description
 @deprecated as not all connection parameters are supported, use connect
 */
- (void)connectToHost:(NSString*)ip port:(UInt32)port;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param ip see connectToHost for description
 @param port see connectToHost for description
 @param connHandler event handler block
 @param messHandler message handler block
 @deprecated as not all connection parameters are supported, use connect

 */
- (void)connectToHost:(NSString*)ip
                 port:(UInt32)port
withConnectionHandler:(void (^)(DoorDuMQTTSessionEvent event))connHandler
       messageHandler:(void (^)(NSData* data, NSString* topic))messHandler;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param ip see connectToHost for description
 @param port see connectToHost for description
 @param usingSSL indicator to use TLS
 @param connHandler event handler block
 @param messHandler message handler block
 */
- (void)connectToHost:(NSString*)ip
                 port:(UInt32)port
             usingSSL:(BOOL)usingSSL
withConnectionHandler:(void (^)(DoorDuMQTTSessionEvent event))connHandler
       messageHandler:(void (^)(NSData* data, NSString* topic))messHandler;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theTopic see subscribeToTopic for description
 */
- (void)subscribeTopic:(NSString*)theTopic;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theData see publishData for description
 @param theTopic see publishData for description
  */
- (void)publishData:(NSData*)theData onTopic:(NSString*)theTopic;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theData see publishData for description
 @param theTopic see publishData for description
 */
- (void)publishDataAtLeastOnce:(NSData*)theData onTopic:(NSString*)theTopic;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theData see publishData for description
 @param theTopic see publishData for description
 @param retainFlag see publishData for description
 */
- (void)publishDataAtLeastOnce:(NSData*)theData onTopic:(NSString*)theTopic retain:(BOOL)retainFlag;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theData see publishData for description
 @param theTopic see publishData for description
 */
- (void)publishDataAtMostOnce:(NSData*)theData onTopic:(NSString*)theTopic;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theData see publishData for description
 @param theTopic see publishData for description
 @param retainFlag see publishData for description
 */
- (void)publishDataAtMostOnce:(NSData*)theData onTopic:(NSString*)theTopic retain:(BOOL)retainFlag;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theData see publishData for description
 @param theTopic see publishData for description
 */
- (void)publishDataExactlyOnce:(NSData*)theData onTopic:(NSString*)theTopic;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param theData see publishData for description
 @param theTopic see publishData for description
 @param retainFlag see publishData for description
 */
- (void)publishDataExactlyOnce:(NSData*)theData onTopic:(NSString*)theTopic retain:(BOOL)retainFlag;

/** for DoorDuMQTTio-OBJC backward compatibility
 @param payload JSON payload is converted to NSData and then send. See publishData for description
 @param theTopic see publishData for description
 */
- (void)publishJson:(id)payload onTopic:(NSString*)theTopic;

@end
