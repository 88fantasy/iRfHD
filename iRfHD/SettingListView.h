//
//  SettingListView.h
//  iRf
//
//  Created by pro on 13-1-11.
//
//

#import <UIKit/UIKit.h>

@interface SettingListView : UITableViewController
<UITextFieldDelegate>
{
    NSMutableDictionary *settingData;
    UITextField *username;
    UITextField *password;
    UIButton *testBtn;
    UISwitch *internet;
    UITextField *server;
}

@property (nonatomic,strong) NSMutableDictionary *settingData;
@property (nonatomic,strong) UITextField *username;
@property (nonatomic,strong) UITextField *password;
@property (nonatomic,strong) UIButton *testBtn;
@property (nonatomic,strong) UISwitch *internet;
@property (nonatomic,strong) UITextField *server;

@end
