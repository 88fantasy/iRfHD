//
//  CommonUtil.h
//  iRf
//
//  Created by pro on 12-11-24.
//
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSObjCRuntime.h>


@interface CommonUtil : NSObject
{

}

+ (void) alert:(NSString*)title msg:(NSString*)msg;

+ (NSString*) getSettingPath;

+ (NSDictionary*) getSettings;

+ (NSDictionary*) rebuildSetting;

+ (NSString*) getLocalServerBase;

+ (NSHTTPCookie*) getSession;

+ (NSHTTPCookie*) getSessionByUsername:(NSString*)username password:(NSString*)password;

@end



#pragma mark -
#pragma mark makeconditions
static const NSString *fieldName =@"fieldName";
static const NSString *opera = @"opera";
static const NSString *value1 = @"value1";

NS_INLINE NSDictionary* NSMakeConditionCeq(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,fieldName,
            @"oper_equal",opera,
            value,value1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCnoteq(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,fieldName,
            @"oper_no_equal",opera,
            value,value1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionClike(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,fieldName,
            @"oper_like",opera,
            value,value1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCbig(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,fieldName,
            @"oper_big",opera,
            value,value1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCbigEqual(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,fieldName,
            @"oper_big_equal",opera,
            value,value1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCsmall(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,fieldName,
            @"oper_small",opera,
            value,value1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCsmallEqual(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,fieldName,
            @"oper_small_equal",opera,
            value,value1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCin(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,fieldName,
            @"oper_in",opera,
            value,value1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCstr(NSString *str) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"cstr",fieldName,
            @"oper_str",opera,
            str,value1,nil];
};
