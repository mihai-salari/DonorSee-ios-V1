//
//  User.m
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initUserWithDictionary:(NSDictionary *)dicUser
{
    self = [super init];
    if(self)
    {
        self.user_id = [[dicUser valueForKey: @"id"] intValue];
        self.fb_id = [dicUser valueForKey: @"fb_id"];
        self.name = [dicUser valueForKey: @"name"];
        self.email = [dicUser valueForKey: @"email"];
        self.avatar = [dicUser valueForKey: @"avatar"];
        self.received_amount = [dicUser[@"received_amount"] floatValue];
        self.pay_amount = [dicUser[@"pay_amount"] floatValue];
        self.follower = [[dicUser valueForKey: @"follower"] intValue];
        self.following = [[dicUser valueForKey: @"following"] intValue];
        //self.followed = self.following;
        self.paypal = [dicUser valueForKey: @"paypal"];
    }
    return self;
}

- (id) initUserWithManagedObject:(NSManagedObject *)objUser
{
    self = [super init];
    if(self)
    {
        self.user_id = [[objUser valueForKey: @"user_id"] intValue];
        self.fb_id = [objUser valueForKey: @"fb_id"];
        self.name = [objUser valueForKey: @"name"];
        self.email = [objUser valueForKey: @"email"];
        self.avatar = [objUser valueForKey: @"avatar"];
        self.received_amount = [[objUser valueForKey: @"received_amount"] floatValue];
        self.pay_amount = [[objUser valueForKey: @"pay_amount"] floatValue];
        self.follower = [[objUser valueForKey: @"follower"] intValue];
        self.following = [[objUser valueForKey: @"following"] intValue];
        //self.followed = self.following;
        self.paypal = [objUser valueForKey: @"paypal"];
    }
    return self;
}

@end
