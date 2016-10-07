//
//  PlayerViewController.m
//  DonorSee
//
//  Created by Oleksii Pelekh on 10/7/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:@"https://res.cloudinary.com/donorsee/video/upload/v1475263379/development/cnds2bb57ff7yqf4h6wm.mp4"]];
    
    AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
    playerController.player = player;
    playerController.showsPlaybackControls = YES;
    [self addChildViewController:playerController];
    
    UIView *container = self.view;
    UIView *subview = playerController.view;
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [container addSubview:subview];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    
    [container addConstraints:@[top, leading, bottom, trailing]];
    
    [player play];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
