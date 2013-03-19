//
//  DbUtil.m
//  iRf
//
//  Created by pro on 12-11-23.
//
//

#import "DbUtil.h"

@implementation DbUtil


+ (FMDatabase*) rebuildForResource:(NSString *)name ofType:(NSString *)ext {
    //paths： ios下Document路径，Document为ios中可读写的文件夹
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //dbPath： 数据库路径，在Document中。
    NSString *filename = [name stringByAppendingString:@"."];
    filename = [filename stringByAppendingString:ext];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:filename];
    NSLog(@"%@",dbPath);
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    NSLog(@"%@",sourcePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    if ([fileManager fileExistsAtPath:dbPath]) {
        if (![fileManager removeItemAtPath:dbPath error:&error]) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    if (![fileManager copyItemAtPath:sourcePath toPath:dbPath error:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    error = nil;
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        db = nil;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Error",@"Error")
                            message:[@"无法打开数据库:"stringByAppendingString:filename]
                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    return db;
}

+ (FMDatabase*) retConnectionForResource:(NSString *)name ofType:(NSString *)ext {
    //paths： ios下Document路径，Document为ios中可读写的文件夹
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //dbPath： 数据库路径，在Document中。
    NSString *filename = [name stringByAppendingString:@"."];
    filename = [filename stringByAppendingString:ext];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    FMDatabase *db = nil;
    NSString *errormsg = nil;
    if ([fileManager fileExistsAtPath:dbPath]) {
        db = [FMDatabase databaseWithPath:dbPath];
        
        if (![db open]) {
            db = nil;
            errormsg = [@"无法打开数据库:"stringByAppendingString:filename];
        }
    }
    else{
        errormsg = [filename stringByAppendingString: @"文件不存在"];
    }
    if (errormsg != nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Error",@"Error")
                                message:errormsg
                               delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
        [alert show];
    }
    
    return db;
}


@end
