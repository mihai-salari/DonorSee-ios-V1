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
    
    _videoURL = [self getValidatedVideoUrl: _videoURL];
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:_videoURL]];
    
    AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
    playerController.player = player;
    playerController.showsPlaybackControls = YES;
    [self presentViewController:playerController animated:YES completion:nil];
    playerController.view.frame = self.view.frame;
    
    [player play];
}

- (NSString*) getValidatedVideoUrl: (NSString*) videoURL {
    NSString* result;
    
    NSRange lastDot = [_videoURL rangeOfString:@"." options:NSBackwardsSearch];
    if(lastDot.location != NSNotFound) {
        result = [_videoURL substringToIndex:lastDot.location];
        result = [result stringByAppendingString:@".mp4"];
    }
    
    return result;
}

- (BOOL)shouldAutorotate {
    return YES;
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
