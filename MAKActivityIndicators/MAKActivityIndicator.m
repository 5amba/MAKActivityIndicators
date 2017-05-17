//
//  MAKActivityIndicator.m
//  MAKActivityIndicators
//
//  Created by Martin Kloepfel on 12.07.15.
//  Copyright (c) 2015 Martin Kloepfel. All rights reserved.
//

#import "MAKLoadingIndicator.h"

#import <AngleGradientLayer/AngleGradientLayer.h>


@interface MAKActivityIndicator ()

@property (nonatomic) BOOL animating;

@property (nonatomic, strong) CALayer *contentLayer;

@property (nonatomic, strong) AngleGradientLayer *angleGradientLayer;
@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end


@implementation MAKActivityIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.contentLayer = [CALayer new];
        self.contentLayer.frame = self.bounds;
        [self.layer addSublayer:self.contentLayer];
        
        self.angleGradientLayer = [AngleGradientLayer new];
        self.angleGradientLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.angleGradientLayer.frame = self.contentLayer.bounds;
        self.angleGradientLayer.colors = @[(id)self.tintColor.CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
        self.angleGradientLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, 1.0);
        self.angleGradientLayer.masksToBounds = YES;
        [self.contentLayer addSublayer:self.angleGradientLayer];
        
        CAShapeLayer *circleLayer = [CAShapeLayer new];
        circleLayer.frame = CGRectMake(1.0, 1.0,
                                       self.angleGradientLayer.frame.size.width-2.0, self.angleGradientLayer.frame.size.height-2.0);
        circleLayer.fillColor = [UIColor clearColor].CGColor;
        circleLayer.strokeColor = [UIColor blackColor].CGColor;
        circleLayer.lineWidth = 2.0;
        circleLayer.path = CGPathCreateWithEllipseInRect(circleLayer.bounds, nil);
        self.angleGradientLayer.mask = circleLayer;
        
        self.hidesWhenStopped = YES;
    }
    return self;
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
    _hidesWhenStopped = hidesWhenStopped;
    
    if (!self.isAnimating)
        [self setHidden:hidesWhenStopped animated:NO completion:nil];
}


- (void)setTintColor:(UIColor *)tintColor
{
    if (![tintColor isKindOfClass:[UIColor class]])
        return; //TODO: exeption!
    
    self.angleGradientLayer.colors = @[(id)tintColor.CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
}

- (UIColor *)tintColor
{
    CGColorRef colorRef = (__bridge CGColorRef)((id)((AngleGradientLayer *)self.angleGradientLayer).colors.firstObject);
    
    if (colorRef)
        return [UIColor colorWithCGColor:colorRef];
    return nil;
}

- (void)setTintColors:(NSArray *)tintColors
{
    if (![tintColors isKindOfClass:[NSArray class]]  || tintColors.count < 2)
        return; //TODO: exeption!
    
    
    NSMutableArray *mutableTintColors = [NSMutableArray new];
    
    for (UIColor *color in tintColors)
    {
        if (![color isKindOfClass:[UIColor class]])
            return; //TODO: exeption!
        
        [mutableTintColors addObject:(id)color.CGColor];
    }
    
    self.angleGradientLayer.colors = mutableTintColors;
}

- (NSArray *)tintColors
{
    NSMutableArray *mutableTintColors = [NSMutableArray new];
    
    for (id color in ((CAGradientLayer *)self.angleGradientLayer).colors)
    {
        CGColorRef colorRef = (__bridge CGColorRef)((id)color);
        [mutableTintColors addObject:[UIColor colorWithCGColor:colorRef]];
    }
    
    return [NSArray arrayWithArray:mutableTintColors];
}


- (BOOL)isAnimating
{
    return self.animating;
}

- (void)startAnimating
{
    if (self.isAnimating)
        return;
    
    self.animating = YES;
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    
    double temp;
    CFTimeInterval timeInterval = modf(CACurrentMediaTime(), &temp);
//    timeInterval *= 1.0;
    
    rotationAnimation.fromValue = @((M_PI*2)*timeInterval);
    rotationAnimation.byValue = @(M_PI*2);
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = INFINITY;
    [self.contentLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [self setHidden:NO animated:YES completion:nil];
}

- (void)stopAnimating
{
    self.animating = NO;
    
    __weak MAKLoadingIndicator *weakSelf = self;
    
    [self setHidden:YES animated:YES completion:^(BOOL finished) {
        if (finished)
            [weakSelf.contentLayer removeAnimationForKey:@"rotationAnimation"];
    }];
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
{
    if (!animated)
    {
        self.alpha = hidden ? 0.0 : 1.0;
        self.hidden = hidden;
    }
    else
    {
        static BOOL animating = NO;
        
        if (self.hidden == hidden && !animating)
            return;
        
        
        if (!animating)
        {
            self.alpha = hidden ? 1.0 : 0.0;
            self.hidden = NO;
        }
        
        animating = YES;
        
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.alpha = hidden ? 0.0 : 1.0;
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                                 self.hidden = hidden;
                             animating = NO;
                             
                             if (completion)
                                 completion(finished);
                         }];
    }
}

@end
