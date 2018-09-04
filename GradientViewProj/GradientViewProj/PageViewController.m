//
//  PageViewController.m
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/14.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import "PageViewController.h"
#import "PageContentViewController.h"

@interface PageViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, weak) UIPageViewController *pageViewController;

/** 复用池 */
@property (nonatomic, strong) NSMutableSet<PageContentViewController *> *reusePool;

/** 当前页码索引：从0开始 */
@property (nonatomic, assign) NSUInteger currenIndex;

/** 预览页码索引：翻页较快时将会出现上一次翻页动画还没结束，下一次动画已经执行，此时currenIndex还没改变，故增加此参数用于快速预览 */
@property (nonatomic, assign) NSUInteger previewIndex;

@end

@implementation PageViewController

@synthesize dataSource = _dataSource;


// MARK: - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initSubviews];
}

// MARK: - Action

- (PageContentViewController *)pageContentViewControllerAtIndex:(NSUInteger)index {
    if (index == NSNotFound) { return nil; }
    
    PageContentViewController *contentVC = [self.reusePool anyObject]; // 从复用池中取出任意一个复用对象

    // 赋值
    contentVC.contentLabel.text = self.dataSource[index];
    contentVC.pageLabel.text = [NSString stringWithFormat:@"Page %ld", index];
    contentVC.index = index;
    
    [self.reusePool removeObject:contentVC];    // 接下来将要显示，从复用池中移除
    
    return contentVC;
}

- (NSArray<PageContentViewController *> *)getInitialPageContentViewControllersWithDoubleSided:(BOOL)doubleSided {
    NSInteger count = doubleSided ? 2 : 1;
    if (count+self.currenIndex >= self.dataSource.count-1) { return nil; }
    
    NSMutableArray<PageContentViewController *> *array = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = self.currenIndex; i < count+self.currenIndex; i++) {
        PageContentViewController *contentVC = [self pageContentViewControllerAtIndex:i];
        [array addObject:contentVC];
    }
    
    return [NSArray arrayWithArray:array];
}


// MARK: - UIPageViewControllerDataSource

// 向前翻页
- (PageContentViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(PageContentViewController *)viewController {
    
    if (self.previewIndex == 0) {
        return nil;
    }
    
    NSLog(@"向前翻页: %ld", self.currenIndex);
    
    self.previewIndex--;
    return [self pageContentViewControllerAtIndex:self.previewIndex];
}

// 向后翻页
- (PageContentViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(PageContentViewController *)viewController {
    
    NSInteger endFlag = pageViewController.doubleSided ? 2 : 1;
    if (self.previewIndex >= self.dataSource.count-endFlag) {
        return nil;
    }
    
    if (pageViewController.doubleSided && self.currenIndex % 2 == 0) {
        self.currenIndex++;
        self.previewIndex = self.currenIndex;
    }
    NSLog(@"向后翻页: %ld", self.currenIndex);

    self.previewIndex++;
    return [self pageContentViewControllerAtIndex:self.previewIndex];
}



// MARK: - UIPageViewControllerDelegate

// 将要开始翻页
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSLog(@"将要开始翻页");
}

// 已经结束翻页
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<PageContentViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (finished && completed) {
        for (PageContentViewController *pageContentViewController in previousViewControllers) {
//            [pageContentViewController resetSubviewsContent];           // 重置UI。也可不重置，但要注意复用问题
            [self.reusePool addObject:pageContentViewController]; // 视图在屏幕上已经不可见，将其加入复用池
//            NSLog(@"+++++复用池大小：%ld+++++", self.reusePool.count);
        }
    }
    
    if (pageViewController.viewControllers.count > 0) {
        PageContentViewController *contentVC = pageViewController.viewControllers.firstObject;
        self.currenIndex = contentVC.index;
        self.previewIndex = self.currenIndex;   // 翻页结束后将previewIndex与currenIndex同步，以避免预览页码偏移。
    }
    
    
    NSLog(@"已经结束翻页，当前页码: %ld", self.currenIndex);
}


- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    UIPageViewControllerSpineLocation spineLocation = UIPageViewControllerSpineLocationMin;
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            spineLocation = UIPageViewControllerSpineLocationMid;
            pageViewController.doubleSided = true;
            break;
        }
        default: {
            spineLocation = UIPageViewControllerSpineLocationMin;
            pageViewController.doubleSided = false;
            break;
        }
    }
    
    NSArray<PageContentViewController *> *viewControllers = [self getInitialPageContentViewControllersWithDoubleSided:pageViewController.doubleSided];
    [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:true completion:^(BOOL finished) {
    }];
    
    return spineLocation;
}

- (UIInterfaceOrientationMask)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController {
    return UIInterfaceOrientationPortrait;
}



// MARK: - Setter & Getter

- (NSArray<NSString *> *)dataSource {
    // 如果当前处于双页模式且数据源数量为奇数，则为数据源补1到偶数，避免无法翻到最后一页的问题
    if (self.pageViewController.doubleSided && _dataSource.count %2 == 1) {
        NSMutableArray *mAry = [NSMutableArray arrayWithCapacity:_dataSource.count+1];
        [mAry addObjectsFromArray:_dataSource];
        [mAry addObject:@""];
        
        _dataSource = [NSArray arrayWithArray:mAry];
    }
    
    return _dataSource;
}


- (NSMutableSet<PageContentViewController *> *)reusePool {
    if (_reusePool.count == 0) {
        NSMutableSet *temp = [[NSMutableSet alloc] init];
        
        for (int i = 0; i < 2; i++) { // 复用池中默认预载2个可复用对象
            PageContentViewController *contentVC = [[PageContentViewController alloc] init];
            [temp addObject:contentVC];
        }
        
        _reusePool = temp;
    }
    return _reusePool;
}

// MARK: - UI

- (void)initSubviews {
    
    // 真实翻页效果
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey: @(UIPageViewControllerSpineLocationMin)}];
    
    // 平移翻页效果
//    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @(20)}];
    
    pageViewController.dataSource = self;
    pageViewController.delegate = self;
//    pageViewController.doubleSided = true;
    
    NSArray<PageContentViewController *> *viewControllers = [self getInitialPageContentViewControllersWithDoubleSided:pageViewController.doubleSided];
    [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:true completion:^(BOOL finished) {
    }];
    
    
    pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];
    
    self.pageViewController = pageViewController;
}


@end

































