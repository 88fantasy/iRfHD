//
//  BasecodeStockList.h
//  iRf
//
//  Created by pro on 13-1-24.
//
//

#import <UIKit/UIKit.h>
#import "DataSetRequest.h"

@interface BasecodeStockList : UITableViewController
<ZBarReaderDelegate>
{
    
    DataSetRequest *request;
    NSArray *dataList;
    NSDictionary *conditions;
    
    @private NSArray *colors;

}

@property (nonatomic,strong) NSArray *dataList;
@property (nonatomic,strong) NSArray *colors;
@property (nonatomic,strong) NSDictionary *conditions;

@end
