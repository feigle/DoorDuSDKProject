//
//  DoorDuMQTTSSLSecurityPolicyTransport.h
//  DoorDuMQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import "DoorDuMQTTTransport.h"
#import "DoorDuMQTTSSLSecurityPolicy.h"
#import "DoorDuMQTTCFSocketTransport.h"

/** DoorDuMQTTSSLSecurityPolicyTransport
 * implements an extension of the DoorDuMQTTCFSocketTransport by replacing the OS's certificate chain evaluation
 */
@interface DoorDuMQTTSSLSecurityPolicyTransport : DoorDuMQTTCFSocketTransport

/**
 * The security policy used to evaluate server trust for secure connections.
 *
 * if your app using security model which require pinning SSL certificates to helps prevent man-in-the-middle attacks
 * and other vulnerabilities. you need to set securityPolicy to properly value(see DoorDuMQTTSSLSecurityPolicy.h for more detail).
 *
 * NOTE: about self-signed server certificates:
 * if your server using Self-signed certificates to establish SSL/TLS connection, you need to set property:
 * DoorDuMQTTSSLSecurityPolicy.allowInvalidCertificates=YES.
 */
@property (strong, nonatomic) DoorDuMQTTSSLSecurityPolicy *securityPolicy;

@end
