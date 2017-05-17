//
//  MAKActivityIndicator.h
//  MAKActivityIndicators
//
//  Created by Martin Kloepfel on 12.07.15.
//  Copyright (c) 2015 Martin Kloepfel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MAKActivityIndicator : UIView

@property (nonatomic, readonly) BOOL isAnimating;

//@property (nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSArray *tintColors UI_APPEARANCE_SELECTOR;

@property (nonatomic) BOOL hidesWhenStopped;


- (void)startAnimating;
- (void)stopAnimating;

@end
