//
//  ViewController.m
//  FadeOut
//
//  Created by Jon Manning on 28/04/2014.
//  Copyright (c) 2014 Secret Lab. All rights reserved.
//

#import "ViewController.h"

#import "UIView+Grayout.h"

@import CoreImage;
@import QuartzCore;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *fadeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [self.fadeView prepareFadedView];
}

- (IBAction)fadeViewOut:(id)sender {
    
    [self.fadeView fadeOut];

}

- (IBAction)fadeViewIn:(id)sender {
    
    [self.fadeView fadeIn];
    
}

@end
