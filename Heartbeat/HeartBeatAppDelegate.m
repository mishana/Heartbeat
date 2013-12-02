//
//  HeartBeatAppDelegate.m
//  Heartbeat
//
//  Created by michael leybovich on 9/10/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "HeartBeatAppDelegate.h"
#import "WelcomeScreenViewController.h"

@implementation HeartBeatAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wasLaunchedBefore"]) {
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasLaunchedBefore"];
    } else {
        //self.window.rootViewController = [[WelcomeScreenViewController alloc] initWithNibName:@"WelcomeScreenViewController" bundle:nil];
    }
    //[self.window makeKeyAndVisible];
    
    // Facebook part
    self.userManager = [[FacebookUserManager alloc] init];
    // At startup time we attempt to log in the default user that has signed on using Facebook Login
    //[viewController2 loginDefaultUser];
    //
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:self.userManager.currentSession];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// As part of the login workflow, the native application or Safari will transition back to this application'
// this method is then called, which defers the responsibility of parsing the url to the handleOpenURL method
// of FBSession
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.userManager.currentSession];
}

@end
