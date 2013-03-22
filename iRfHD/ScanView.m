//
//  ScanView.m
//  rf
//
//  Created by pro on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ScanView.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "DbUtil.h"
#import "RgView.h"
#import "RgListView.h"
#import "RootViewController.h"
#import "ScanOverlayView.h"
#import "MBProgressHUD.h"


@implementation ScanView

@synthesize resultImage, resultText,vswitch;
@synthesize _reader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[nibNameOrNil stringByAppendingString:@"HD"] bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        
//        //增加滑动手势操作
        
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
//        [panGesture setMaximumNumberOfTouches:2];
//        
//        [self.view addGestureRecognizer:panGesture];
//        
//        [panGesture release];
        
        // ADD: present a barcode reader that scans from the camera feed
        _reader = [ZBarReaderViewController new];
        _reader.readerDelegate = self;
        [_reader addScanLineOverlay];
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"扫描收货号"; 
    

    CGRect rect = self.resultText.frame;
    
    rect.size.height = 60;
    self.resultText.frame = rect;
}

#pragma mark ios6+纵向旋转控制需要以下3个 覆盖viewcontroller的方法
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}



//- (void) viewDidAppear:(BOOL)animated
//{
//
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (IBAction) cancelKeyboard:(id)sender{
    [sender resignFirstResponder];
}

#pragma mark scan and handles

- (IBAction) scanButtonTapped
{
    // present and release the controller
//    [self setOverView];
    [self presentViewController: _reader
							animated: YES
        completion:nil];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
	[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
	
    // EXAMPLE: do something useful with the barcode data
	
        
    resultText.text = symbol.data;
    
	if([vswitch isOn]){
		if ([resultText.text length]>0) {
			NSUInteger index = [resultText.text length] - 1;
			resultText.text = [resultText.text substringToIndex:index ];
		}
	}
	
    
    // EXAMPLE: do something useful with the barcode image
    resultImage.image =
	[info objectForKey: UIImagePickerControllerOriginalImage];
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
    
    
//    [self searchButtonTapped];
    
}


- (IBAction) searchButtonTapped {
	
    if ([resultText.text length] < 1) {
        [CommonUtil alert:NSLocalizedString(@"Error",@"Error") msg:@"条码为空,无法查询"];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = @"Loading";
    hud.removeFromSuperViewOnHide = YES;
    
    
    if ([RootViewController isSync] ) {
        FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
        if (db != nil) {
            FMResultSet *rs = [db executeQuery:@"select * from scm_rg where labelno = ?",resultText.text];
            NSMutableArray *rows =  [NSMutableArray array];
            while ([rs next]) {
                
                NSMutableDictionary *row =  [NSMutableDictionary dictionary];
                
                for (int i=0; i < [rs columnCount]; i++) {
                    NSString *key = [rs columnNameForIndex:i];
                    NSString *value = [rs stringForColumnIndex:i];
                    
                    if (value == nil) {
                        [row setObject:@"" forKey:key];
                    }
                    else {
                        [row setObject:value forKey:key];
                    }
                    
                }
                
                [rows addObject: row];
            }
            
            [db close];
            
            [self showRg:rows];
        }
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }
    else {
        iRfRgService* service = [iRfRgService service];
        //    service.logging = YES;
        NSLog(@"getrg开始");
        
        NSDictionary *setting = [CommonUtil getSettings];
        NSString *username = [setting objectForKey:kSettingUserKey];
        NSString *password = [setting objectForKey:kSettingPwdKey];
        
        [service getRg:self action:@selector(getRgHandler:) 
              username: username 
              password: password
               labelno: resultText.text];//resultText.text];1200010586734,1100009542948,0200009541779
        

    }
}

// Handle the response from getRg.

- (void) getRgHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接失败" 
                                                        message: [result localizedFailureReason]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"soap连接失败" 
                                                        message: [result faultString]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
	}				
    
    else{
        // Do something with the NSString* result
        NSString* result = (NSString*)value;
        //	resultText.text = [@"getRg returned the value: " stringByAppendingString:result] ;
        NSLog(@"%@", result);
        
        
        
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                
                [self showRg:rows];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [CommonUtil alert:NSLocalizedString(@"Error",@"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

-(void) showRg:(NSArray*)rows{
    NSUInteger count = [rows count];
    if (count <1) {
        [CommonUtil alert:@"提示" msg:@"找不到此收货号"];
    }
    else{
        if (count == 1) {
            NSDictionary *obj = (NSDictionary*)[rows objectAtIndex:0];
            RgView *rgView = [[RgView alloc] initWithNibName:@"RgView" bundle:nil values:obj ];
            //                    rgView.scanViewDelegate = self;
            [self.navigationController pushViewController:rgView animated:YES];
            
        }
        else{
            
            RgListView *rgListView =[[RgListView alloc] initWithStyle:UITableViewStylePlain
                                                                 objs:rows ];
            [self.navigationController pushViewController:rgListView animated:YES];
            
            
        }
        
    }
}

#pragma mark -
#pragma mark === Touch handling  ===

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    
//    // Disallow recognition of tap gestures in the segmented control.
//    UIView *view = [gestureRecognizer view];
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
//        CGPoint translation = [recognizer translationInView:[view superview]];
//        NSLog(@"x:%f y:%f",translation.x,translation.y);
//    }
//    
//    return YES;
//}

//- (void)panView:(UIPanGestureRecognizer *)gestureRecognizer{
//    
//    UIView *view = [gestureRecognizer view];
//    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
//    
//    NSInteger state = [gestureRecognizer state];
//    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [gestureRecognizer translationInView:[view superview]];
//        
//        [view setCenter:CGPointMake([view center].x + translation.x, [view center].y)];
//        [gestureRecognizer setTranslation:CGPointZero inView:[view superview]];
//    }
//    
//    if (state == UIGestureRecognizerStateCancelled || state == UIGestureRecognizerStateEnded) {
//        CGRect rect = GetScreenSize;
//        NSLog(@"x:%f y:%f",view.frame.origin.x,view.frame.origin.y);
//        if (view.frame.origin.x > rect.size.width * 0.4  ) { //超过40%屏幕
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//        else{
//            NSLog(@"x:%f y:%f",view.center.x,view.center.y);
//            [view setCenter:CGPointMake(view.superview.center.x, view.superview.center.y)];
//            NSLog(@"x:%f y:%f",view.center.x,view.center.y);
//        }
//    }
//}
//
//- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        UIView *view = gestureRecognizer.view;
//        CGPoint locationInView = [gestureRecognizer locationInView:view];
//        CGPoint locationInSuperview = [gestureRecognizer locationInView:view.superview];
//        
//        view.layer.anchorPoint = CGPointMake(locationInView.x / view.bounds.size.width, locationInView.y / view.bounds.size.height);
//        view.center = locationInSuperview;
//    }
//}

@end
