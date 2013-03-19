//
//  ScanOverlayView.h
//  iRf
//
//  Created by pro on 12-12-20.
//
//

#import <UIKit/UIKit.h>

@interface ScanOverlayView : UIView
{
    CGFloat _dashPhase;
    NSTimer *timer;
}

@property(nonatomic, readwrite) CGFloat dashPhase;

-(void)drawInContext:(CGContextRef)context;

@end


@interface ZBarReaderViewController (ZBarReaderViewControllerScanLineOverlayView)

-(void)addScanLineOverlay;

@end
