//
//  ViewController.m
//  ZDrawCircle
//
//  Created by howbuy on 15/6/1.
//  Copyright (c) 2015年 Michael. All rights reserved.
//

#import "ViewController.h"
#import "ZDrawCircle.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZDrawCircle *circle = [[ZDrawCircle alloc] initWithFrame:self.view.bounds];
    circle.needSpaceBetweenArc = YES;
    self.view = circle;
    
    // 1秒后开始绘制
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [circle startAnimationWithAngles:@[@(0.2), @(0.3), @(0.5)]
                                  colors:@[[UIColor redColor], [UIColor blueColor], [UIColor purpleColor]]
                              completion:^{
                                  
                              }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
