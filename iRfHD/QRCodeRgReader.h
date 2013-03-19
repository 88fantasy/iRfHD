//
//  QRCodeRgReader.h
//  iRf
//
//  Created by pro on 13-3-5.
//
//

#import <UIKit/UIKit.h>

@interface QRCodeRgReader : UITableViewController
<ZBarReaderDelegate>
{
    NSArray *dataList;
    
    @private NSArray *fieldDictionary;
    @private NSString *uploadJSON;
}

@property (nonatomic,strong) NSArray *dataList;
@property (nonatomic,strong) NSArray *fieldDictionary;
@property (nonatomic,copy) NSString *uploadJSON;

extern NSString* const QRCodeRgReaderCellIdentifier;

@end
