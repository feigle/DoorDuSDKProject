//
// DoorDuMQTTSSLSecurityPolicyEncoder.h
// DoorDuMQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import <Foundation/Foundation.h>
#import "DoorDuMQTTSSLSecurityPolicy.h"
#import "DoorDuMQTTCFSocketEncoder.h"

@interface DoorDuMQTTSSLSecurityPolicyEncoder : DoorDuMQTTCFSocketEncoder
@property(strong, nonatomic) DoorDuMQTTSSLSecurityPolicy *securityPolicy;
@property(strong, nonatomic) NSString *securityDomain;

@end

