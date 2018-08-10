//
//  ViewController.m
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/7.
//  Copyright © 2018年 peizhuo. All rights reserved.
//


#import "ViewController.h"
#import "UIImage+TranslateColor.h"
#import <RKAPPMonitorView/RKAPPMonitorView.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarItem;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *pixelView;

@property (weak, nonatomic) IBOutlet UILabel *pixelLabel;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation ViewController

// MARK: - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef DEBUG
    RKAPPMonitorView *monitorView = [[RKAPPMonitorView alloc] initWithOrigin:CGPointMake(10, 100)];
    [[UIApplication sharedApplication].keyWindow addSubview:monitorView];
#else
    
#endif

}


// MARK: - Action

- (IBAction)executionGradientAnimation:(UIBarButtonItem *)sender {
    sender.enabled = false;
    
    [self beginTimerWithInvalidateDelay:5];
}

- (void)translateColorWithProgress:(CGFloat)progress {
    if (progress > 1) {
        self.imageView.image = [UIImage imageNamed:@"demo"];
        return;
    }
//    NSLog(@"progress: %.f%%", progress*100);

    UIImage *image = self.imageView.image;
    CGRect rect = CGRectZero;

    int row = 2;
    if (progress >= 0.5) {
        CGFloat p = progress - 0.5;
        rect = CGRectMake(0, image.size.height/row, image.size.width*p*row, image.size.height/row);
    } else {
        rect = CGRectMake(0, 0, image.size.width*progress*row, image.size.height/row);
    }
    
    image = [image translatePixelColorByTargetNearBlackColor:[UIColor colorWithRGBHex:0x000000]
                                              nearWhiteColor:[UIColor colorWithRGBHex:0x323232]
                                                  transColor:[UIColor redColor]
                                                      inRect:rect];
//    image = [image translatePixelColorByTargetNearBlackColorHex:0x000000 nearWhiteColorHex:0x323232 transColorHex:0xFF0000 inRect:rect];
    
    self.imageView.image = image;
}


- (void)colorMeterAtPoint:(CGPoint)point {
    if (!CGRectContainsPoint(self.imageView.frame, point)) { return; }
    
    CGPoint convertPoint = [self.view convertPoint:point toView:self.imageView];
    
    UIImage *image = [UIImage screenshotWithView:self.imageView];
    
    UIColor *color = [image pixelColorAtPoint:convertPoint];
    
    self.pixelView.backgroundColor = color;
    self.pixelLabel.text = [NSString stringWithFormat:@"0x%X", color.RGB];
}

- (void)beginTimerWithInvalidateDelay:(NSTimeInterval)delay {   // GCD定时器
    __block NSTimeInterval cancel = delay;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, NSEC_PER_MSEC * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        cancel -= 0.1;
        
        if (cancel <= 0) {
            dispatch_source_cancel(timer);
            self.rightBarItem.enabled = true;
        }
        
        [self translateColorWithProgress:1-cancel/delay];
    });
    dispatch_resume(timer);
    
    self.timer = timer;
}


// MARK: - Touch Action

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    CGPoint touchPoint = [touches.anyObject locationInView:self.view];
    [self colorMeterAtPoint:touchPoint];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint touchPoint = [touches.anyObject locationInView:self.view];
    [self colorMeterAtPoint:touchPoint];
}




@end






















