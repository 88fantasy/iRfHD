//
//  BasecodeStockList.h
//  iRf
//
//  Created by pro on 13-1-24.
//
//

#import <UIKit/UIKit.h>
#import "DataSetRequest.h"
#import "ConditionMakerController.h"

@interface BasecodeStockList : UITableViewController
<ZBarReaderDelegate,UIPopoverControllerDelegate,ConditionMakerControllerDelegate>
{
    
    DataSetRequest *request;
    NSArray *dataList;
    NSDictionary *conditions;
    
    @private NSArray *colors;

    UIPopoverController *searchPopOver;
}

@property (nonatomic,strong) NSArray *dataList;
@property (nonatomic,strong) NSArray *colors;
@property (nonatomic,strong) NSDictionary *conditions;
@property (nonatomic,strong) UIPopoverController *searchPopOver;

@end
