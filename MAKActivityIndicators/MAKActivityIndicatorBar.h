//
//  MAKActivityIndicatorBar.h
//  MAKActivityIndicators
//
//  Created by Martin Kloepfel on 26.06.15.
//  Copyright (c) 2015 Martin Kloepfel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MAKActivityIndicatorBar : UIView

@property (nonatomic, readonly) BOOL isAnimating;

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) NSArray *tintColors;

@property (nonatomic) BOOL hidesWhenStopped;


- (void)startAnimating;
- (void)stopAnimating;

@end
