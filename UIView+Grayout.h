//
//  UIView+Grayout.h
//  FadeOut
//
//  Created by Jon Manning on 28/04/2014.
//  Copyright (c) 2014 Secret Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

// Adds support for making any view go greyscaled and blurry.
@interface UIView (Grayout)

// The blurred, greyed-out view.
@property (strong) UIImageView* fadedView;

// Prepares the greyed-out view ahead of time.
- (void) prepareFadedView;

// Makes the view greyed-out and blurry.
- (void) fadeOut;

// Restores the view to its original state.
- (void) fadeIn;

@end
