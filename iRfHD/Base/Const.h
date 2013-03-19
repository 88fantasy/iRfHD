/*
 *  Const.h
 *  rf
 *
 *  Created by pro on 11-7-8.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ZBarSDK.h"
#import "Const.h"
#import "sqlite3.h"
#import "FMDatabase.h"
#import "CommonUtil.h"
#import "DbUtil.h"
#import "SBJson.h"

#define kBase @"http://www.gzmpc.com/gzmpcscm3"
#define kHomeUrl @"http://125.88.8.28/gzmpcscm3/services/RgService"
#define kHost @"www.gzmpc.com"
#define kRetFlagKey @"ret"
#define kMsgKey @"msg"
#define kSettingUserKey @"setuser"
#define kSettingPwdKey @"setpwd"
#define kSettingInternetKey @"setinternet"
#define kSettingServerKey @"setserver"


#define IsPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)//定义是否是Ipad的宏
#define fcccf(__x__,__y__) GetPointbyPhoneXandY(__x__,__y__)//为了与ccp用法一致
#define IsInternet ([[[CommonUtil getSettings] objectForKey:kSettingInternetKey]boolValue])//互联网检查
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)  //iphone5分辨率检查
#define GetScreenSize [[UIScreen mainScreen] bounds]  //获取设备分辨率 返回 CGRect
#define GetSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue] //返回当前系统版本
#define IsLandscape UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)   //横屏检查
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]  //16进制取颜色 格式为 0xFFFFFF