//
//  VideoPlayer.m
//  DonorSee
//
//  Created by Bogdan on 10/8/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoPlayer.h"

@implementation VideoPlayer : NSObject

- (void) playVideo: (NSString*) videoURL{
    videoURL = [self getValidatedVideoUrl:videoURL];
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString: videoURL]];
    
    AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
    playerController.player = player;
    playerController.showsPlaybackControls = YES;
    [_viewController presentViewController:playerController animated:YES completion:nil];
    playerController.view.frame = _viewController.view.frame;
    
    [player play];

}

- (NSString*) getValidatedVideoUrl: (NSString*) videoURL {
    NSString* result;
    
    NSRange lastDot = [videoURL rangeOfString:@"." options:NSBackwardsSearch];
    if(lastDot.location != NSNotFound) {
        result = [videoURL substringToIndex:lastDot.location];
        result = [result stringByAppendingString:@".mp4"];
    }
    
    return result;
}


@end
