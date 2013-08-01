//
//  AppDelegate.h
//  VosboxHD
//
//  Created by Lorenzo Primiterra on 01/06/2012.
//  Copyright (c) 2012 K2 Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceManager.h"
#import "VosboxViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSUserDefaults *settings;
    VosboxViewController *vosboxController;
}

@property (strong, nonatomic) UIWindow *window;

- (void)reloadSettings;

@end
