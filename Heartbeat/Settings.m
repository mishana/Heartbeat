//
//  Settings.m
//  Heartbeat
//
//  Created by michael leybovich on 9/24/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "Settings.h"

@interface Settings()

@end

@implementation Settings

#define ALL_SETTINGS_KEY @"Setings_All"

#define CONTINUOUS_MODE_KEY @"continuousMode"
#define AUTO_STOP_AFTER_KEY @"autoStopAfter"


- (void)synchronize
{
    [[NSUserDefaults standardUserDefaults] setObject:self forKey:ALL_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (Settings *)defaultSettings
{
    Settings *settings = [[Settings alloc] init];
    
    settings.continuousMode = NO;
    settings.autoStopAfter = 15;
    
    return settings;
}

+ (Settings *)currentSettings
{
    Settings *settings = (Settings *)[[NSUserDefaults standardUserDefaults] objectForKey:ALL_SETTINGS_KEY];
    
    if (!settings) {
        settings = [Settings defaultSettings];
        [settings synchronize];
    }
    Settings *currentSettings = [[Settings alloc] init];
    
    currentSettings.continuousMode = settings.continuousMode;
    currentSettings.autoStopAfter = settings.autoStopAfter;
    
    return currentSettings;
}

@end
