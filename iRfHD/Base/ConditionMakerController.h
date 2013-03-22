//
//  ConditionMakerController.h
//  iRfHD
//
//  Created by pro on 13-3-20.
//  Copyright (c) 2013年 rwe. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kConditionMakerFieldNameKey @"fieldname"
#define kConditionMakerFieldTextKey @"labeltext"
#define kConditionMakerInputTypeKey @"inputtype"
#define kConditionMakerCellKey @"fieldcell"


typedef NS_OPTIONS(NSUInteger, ConditionMakerInputType) {
    ConditionMakerInputTypeText = 0,          
    ConditionMakerInputTypeDate,
    ConditionMakerInputTypeSwitch,
    ConditionMakerInputTypeSegment
};
typedef NS_OPTIONS(NSUInteger, ConditionMakerMode) {
    ConditionMakerModeSingle = 0,
    ConditionMakerModeMulti
};

@protocol ConditionMakerControllerDelegate;

@interface ConditionMakerController : UITableViewController
<UITextFieldDelegate>
{
    NSArray *fieldDictionaryList;
    __weak id<ConditionMakerControllerDelegate> delegate;
    
    NSInteger controllermode;
    
    @private
    NSMutableDictionary *_fieldValues;
}

@property (nonatomic,strong) NSArray *fieldDictionaryList;
@property (nonatomic,weak) id<ConditionMakerControllerDelegate> delegate;
@property (nonatomic) NSInteger controllermode;

+ (id)controllerWithMode:(ConditionMakerMode)mode style:(UITableViewStyle)style fields:(NSArray*)fieldlist;

-(NSDictionary*) getConditions;

@end

@protocol ConditionMakerControllerDelegate <NSObject>

@optional
-(void)conditionDidMaked:(NSDictionary*)makedconditions;

@end
