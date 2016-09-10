//
//  Notification.m
//  DonorSee
//
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "Notification.h"

@implementation Notification

- (id) initWithDictionary: (NSDictionary*) dicItem
{
    self = [super init];
    if(self)
    {
        self.notification_id = [dicItem[@"notification_id"] intValue];
        self.feed_id = [dicItem[@"feed_id"] intValue];
        self.user_id = [dicItem[@"user_id"] intValue];
        self.is_read = [dicItem[@"is_read"] intValue];
        self.user_avatar = dicItem[@"avatar"];
        self.type = [dicItem[@"type"] intValue];
        
        NSString *message = dicItem[@"message"];
        NSString* result = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        self.message = result;
        self.pic = dicItem[@"pic"];
        self.register_date = [dicItem[@"register_date"] intValue];
        
        self.feed = [[Feed alloc] init];
        self.feed.feed_id = [NSString stringWithFormat: @"%d", self.feed_id];
        self.feed.feed_description = @"";
        self.feed.photo = [AppEngine getValidString: dicItem[@"pic"]];
        
        self.date = [NSDate dateWithTimeIntervalSince1970: self.register_date];
    }
    return self;
}

@end
