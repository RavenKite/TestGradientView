//
//  PageContentViewController.m
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/14.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import "PageContentViewController.h"
#import <Masonry/Masonry.h>

@interface PageContentViewController ()

@property (nonatomic, weak) UILabel *contentLabel;

@property (nonatomic, weak) UILabel *pageLabel;

@property (nonatomic, assign, getter=isVisible) BOOL visible;


@end

@implementation PageContentViewController

// MARK: - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

}


// MARK: - UI

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.numberOfLines = 0;
        contentLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightLight];
        
        [self.view addSubview:contentLabel];
        
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(contentLabel.superview);
            make.width.lessThanOrEqualTo(contentLabel.superview).multipliedBy(0.95);
        }];

        _contentLabel = contentLabel;
    }
    
    return _contentLabel;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        UILabel *pageLabel = [[UILabel alloc] init];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
        
        [self.view addSubview:pageLabel];
        
        [pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(pageLabel.superview);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(pageLabel.superview.mas_safeAreaLayoutGuideBottom).offset(-12);
            } else {
                make.bottom.equalTo(pageLabel.superview).offset(-12);
            }
        }];
        
        _pageLabel = pageLabel;
    }
    
    return _pageLabel;
}

- (void)initSubviews {
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightLight];
    
    UILabel *pageLabel = [[UILabel alloc] init];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
    
    
    [self.view addSubview:contentLabel];
    [self.view addSubview:pageLabel];
    
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(contentLabel.superview);
        make.width.lessThanOrEqualTo(contentLabel.superview).multipliedBy(0.95);
    }];
    
    [pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(pageLabel.superview);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(pageLabel.superview.mas_safeAreaLayoutGuideBottom).offset(-12);
        } else {
            make.bottom.equalTo(pageLabel.superview).offset(-12);
        }
    }];
    
    self.contentLabel = contentLabel;
    self.pageLabel = pageLabel;
}


- (void)resetSubviewsContent {
    
    self.contentLabel.text = nil;
    self.pageLabel.text = nil;
    
}


@end





























