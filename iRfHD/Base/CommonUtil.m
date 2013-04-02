//
//  CommonUtil.m
//  iRf
//
//  Created by pro on 12-11-24.
//
//

#import "CommonUtil.h"
#import "ASIFormDataRequest.h"
#import "iRfAppDelegate.h"
#import "GRAlertView.h"

@implementation CommonUtil

static NSString *settingPath;
static NSDictionary *settingData;
static NSHTTPCookie *_session;

+ (void) alert:(NSString*)title msg:(NSString*)msg
{
    // open an alert with just an OK button
//    iRfAppDelegate *appdelegate = (iRfAppDelegate*) [[UIApplication sharedApplication] delegate];
//    
//    UIPopoverController
//    appdelegate.navigationController.
    
    GRAlertView *alert = [[GRAlertView alloc] initWithTitle:title message:msg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alert.animation = alert.animation = GRAlertAnimationLines;
    if ([title isEqualToString:NSLocalizedString(@"Info", @"Info")]) {
        alert.style = GRAlertStyleInfo;
        [alert setImage:@"info.png"];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Error", @"Error")]) {
        alert.style = GRAlertStyleAlert;
        alert.animation = GRAlertAnimationBorder;
        [alert setImage:@"alert.png"];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Success", @"Success")]) {
        alert.style = GRAlertStyleSuccess;
        [alert setImage:@"accept.png"];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Warning", @"Warning")]) {
        alert.style = GRAlertStyleWarning;
    }
    [alert show];
}

+ (NSString*) getSettingPath
{
    
    if (!settingPath) {
        //获取应用程序沙盒的Documents目录
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        settingPath =  [documentDirectory stringByAppendingPathComponent:@"setting.plist"];
        
        NSLog(@"setting path = %@",settingPath);
    }
    return [settingPath copy];
}

+ (NSDictionary *) getSettings
{
    if (!settingData) {
        [CommonUtil rebuildSetting];
    }
    return [settingData copy];
}

+ (NSDictionary *) rebuildSetting
{
    NSString *settingPath = [self getSettingPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:settingPath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"true",kSettingInternetKey,
                              nil];
        NSString *error;
        
        NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:dict
                                                                     format:NSPropertyListXMLFormat_v1_0
                                                           errorDescription:&error];
        if(xmlData) {
            [xmlData writeToFile:settingPath atomically:YES];
        }
        else {
            NSLog(@"error = %@",error);
        }
    }
    
    settingData = [[NSDictionary alloc] initWithContentsOfFile:settingPath];
    NSLog(@"setting data = %@", settingData);
    return [settingData copy];
}

+ (NSString*) getLocalServerBase
{
    NSDictionary *settingData = [CommonUtil getSettings];
    NSString *serverurl = [settingData objectForKey:kSettingServerKey];
    NSRange range = [serverurl rangeOfString:@"/" options:NSCaseInsensitiveSearch];
    if (range.length == 0) {
        serverurl = [NSString stringWithFormat:@"%@/hscm",serverurl];
    }
    NSRange range2 = [serverurl rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
    if (range2.length == 0) {
        serverurl = [NSString stringWithFormat:@"http://%@",serverurl];
    }
    return serverurl;
}

+ (NSHTTPCookie*) getSession
{
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    return [CommonUtil getSessionByUsername:username password:password];
}

+ (NSHTTPCookie*) getSessionByUsername:(NSString*)username password:(NSString*)password
{
    if (!_session) {
        _session = nil;
        
        NSString *httpurl = [[NSString alloc]initWithFormat:@"%@%@",[CommonUtil getLocalServerBase] ,@"/loginactionservlet"];
        NSURL *url = [NSURL URLWithString:httpurl];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:username forKey:@"username"];
        [request setPostValue:password forKey:@"password"];
        [request startSynchronous];
        NSError *error = [request error];
        if (!error) {
            
            NSDictionary *headers = [request responseHeaders];
            NSString *setcookie = [headers objectForKey:@"Set-Cookie"];
            if (setcookie != nil) {
                
                NSArray *cookies = [setcookie componentsSeparatedByString:@";"];
                
                NSArray *sessions = [[cookies objectAtIndex:0] componentsSeparatedByString:@"="];
                
                NSArray *paths = [[cookies objectAtIndex:1] componentsSeparatedByString:@"="];
                
                //Create a cookie
                NSMutableDictionary *properties = [NSMutableDictionary dictionary] ;
                [properties setValue:[sessions objectAtIndex:1] forKey:NSHTTPCookieValue];
                [properties setValue:[sessions objectAtIndex:0] forKey:NSHTTPCookieName];
                [properties setValue:@".gzmpc.com" forKey:NSHTTPCookieDomain];
                [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
                [properties setValue:[paths objectAtIndex:1] forKey:NSHTTPCookiePath];
                _session = [[NSHTTPCookie alloc] initWithProperties:properties];
                
                NSLog(@"登录的cookie：%@", setcookie);
                
                
            }
            
            // Use when fetching text data
            NSString *responseString = [request responseString];
            NSDictionary *nsd = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSLog(@"login return : %@",responseString);
            NSString *success = [nsd objectForKey:@"success"];
            
            if ([success boolValue]) {
//                [CommonUtil alert:NSLocalizedString(@"Info", @"Info") msg:@"登陆成功"];
            }
            else {
                [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:[nsd objectForKey:@"error"]];
            }
        }
        else {
            [CommonUtil alert:@"服务器端错误" msg:[error localizedDescription]];
        }
    }
    return _session;
}


+ (NSString *) stringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

+ (NSString *) stringFromDateTime:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

@end
