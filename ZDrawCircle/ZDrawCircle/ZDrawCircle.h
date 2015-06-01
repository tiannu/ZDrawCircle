//
//  ZDrawCircle.h
//
//
//  Created by howbuy on 15/4/9.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDrawCircle : UIView

@property (nonatomic, assign) BOOL needAnimation;       // 加载圆圈需要动画
@property (nonatomic, assign) BOOL needSpaceBetweenArc; // 不同颜色圆弧之间需要间隙

/**
 *  @Author 占昊儒
 *
 *  开始动画
 *
 *  @param angleValues 弧度的值数组(数组中得内容为CGFloat类型)(所有数值的总和为1.0)
 *  @param colors      相应的数组(数组中得内容为UIColor类型)(需要与弧度数组个数一致)
 *  @param lineWidth   线条宽度(默认40)
 */
- (void)startAnimationWithAngles:(NSArray *)angleValues
                          colors:(NSArray *)colors
                      completion:(void (^)())completion;
- (void)startAnimationWithAngles:(NSArray *)angleValues
                          colors:(NSArray *)colors
                       lineWidth:(CGFloat)lineWidth
                      completion:(void (^)())completion;

@end
