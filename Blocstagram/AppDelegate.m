//
//  AppDelegate.m
//  Blocstagram
//
//  Created by Stephen Palley on 12/19/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "AppDelegate.h"
#import "BLCImagesTableViewController.h"
#import "BLCLoginViewController.h"
#import "BLCDataSource.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [BLCDataSource sharedInstance]; // create the data source (so it can receive the access token notification)
    
    UINavigationController *navVC = [[UINavigationController alloc] init];
    
    if (![BLCDataSource sharedInstance].accessToken) //if no token, go to login page
    {
    
        BLCLoginViewController *loginVC = [[BLCLoginViewController alloc] init];
        [navVC setViewControllers:@[loginVC] animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            BLCImagesTableViewController *imagesVC = [[BLCImagesTableViewController alloc] init];
            [navVC setViewControllers:@[imagesVC] animated:YES];
        }];
    }
    else //if token is saved, go straight to main table view
    {
        BLCImagesTableViewController *imagesVC = [[BLCImagesTableViewController alloc] init];
        [navVC setViewControllers:@[imagesVC] animated:YES];
    }
    
    
    self.window.rootViewController = navVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
