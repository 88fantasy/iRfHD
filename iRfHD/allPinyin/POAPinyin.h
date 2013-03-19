//
//  POAPinyin.h
//  POA
//
//  Created by haung he on 11-7-18.
//  Copyright 2011年 huanghe. All rights reserved.
//

#import <Foundation/Foundation.h>


//rwe 20121225 added
typedef NS_ENUM(NSInteger, POAPinyinConvertMode) {
    POAPinyinConvertModeFull,           // 全拼返回
    POAPinyinConvertModeFullUpper,      // 全拼返回并全部大写
    POAPinyinConvertModeFirstWord       // 返回首字母
};

@interface POAPinyin : NSObject {
    
}

+ (NSString *) convert:(NSString *) hzString;//输入中文，返回拼音。

//  added by setimouse ( setimouse@gmail.com )  modifyed by rwe
+ (NSString *)quickConvert:(NSString *)hzString byConvertMode:(NSInteger)mode;
+ (void)clearCache;
//  ------------------

@end
