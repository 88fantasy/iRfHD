//
//  BAMethod.h
//  IMpc
//
//  Created by pro on 11-3-24.
//  Copyright 2011 gzmpc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "ASIFormDataRequest.h"

@interface BAMethod : NSObject
<ASIHTTPRequestDelegate>
{
    NSString *className;
    NSString *moduleId;
    NSString *methodName;
    BOOL _async;
    
    NSMutableArray *sessionCookie;
//    NSString *base;
    
    @private id target;
    @private SEL action;
}

@property (nonatomic,strong) NSString *className;
@property (nonatomic,strong) NSString *moduleId;
@property (nonatomic,strong) NSString *methodName;

//@property (nonatomic,strong) NSString *base;
@property (nonatomic,strong) NSMutableArray *sessionCookie;

//@property (nonatomic,strong) id _target;
//@property (nonatomic,assign) SEL _action;

-(id)initWithClassName:(NSString *)classname;


-(void)invokeByAsync:(NSArray *)params target:(id) _target action:(SEL) _action;
-(id)invokeBySync:(NSArray *)params;

+(BAMethod *) baWithClassName:(NSString*)_className moduleId:(NSString*)_moduleid methodName:(NSString*)_methodName;

@end
