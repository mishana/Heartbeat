//
//  HeartBeatProtocols.h
//  Heartbeat
//
//  Created by Or Maayan on 12/7/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookSDK/FacebookSDK.h"

@protocol PulseObject<FBGraphObject>

@end

@protocol MeaasurePulseAction<FBOpenGraphAction>

@property (retain, nonatomic) id<PulseObject> pulse;

@end
