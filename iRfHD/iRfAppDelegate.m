//
//  iRfAppDelegate.m
//  iRfHD
//
//  Created by pro on 13-3-18.
//  Copyright (c) 2013年 rwe. All rights reserved.
//

#import "iRfAppDelegate.h"

#import "ViewController.h"
#import "RootViewController.h"
#import "iRfRgService.h"


@implementation iRfAppDelegate

@synthesize devtoken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [application setApplicationIconBadgeNumber:0];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    RootViewController *root = [[RootViewController alloc]initWithStyle:UITableViewStylePlain];
    self.navigationController = [[ViewController alloc] initWithRootViewController:root];
    
    self.navigationController.delegate = self;
//    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [self versionCheck];
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark push notifications handle


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    NSLog(@"Device Token=%@",newDeviceToken);
    NSString *token = [NSString stringWithFormat:@"%@",newDeviceToken];
    self.devtoken = [token substringWithRange:NSMakeRange(1, [token length]-2)];
    
    NSString *username = [[CommonUtil getSettings] objectForKey:kSettingUserKey];
    if (username != nil && IsInternet) {
        NSString *appid = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
        NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                             devtoken,@"token",
                             appid,@"appid",
                             username,@"username",
                             nil];
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *json = [writer stringWithObject:obj];
        
        iRfRgService* service = [iRfRgService service];
        
        [service setIRfSetting:self action:nil username:@"iRfsetting" password:nil jsonObject:json];
    }
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Fail to get Device Token=%@",[error localizedDescription]);
}

//广播频道（broadcast channel）用于同时联系到所有用户，所以很多时候开发者可能需要自己创建一些更精准化的频道。一旦推送通知被接受但是应用不在前台，就会被显示在iOS推送中心。反之如果应用刚好处于活动状态，则交于应用去自行处理。具体我们可以在app delegate中实现[application:didReceiveRemoteNotification]方法。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Receive a Remote Notification : %@",userInfo);
    //可以根据application状态来判断，程序当前是在前台还是后台
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        
        // Application was in the background when notification
        // was delivered.
    }
}


#pragma mark -
#pragma mark 版本检查  NSURLConnectionDataDelegate delegate

-(void)versionCheck
{
    // 新版本检查
    NSDictionary *appinfo = [[NSBundle mainBundle] infoDictionary] ;
    
    NSLog(@"%@",appinfo);
    
    NSString *version = [appinfo objectForKey:@"CFBundleShortVersionString"];//(NSString *)kCFBundleVersionKey];
    NSString *bid = [appinfo objectForKey: (__bridge NSString *) kCFBundleIdentifierKey];
    
    NSString *urlString =[NSString stringWithFormat:@"http://%@/phoneapp/ios/iRf.php?bid=%@&newestver=%@",kHost,bid,version];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [connection start];
    
    // 版本检查end
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Version check result string is :%@",result);
    
    if ([@"" isEqualToString:[result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
        return;
    }
    NSError *error = nil;
    
    id retObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (retObj != nil) {
        NSLog(@"%@",retObj);
        NSDictionary *versionobj = (NSDictionary *)retObj;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有新版本啦[%@]",[versionobj objectForKey:@"version"]]
                                                        message:[versionobj objectForKey:@"comments"]
													   delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel")
                                              otherButtonTitles:@"立即安装", nil];
//        [alert setTag:VersionAlert];
        NSArray *subViewArray = alert.subviews;
        
        for(int x=0;x<[subViewArray count];x++){
            if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]])
            {
                UILabel *label = [subViewArray objectAtIndex:x];
                label.textAlignment = NSTextAlignmentLeft;
            }
        }
		[alert show];
    }
    else {
        [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:[error localizedDescription]];
    }
}

#pragma mark -
#pragma mark version check UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
//    if ([alertView tag] == VersionAlert) {
        if(buttonIndex == 1) {
            NSString *appurl = [NSString stringWithFormat:@"itms-services:///?action=download-manifest&url=http://%@/phoneapp/ios/iRf.php",kHost];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appurl]];
        }
//    }
}


#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self isKindOfClass:[viewController class]]) {
        //增加滑动手势操作
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:viewController action:@selector(swipeBackView:)];
        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft]; //左划
        [swipeGesture setNumberOfTouchesRequired:2];//双指操作有效
        //        [swipeGesture setDelegate:self];
        [viewController.view addGestureRecognizer:swipeGesture];
    }
    
}

@end


@interface UIViewController (UINavigationControllerSwipeBackItem)

- (void)swipeBackView:(UISwipeGestureRecognizer *)recognizer;

@end

@implementation UIViewController (UINavigationControllerSwipeBackItem)

- (void)swipeBackView:(UISwipeGestureRecognizer *)recognizer
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end