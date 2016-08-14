//
//  Activity.m
//  DonorSee
//
//  Created by star on 3/16/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "Activity.h"

@implementation Activity
@synthesize activity_id;
@synthesize receiver_user_id;
@synthesize feed_id;
@synthesize register_date;
@synthesize type;
@synthesize amount;
@synthesize user_id;
@synthesize user_name;
@synthesize user_email;

- (id) initActivityWithDictionary: (NSDictionary*) dicItem
{
    self = [super init];
    if(self)
    {
        self.activity_id = [dicItem[@"activity_id"] intValue];
        self.receiver_user_id = [dicItem[@"receiver_user_id"] intValue];
        self.feed_id = [dicItem[@"feed_id"] intValue];
        self.register_date = [dicItem[@"register_date"] intValue];
        self.type = [dicItem[@"type"] intValue];
        self.amount = [dicItem[@"amount"] intValue];
        self.user_id = [dicItem[@"user_id"] intValue];
        self.user_name = dicItem[@"name"];
        self.user_email = dicItem[@"email"];
        self.user_avatar = dicItem[@"avatar"];
        self.object_id = [dicItem[@"object_id"] intValue];
        self.is_read = [dicItem[@"is_read"] boolValue];
        
        self.feed = [[Feed alloc] init];
        self.feed.feed_id = [NSString stringWithFormat: @"%d", self.feed_id];
        self.feed.feed_description = [AppEngine getValidString: dicItem[@"description"]];
        self.feed.donated_amount = [dicItem[@"donated_amount"] intValue];
        self.feed.photo = [AppEngine getValidString: dicItem[@"photo"]];
        self.feed.pre_amount = [dicItem[@"pre_amount"] intValue];
        self.feed.post_user_id = [dicItem[@"post_user_id"] intValue];
        
        self.date = [NSDate dateWithTimeIntervalSince1970: self.register_date];
    }
    return self;
}
@end
