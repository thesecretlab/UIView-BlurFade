//
//  UIView+Grayout.m
//  FadeOut
//
//  Created by Jon Manning on 28/04/2014.
//  Copyright (c) 2014 Secret Lab. All rights reserved.
//

#import "UIView+Grayout.h"
#import <objc/runtime.h>

// Import Core Image to do the blurring and greyscaling,
// and QuartzCore to do the fading.
@import CoreImage;
@import QuartzCore;

// A string key used to associate the faded view with this view.
const char* FADEVIEWKEY = "SLUIViewGrayoutView";

@implementation UIView (Grayout)

@dynamic fadedView;

// Get the faded image view associated with this view.
- (UIImageView*)fadedView {
    return objc_getAssociatedObject(self, FADEVIEWKEY);
}

// Set the faded image view for this view.
- (void) setFadedView:(UIImageView*)fadeView {
    objc_setAssociatedObject(self, FADEVIEWKEY, fadeView, OBJC_ASSOCIATION_RETAIN);
}

// Prepares the faded view. This can take a moment, so you
// should call this ahead of time (for example, during
// viewDidLoad in your view controller.)
- (void) prepareFadedView {
    
    // Don't bother re-generating the faded view if we already
    // have one.
    if (self.fadedView != nil)
        return;
    
    // Get the content scale of the screen, so that we get nice
    // retina versions if this is a retina display
    float scale = [UIScreen mainScreen].scale;
    
    // Create the filters for blurring and graying out the
    // image.
    CIFilter* hueAdjust;
    CIFilter* blurAdjust;
    
    blurAdjust = [CIFilter filterWithName:@"CIGaussianBlur"];
    hueAdjust = [CIFilter filterWithName:@"CIColorControls"];
    
    // Snapshot the view into an image. (This is the main
    // time-sink of the whole process.)
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    // Take the snapshotted image, blur it, and grayscale it.
    
    CIImage* originalImage = [CIImage imageWithCGImage:image.CGImage];
    
    [blurAdjust setValue:originalImage forKey:kCIInputImageKey];
    [blurAdjust setValue:@3 forKey:kCIInputRadiusKey];
    
    CIImage* blurredImage = [blurAdjust valueForKey:kCIOutputImageKey];
    
    [hueAdjust setValue:blurredImage forKey:kCIInputImageKey];
    [hueAdjust setValue:@0.0 forKey:kCIInputSaturationKey];
    
    CIImage* outputImage = [hueAdjust valueForKey:kCIOutputImageKey];
    
    // Convert the result to a UIImage. (This is another time-sink, since
    // we need to pull pixels from the GPU into the CPU, which is slow.
    
    UIImage* fadedImage = [UIImage imageWithCIImage:outputImage scale:scale orientation:UIImageOrientationUp];
    
    // Because the image will have grown in size (because of the blurring),
    // we need to create a rectangle that takes into account the new size
    // and position. It also needs to take the image scale into account.
    
    CGRect frame = fadedImage.CIImage.extent;
    frame.origin.x /= scale;
    frame.origin.y /= scale;
    
    frame.origin.x += self.frame.origin.x;
    frame.origin.y += self.frame.origin.y;
    
    frame.size.width /= scale;
    frame.size.height /= scale;
    
    // We're done! Create the image view with the frame and give it the image.
    
    self.fadedView = [[UIImageView alloc] initWithFrame:frame];
    self.fadedView.image = fadedImage;
}

- (void)fadeOut {
    
    // If we don't have the faded view already, prepare it.
    
    if (self.fadedView == nil)
        [self prepareFadedView];
    
    // Add the view to the screen, make it be at the right position,
    // and make it transparent.
    
    [self.superview addSubview:self.fadedView];
    self.fadedView.center = self.center;
    self.fadedView.alpha = 0.0;
    self.alpha = 1.0;
    
    // Fade it in, while fading the original out.
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.fadedView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0.0;
        }];
        
    }];
    
}

- (void)fadeIn {
    
    // If we don't have the faded view already, prepare it.
    if (self.fadedView == nil)
        [self prepareFadedView];
    
    // Make sure the original view is in the same place as the faded view.
    
    self.center = self.fadedView.center;
    
    // Make sure the faded view is fully visible.
    self.fadedView.alpha = 1.0;
    self.alpha = 0.0;
    
    [self.fadedView.superview insertSubview:self.fadedView belowSubview:self];
    
    // Fade the faded view out, and fade the original in. When done, remove the faded view from the screen.
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.fadedView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.fadedView removeFromSuperview];
        }];
        
        
    }];
}

@end
