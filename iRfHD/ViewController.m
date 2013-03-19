//
//  ViewController.m
//  iRf
//
//  Created by pro on 12-11-29.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//为兼容ios6的旋转控制,需要子类化以下2个方法,供实际view覆盖
- (BOOL) shouldAutorotate
{
    return self.topViewController.shouldAutorotate; 
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
