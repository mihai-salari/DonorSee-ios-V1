//
//  FollowMessage.m
//  DonorSee
//
//  Created by star on 3/24/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "FollowMessage.h"

@implementation FollowMessage


- (id) initWithDictionary: (NSDictionary*) dicItem
{
    self = [super init];
    if(self)
    {
        self.message_id = [dicItem[@"id"] intValue];
        self.feed_id = [dicItem[@"feed_id"] intValue];
        self.register_date = [dicItem[@"register_date"] intValue];
        self.user_id = [dicItem[@"user_id"] intValue];
        self.message = dicItem[@"message"];
        
        NSString* strPhotos = dicItem[@"photos"];
        if(strPhotos != nil && [strPhotos length] > 0)
        {
            self.arrPhotos = [strPhotos componentsSeparatedByString: @","];
        }
    }
    return self;
}

@end
