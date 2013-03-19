//
//  iRfAppDelegate.h
//  iRfHD
//
//  Created by pro on 13-3-18.
//  Copyright (c) 2013年 rwe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface iRfAppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate>
{
    NSString *devtoken;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) NSString *devtoken;

@end
