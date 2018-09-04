//
//  ViewController.m
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/7.
//  Copyright © 2018年 peizhuo. All rights reserved.
//


#import "ViewController.h"
#import <RKAPPMonitorView/RKAPPMonitorView.h>
#import "UIImage+TranslateColor.h"
#import "PageViewController.h"
#import "KaraokeModule.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarItem;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *pixelView;

@property (weak, nonatomic) IBOutlet UILabel *pixelLabel;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) NSArray<NSString *> *dataSource;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PushPageViewController"] || [segue.destinationViewController isKindOfClass:PageViewController.class]) {
        PageViewController *pageViewController = (PageViewController *)segue.destinationViewController;
        pageViewController.dataSource = self.dataSource;
    }
    
}

- (IBAction)executionGradientAnimation:(UIBarButtonItem *)sender {
    sender.enabled = false;
    
    UIImage *image = [UIImage imageNamed:@"demo"];
    
    KaraokeModule *module = [[KaraokeModule alloc] init];
    [module configurationImage:image inRect:self.imageView.frame dataSource:[self karaokeDataSource]];
    
    UIImageView *imageView = module.imageView;
    [self.view addSubview:imageView];
    
    [module beginKaraokeAnimation];
    
    module.karaokeDidEnd = ^{
        sender.enabled = true;
        [imageView removeFromSuperview];
    };
}


- (void)colorMeterAtPoint:(CGPoint)point {
    if (!CGRectContainsPoint(self.imageView.frame, point)) { return; }
    
    CGPoint convertPoint = [self.view convertPoint:point toView:self.imageView];
    
    UIImage *image = [UIImage screenshotWithView:self.imageView];
    
    UIColor *color = [image pixelColorAtPoint:convertPoint];
    
    self.pixelView.backgroundColor = color;
    self.pixelLabel.text = [NSString stringWithFormat:@"0x%X", color.RGB];
}

- (NSArray<KaraokeModel *> *)karaokeDataSource {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"lrc" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    
    NSArray<NSDictionary *> *metaAry = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableArray<KaraokeModel *> *array = [NSMutableArray arrayWithCapacity:metaAry.count];
    for (NSDictionary *dic in metaAry) {
        KaraokeModel *model = [[KaraokeModel alloc] init];
        model.content = dic[@"content"];
        model.begin = [dic[@"begin"] floatValue];
        model.end = [dic[@"end"] floatValue];
        model.x = [dic[@"x"] floatValue];
        model.y = [dic[@"y"] floatValue];
        model.width = [dic[@"width"] floatValue];
        model.height = [dic[@"height"] floatValue];
        
        [array addObject:model];
    }
    
    return array;
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


// MARK: - Getter & Setter

- (NSArray<NSString *> *)dataSource {
    if (!_dataSource) {
        NSInteger count = 19;
        NSMutableArray<NSString *> *array = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 0; i < count; i++) {
            NSString *str = @"单独编译MTFramework项目时，需要在模拟器和真机环境下各编译一次（真机环境编译的只能在真机环境运行，模拟器同理），然后在Products下的MTFramework.framework上右键，选择show in finder，可以看到模拟器和真机编译生成的framework。\n合并模拟器和真机的编译文件需要使用终端命令，且合并的并不是MTFramework.framework本身，而是其内部的MTFramework二进制文件。命令如下：\nlipo -create 第一个framework下二进制文件的绝对路径 第二个framework下二进制文件的绝对路径 -output 最终的二进制文件路径\n";
            
            [array addObject:str];
        }
        
        _dataSource = [NSArray arrayWithArray:array];
    }
    return _dataSource;
}





@end






















