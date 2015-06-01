//
//  ZDrawCircle.m
//  
//
//  Created by howbuy on 15/4/9.
//  Copyright (c) 2015年 . All rights reserved.
//

#import "ZDrawCircle.h"

#define kTotalAnimationTimes 0.5
#define kArcsDis (0.005 * M_PI)  // 弧之间的间隙

@interface HBCircleItem : NSObject

@property (nonatomic, strong) CAShapeLayer *drawLayer;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CGFloat animationTimes;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;

@end

@implementation HBCircleItem

- (CAShapeLayer *)drawLayer {
    if (!_drawLayer) {
        _drawLayer = [CAShapeLayer layer];
        _drawLayer.frame = self.bounds;
        _drawLayer.backgroundColor = nil;
        _drawLayer.fillColor = nil;
        _drawLayer.strokeColor = self.lineColor.CGColor;
        _drawLayer.lineWidth = self.lineWidth;
    }
    return _drawLayer;
}

- (CGFloat)lineWidth {
    if (!_lineWidth) {
        _lineWidth = 1;
    }
    return _lineWidth;
}

@end

@interface ZDrawCircle ()

@property (nonatomic, strong) NSMutableArray *drawItems;


@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat drawLineWidth;

@property (nonatomic, copy) void (^animationCompletion)();

@end

@implementation ZDrawCircle

- (instancetype)init {
    if (self = [super init]) {
        self.needAnimation = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.needAnimation = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.needAnimation = YES;
    }
    return self;
}

#pragma mark - get/set
//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
////    CGContextRef context = UIGraphicsGetCurrentContext();
////    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
////    CGContextSetLineWidth(context, 10);
////    
////    CGContextAddArc(context, self.bounds.size.width / 2, self.bounds.size.height / 2, self.bounds.size.height / 2 - 50, 2 * M_PI, M_PI * 3 / 2, 1); //添加一个圆
////    CGContextDrawPath(context, kCGPathStroke); //绘制路径
////    
////    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
////    CGContextAddArc(context, self.bounds.size.width / 2, self.bounds.size.height / 2, self.bounds.size.height / 2 - 50, M_PI * 3 / 2, M_PI, 1); //添加一个圆
////    CGContextDrawPath(context, kCGPathStroke); //绘制路径
////    
////    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
////    CGContextAddArc(context, self.bounds.size.width / 2, self.bounds.size.height / 2, self.bounds.size.height / 2 - 50, M_PI, 0, 1); //添加一个圆
////    CGContextDrawPath(context, kCGPathStroke); //绘制路径
//}

/**
 *  @Author 占昊儒
 *
 *  开始动画
 *
 *  @param angleValues 弧度的值数组
 *  @param colors      相应的数组（需要与弧度数组个数一致）
 *  @param lineWidth   线条宽度
 */

- (void)startAnimationWithAngles:(NSArray *)angleValues
                          colors:(NSArray *)colors
                      completion:(void (^)())completion {
    [self startAnimationWithAngles:angleValues
                            colors:colors
                         lineWidth:40
                        completion:completion];
}
- (void)startAnimationWithAngles:(NSArray *)angleValues
                          colors:(NSArray *)colors
                       lineWidth:(CGFloat)lineWidth
                      completion:(void (^)())completion {
    if (angleValues.count != colors.count) {
        NSLog(@"绘制圆圈的传入数据有错");
        return;
    }
    
    self.animationCompletion = completion;
    
    if (self.drawItems.count > 0) {
        // 清除原来的绘画
        for (NSInteger i = 0; i < self.drawItems.count; i++) {
            HBCircleItem *item = (HBCircleItem *)self.drawItems[i];
            [item.drawLayer removeFromSuperlayer];
        }
        [self.drawItems removeAllObjects];
    }
    else {
        self.drawItems = @[].mutableCopy;
    }
    
    CGFloat center_x = self.bounds.size.width / 2;
    CGFloat center_y = self.bounds.size.height / 2;
    self.drawLineWidth = lineWidth;
    
    /* 添加户型的动画路径与动画时间 */
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != %@", @(0.0)];
    NSArray *array = [angleValues filteredArrayUsingPredicate:predicate];
    
    CGFloat lastAngle = M_PI / 2;
    for (NSInteger i = 0; i < angleValues.count; i++) {
        if ([angleValues[i] floatValue] == 0.0) {
            continue;
        }
        
        lastAngle += self.needSpaceBetweenArc? kArcsDis : 0;
        CGFloat endAngle = lastAngle + (2 * M_PI - (self.needSpaceBetweenArc ? array.count * kArcsDis : 0)) * [angleValues[i] floatValue];
        
        // 路径
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        linePath.usesEvenOddFillRule = YES;
        [linePath addArcWithCenter:CGPointMake(center_x, center_y)
                            radius:(self.bounds.size.width / 2) - (lineWidth / 2)
                        startAngle: lastAngle
                          endAngle: endAngle
                         clockwise:YES];
        
        // 动画时间
        CGFloat animationTimes = [angleValues[i] floatValue] * kTotalAnimationTimes;
        
        lastAngle = endAngle;
        
        HBCircleItem *item = [[HBCircleItem alloc] init];
        item.animationTimes = animationTimes;
        item.path = linePath;
        item.lineColor = colors[i];
        item.lineWidth = lineWidth;
        [self.drawItems addObject:item];
    }
    
    /* 启动动画 */
    self.currentIndex = 0;
    [self updateAnimation];
}

/**
 *  @Author 占昊儒
 *
 *  进行动画
 */
- (void)updateAnimation {
    if (self.drawItems.count <= 0) {
        CGFloat center_x = self.bounds.size.width / 2;
        CGFloat center_y = self.bounds.size.height / 2;
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        linePath.usesEvenOddFillRule = YES;
        [linePath addArcWithCenter:CGPointMake(center_x, center_y)
                            radius:(self.bounds.size.width / 2) - (self.drawLineWidth / 2)
                        startAngle:M_PI / 2
                          endAngle:M_PI / 2 + 2 * M_PI
                         clockwise:YES];
        
        HBCircleItem *noneItem = [[HBCircleItem alloc] init];
        noneItem.lineColor = [UIColor grayColor];
        noneItem.lineWidth = self.drawLineWidth;
        noneItem.drawLayer.frame = self.bounds;
        noneItem.drawLayer.path = [linePath CGPath];
        [self.layer addSublayer:noneItem.drawLayer];
        [self.drawItems addObject:noneItem];
        if (self.animationCompletion) {
            self.animationCompletion();
        }
        return;
    }
    
    if (self.drawItems.count <= self.currentIndex) {
        if (self.animationCompletion) {
            self.animationCompletion();
        }
        return;
    }
    
    HBCircleItem *item = self.drawItems[self.currentIndex];
    
    item.drawLayer.frame = self.bounds;
    item.drawLayer.path = [item.path CGPath];
    
    if (self.needAnimation) { // 添加动画
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = item.animationTimes;
        pathAnimation.fromValue = @(0.0);
        pathAnimation.toValue = @(1.0);
        pathAnimation.delegate = self;
        [item.drawLayer addAnimation:pathAnimation forKey:@"drawLine"];
        [self.layer addSublayer:item.drawLayer];
    }
    else { // 无动画
        [self.layer addSublayer:item.drawLayer];
        self.currentIndex++;
        [self updateAnimation];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        self.currentIndex++;
        [self updateAnimation];
    }
}

@end
