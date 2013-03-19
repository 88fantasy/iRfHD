//
//  DbUtil.h
//  iRf
//
//  Created by pro on 12-11-23.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DbUtil : NSObject


//使用项目文件重建数据库
+ (FMDatabase*) rebuildForResource:(NSString *)name ofType:(NSString *)ext;

//使用文件创建数据库链接
+ (FMDatabase*) retConnectionForResource:(NSString *)name ofType:(NSString *)ext;

@end
