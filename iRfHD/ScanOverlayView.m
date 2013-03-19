//
//  ScanOverlayView.m
//  iRf
//
//  Created by pro on 12-12-20.
//
//

#import "ScanOverlayView.h"

@implementation ScanOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor whiteColor];
        self.opaque = NO;
		self.clearsContextBeforeDrawing = YES;
        self.alpha = 0.5;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleBottomMargin 
//                                UIViewAutoresizingFlexibleHeight |
//                                UIViewAutoresizingFlexibleWidth
        ;
        
        _dashPhase = 0.0;
//        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)setDashPhase:(CGFloat)phase
{
	if(phase != _dashPhase)
	{
		_dashPhase = phase;
		[self setNeedsDisplay];
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)drawRect:(CGRect)rect
{
	// Since we use the CGContextRef a lot, it is convienient for our demonstration classes to do the real work
	// inside of a method that passes the context as a parameter, rather than having to query the context
	// continuously, or setup that parameter for every subclass.
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

-(void)drawInContext:(CGContextRef)context
{
    CGRect frame = GetScreenSize;
    CGFloat length = 240;
    
    CGFloat left = frame.size.width / 2 - length;
    CGFloat right = frame.size.width / 2 + length;
    CGFloat y = frame.size.height / 2;
    CGFloat linewidth = 2.0;
//
//    CGRect newframe = frame;
//    newframe.size.height = frame.size.height - 54;  //减去底部工具栏高度
//    newframe.size.width = frame.size.width;
//    //获取当前电池条的方向
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (UIInterfaceOrientationIsLandscape(orientation)) {
    
        
//        newframe.size.height = frame.size.width - 31;
//        newframe.size.width = frame.size.height;
//        
//        left = newframe.size.width * 0.25;
//        right = newframe.size.width * 0.75;
//        y = newframe.size.height /  2 ;
        
//        linewidth = linewidth * 2;
//    }
//
//    if (self.frame.size.height != newframe.size.height || self.frame.size.width!= newframe.size.width) {
//        self.frame = newframe;
//    }
//    else{
//        
//    }
    
    
    
    //画直线
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, linewidth);
	
	// Draw a single line from left to right
	CGContextMoveToPoint(context, left, y);
	CGContextAddLineToPoint(context, right, y);
	CGContextStrokePath(context);
    
    
	
//    if (UIInterfaceOrientationIsPortrait(orientation)) {
    
        
        //画虚线 正方形
        
        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
        
        CGContextSetLineWidth(context, linewidth);
        CGContextMoveToPoint(context, left, y - length );
        CGContextAddLineToPoint(context, left + length / 2, y - length );
        CGContextMoveToPoint(context, left, y - length );
        CGContextAddLineToPoint(context, left, y - length / 2 );
        
        CGContextMoveToPoint(context, right, y - length );
        CGContextAddLineToPoint(context, right - length / 2, y - length );
        CGContextMoveToPoint(context, right, y - length );
        CGContextAddLineToPoint(context, right, y - length / 2 );
        
        CGContextMoveToPoint(context, left, y + length );
        CGContextAddLineToPoint(context, left + length / 2, y + length );
        CGContextMoveToPoint(context, left, y + length );
        CGContextAddLineToPoint(context, left, y + length / 2);
        
        CGContextMoveToPoint(context, right, y + length );
        CGContextAddLineToPoint(context, right - length / 2, y + length );
        CGContextMoveToPoint(context, right, y + length );
        CGContextAddLineToPoint(context, right, y + length / 2);
        
//        CGFloat pattern[] = {10,10};
//        CGContextSetLineDash(context, _dashPhase, pattern, 2);
//        CGContextAddRect(context, CGRectMake(left , y - length /2 , length, length));
        
        CGContextStrokePath(context);
//    }
}

@end


@implementation ZBarReaderViewController (ZBarReaderViewControllerScanLineOverlayView)

-(void)addScanLineOverlay
{
    ScanOverlayView *over = [[ScanOverlayView alloc]initWithFrame:GetScreenSize];
    [self setCameraOverlayView: over];
}

@end