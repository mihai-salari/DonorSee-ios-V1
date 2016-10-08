//
//  VideoPlayer.h
//  DonorSee
//
//  Created by Bogdan on 10/8/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

@interface VideoPlayer : NSObject{
    
}

@property (nonatomic, strong) UIViewController *viewController;

- (void) playVideo: (NSString*) videoURL;

@end
