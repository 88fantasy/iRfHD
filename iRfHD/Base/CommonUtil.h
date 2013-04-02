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

+ (NSString *) stringFromDate:(NSDate *)date;

+ (NSString *) stringFromDateTime:(NSDate *)date;

@end



#pragma mark -
#pragma mark makeconditions
#define MakeConditionFieldName @"fieldName"
#define MakeConditionOpera @"opera"
#define MakeConditionValue1 @"value1"

NS_INLINE NSDictionary* NSMakeConditionCeq(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,MakeConditionFieldName,
            @"oper_equal",MakeConditionOpera,
            value,MakeConditionValue1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCnoteq(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,MakeConditionFieldName,
            @"oper_no_equal",MakeConditionOpera,
            value,MakeConditionValue1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionClike(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,MakeConditionFieldName,
            @"oper_like",MakeConditionOpera,
            value,MakeConditionValue1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCbig(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,MakeConditionFieldName,
            @"oper_big",MakeConditionOpera,
            value,MakeConditionValue1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCbigEqual(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,MakeConditionFieldName,
            @"oper_big_equal",MakeConditionOpera,
            value,MakeConditionValue1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCsmall(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,MakeConditionFieldName,
            @"oper_small",MakeConditionOpera,
            value,MakeConditionValue1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCsmallEqual(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,MakeConditionFieldName,
            @"oper_small_equal",MakeConditionOpera,
            value,MakeConditionValue1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCin(NSString *fieldname, NSString *value) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:fieldname,MakeConditionFieldName,
            @"oper_in",MakeConditionOpera,
            value,MakeConditionValue1,nil];
};

NS_INLINE NSDictionary* NSMakeConditionCstr(NSString *str) {
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"cstr",MakeConditionFieldName,
            @"oper_str",MakeConditionOpera,
            str,MakeConditionValue1,nil];
};
