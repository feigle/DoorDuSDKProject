//
//  MQTTCoreDataPersistence.h
//  MQTTClient
//
//  Created by Christoph Krey on 22.03.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DoorDuMQTTPersistence.h"

@interface DoorDuMQTTCoreDataPersistence : NSObject <DoorDuMQTTPersistence>

@end

@interface DoorDuMQTTFlow : NSManagedObject <DoorDuMQTTFlow>
@end

@interface DoorDuMQTTCoreDataFlow : NSObject <DoorDuMQTTFlow>
@end
