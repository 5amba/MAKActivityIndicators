//
//  MAKActivityIndicatorBar.m
//  MAKActivityIndicators
//
//  Created by Martin Kloepfel on 26.06.15.
//  Copyright (c) 2015 Martin Kloepfel. All rights reserved.
//

#import "MAKLoadingIndicatorBar.h"

#import <FrameAccessor/FrameAccessor.h>


@interface MAKActivityIndicatorBar ()

@property (nonatomic) BOOL animating;

@property (nonatomic, strong) UIView *clipView;

@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) NSArray *gradientChunks;


@property (nonatomic) NSUInteger animationCounter;

@end


@implementation MAKActivityIndicatorBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clipView = [[UIView alloc] initWithFrame:self.bounds];
        self.clipView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.clipView.layer.masksToBounds = YES;
        self.clipView.layer.shouldRasterize = YES;
        self.clipView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self addSubview:self.clipView];
        
        self.trackView = [[UIView alloc] initWithFrame:CGRectMake(-self.clipView.width*2, 0.0, self.clipView.width*2, self.clipView.height)];
        self.trackView.layer.masksToBounds = YES;
        self.trackView.layer.shouldRasterize = YES;
        self.trackView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.clipView addSubview:self.trackView];
        
        CAGradientLayer *firstGradientLayer = [CAGradientLayer new];
        firstGradientLayer.opaque = NO;
        firstGradientLayer.masksToBounds = YES;
        firstGradientLayer.shouldRasterize = YES;
        firstGradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
        firstGradientLayer.frame = CGRectMake(0.0, 0.0, self.clipView.width, self.trackView.height);
        firstGradientLayer.startPoint = CGPointZero;
        firstGradientLayer.endPoint = CGPointMake(1.0, 0.0);
        firstGradientLayer.colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, (id)[UIColor blueColor].CGColor];
        [self.trackView.layer addSublayer:firstGradientLayer];
        
        CAGradientLayer *secondGradientLayer = [CAGradientLayer new];
        secondGradientLayer.opaque = NO;
        secondGradientLayer.masksToBounds = YES;
        secondGradientLayer.shouldRasterize = YES;
        secondGradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
        secondGradientLayer.frame = CGRectMake(firstGradientLayer.frame.size.width, 0.0, self.clipView.width, self.trackView.height);
        secondGradientLayer.startPoint = CGPointZero;
        secondGradientLayer.endPoint = CGPointMake(1.0, 0.0);
        secondGradientLayer.colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, (id)[UIColor blueColor].CGColor];
        [self.trackView.layer addSublayer:secondGradientLayer];
        
        self.gradientChunks = @[firstGradientLayer, secondGradientLayer];
        
        self.hidesWhenStopped = YES;
    }
    return self;
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
    _hidesWhenStopped = hidesWhenStopped;
    
    if (!self.isAnimating)
        [self setHidden:hidesWhenStopped animated:NO];
}


- (void)setTintColor:(UIColor *)tintColor
{
    if (![tintColor isKindOfClass:[UIColor class]])
        return; //TODO: exeption!
    
    for (CAGradientLayer *gradientLayer in self.gradientChunks)
        gradientLayer.colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, (id)tintColor.CGColor];
}

- (UIColor *)tintColor
{
    CGColorRef colorRef = (__bridge CGColorRef)((id)((CAGradientLayer *)self.gradientChunks.firstObject).colors.lastObject);
    
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
    
    for (CAGradientLayer *gradientLayer in self.gradientChunks)
        gradientLayer.colors = mutableTintColors;
}

- (NSArray *)tintColors
{
    NSMutableArray *mutableTintColors = [NSMutableArray new];
    
    for (id color in ((CAGradientLayer *)self.gradientChunks.firstObject).colors)
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
    self.animationCounter = 0;
    
    [self animateTrackView];
    [self setHidden:NO animated:YES];
}

- (void)stopAnimating
{
    self.animating = NO;
    [self setHidden:YES animated:YES];
}


- (void)animateTrackView
{
    if (!self.isAnimating)
        return;
    
    self.trackView.frame = CGRectMake(-self.clipView.width, 0.0, self.clipView.width*2, self.clipView.height);

    NSUInteger i = 0;
    for (CAGradientLayer *gradientLayer in self.gradientChunks)
    {
        gradientLayer.frame = CGRectMake(i*self.clipView.width, 0.0, self.clipView.width, self.trackView.height);
        i++;
    }
    
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
            self.trackView.frame = CGRectMake(0.0, 0.0, self.trackView.width, self.trackView.height);
    
    } completion:^(BOOL finished) {
        if (!self.isAnimating)
            return;
        
        [self animateTrackView];
    }];
}


- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
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
                         }];
    }
}

@end
