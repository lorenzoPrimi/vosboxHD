//
//  AppDelegate.m
//  VosboxHD
//
//  Created by Lorenzo Primiterra on 01/06/2012.
//  Copyright (c) 2012 K2 Technology. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    settings = [NSUserDefaults standardUserDefaults];
    NSString *server = [settings stringForKey:@"custom_srv"];
	if(!server) {
		// If the default value doesn't exist then we need to manually set them.
		[self registerDefaultsFromSettingsBundle];
		//server = [[NSUserDefaults standardUserDefaults] stringForKey:@"custom_srv"];
	}
    vosboxController = (VosboxViewController*) self.window.rootViewController;
    
    vosboxController.custom_srv =  [settings stringForKey:@"custom_srv"];
    vosboxController.srv_addr =  [settings stringForKey:@"srv_addr"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsChanged)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    return YES;
}
		
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [vosboxController handleOpenURL:url];
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
    
    //TODO
    //[[[tabBarController viewControllers] objectAtIndex:2] checkPaused];
    [vosboxController checkPaused];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (void) defaultsChanged {
    
    NSString *custom_srv_new =  [settings stringForKey:@"custom_srv"];
    NSString *srv_addr_new =  [settings stringForKey:@"srv_addr"];
    
    if (![vosboxController.custom_srv isEqualToString:custom_srv_new]){
        if ([custom_srv_new isEqualToString:@"0"]) [self reloadSettings];
        else {
            if ([srv_addr_new length] > 0) [self reloadSettings];
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"You specified to use a custom server but you have entered no server address", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
                [alert show];
            }
        }
    }
    else if (![vosboxController.srv_addr isEqualToString:srv_addr_new]) [self reloadSettings];
}

- (void)reloadSettings {
    vosboxController.custom_srv =  [settings stringForKey:@"custom_srv"];
    vosboxController.srv_addr =  [settings stringForKey:@"srv_addr"];
    [vosboxController reloadSettings];
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings2 = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings2 objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}


@end
