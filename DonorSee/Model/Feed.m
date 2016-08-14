//
//  Feed.m
//  DonorSee
//
//  Created by star on 3/1/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "Feed.h"

@implementation Feed
@synthesize postUser;

- (id) initWithDictionary: (NSDictionary*) dicFeed
{
    self = [super init];
    if(self)
    {
        self.feed_id = [dicFeed valueForKey: @"feed_id"];
        self.feed_description = [dicFeed valueForKey: @"description"];
        self.photo = [dicFeed valueForKey: @"photo"];
        self.pre_amount = [[dicFeed valueForKey: @"pre_amount"] intValue];
        self.donated_amount = [[dicFeed valueForKey: @"donated_amount"] intValue];
        self.post_user_id = [[dicFeed valueForKey: @"post_user_id"] intValue];
        self.register_date = [dicFeed valueForKey: @"created_at"];
        self.arrUsers = [NSMutableArray array];
        self.donated_user_count = [dicFeed[@"donated_user_count"] intValue];
        self.donated_count = [dicFeed[@"donated_count"] intValue];
        self.is_gave = [dicFeed[@"is_gave"] boolValue];
        self.stripe_user_id = [dicFeed valueForKey:@"stripe_user_id"];
    }
    return self;
}

- (id) initWithManagedObject: (NSManagedObject*) objFeed
{
    self = [super init];
    if(self)
    {
        self.feed_id = [objFeed valueForKey: @"feed_id"];
        self.feed_description = [objFeed valueForKey: @"feed_description"];
        self.photo = [objFeed valueForKey: @"photo"];
        self.pre_amount = [[objFeed valueForKey: @"pre_amount"] intValue];
        self.donated_amount = [[objFeed valueForKey: @"donated_amount"] intValue];
        self.post_user_id = [[objFeed valueForKey: @"post_user_id"] intValue];
        self.register_date = [objFeed valueForKey: @"created_at"];
        self.arrUsers = [NSMutableArray array];
    }
    return self;
}

- (id) initWithHomeFeed: (NSDictionary*) dicFeed
{
    self = [super init];
    if(self)
    {
        NSDictionary *ownerUser = [dicFeed objectForKey:@"owner"];
        
        self.feed_id = [dicFeed valueForKey: @"id"];
        self.feed_description = [dicFeed valueForKey: @"description"];
        self.photo = [dicFeed valueForKey: @"photo"];
        self.pre_amount = [[dicFeed valueForKey: @"goal_amount"] intValue];
        //self.donated_amount = [[dicFeed valueForKey: @"donated_amount"] intValue];
        self.post_user_id = [[ownerUser valueForKey: @"id"] intValue];
        self.register_date = [dicFeed valueForKey: @"created_at"];
        //self.donated_user_count = [dicFeed[@"donated_user_count"] intValue];
        //self.donated_count = [dicFeed[@"donated_count"] intValue];
        //self.is_gave = [dicFeed[@"is_gave"] boolValue];
        //self.stripe_user_id = [dicFeed valueForKey:@"stripe_user_id"];
        
        NSString* email = [ownerUser valueForKey: @"email"];
        NSString* name = [NSString stringWithFormat:@"%@ %@", [ownerUser valueForKey: @"first_name"], [ownerUser valueForKey: @"last_name"]];
        
        postUser = [[User alloc] init];
        postUser.user_id = self.post_user_id;
        //postUser.fb_id = dicFeed[@"fb_id"];
        postUser.name = name;
        postUser.email = email;
//        postUser.follower = [dicFeed[@"follower"] intValue];
//        postUser.following = [dicFeed[@"following"] intValue];
//        postUser.followed = [dicFeed[@"is_followed"] boolValue];
        postUser.paypal = dicFeed[@"paypal"];
        postUser.avatar = ownerUser[@"photo"];
    }
    
    return self;
    
}

- (id) initWithProfileFeed: (NSDictionary*) dicFeed
{
    self = [super init];
    if(self)
    {
        self.feed_id = [dicFeed valueForKey: @"feed_id"];
        self.feed_description = [dicFeed valueForKey: @"description"];
        self.photo = [dicFeed valueForKey: @"photo"];
        self.pre_amount = [[dicFeed valueForKey: @"pre_amount"] intValue];
        self.donated_amount = [[dicFeed valueForKey: @"donated_amount"] intValue];
        self.post_user_id = [[dicFeed valueForKey: @"post_user_id"] intValue];
        self.register_date = [dicFeed valueForKey: @"created_at"];
        self.is_gave = [dicFeed[@"is_gave"] boolValue];        
        self.arrUsers = [NSMutableArray array];
        self.stripe_user_id =[dicFeed valueForKey:@"stripe_user_id"];
        
        if([[dicFeed allKeys] containsObject: @"donated_user_count"])
        {
            self.donated_user_count = [[dicFeed valueForKey: @"donated_user_count"] intValue];
            self.donated_count = [dicFeed[@"donated_count"] intValue];
        }
        
        if([[dicFeed allKeys] containsObject: @"poster_name"])
        {
            self.postUser = [[User alloc] init];
            self.postUser.user_id = self.post_user_id;
            self.postUser.name = [dicFeed valueForKey: @"poster_name"];
            self.postUser.email = [dicFeed valueForKey: @"poster_email"];
            self.postUser.avatar = postUser.avatar = dicFeed[@"avatar"];
            self.postUser.follower = [[dicFeed valueForKey: @"poster_follower"] intValue];
            self.postUser.following = [[dicFeed valueForKey: @"poster_following"] intValue];
            self.postUser.paypal = dicFeed[@"paypal"];
        }
        
        if([[dicFeed allKeys] containsObject: @"id"] && ![[dicFeed valueForKey: @"id"] isKindOfClass: [NSNull class]])
        {
            int user_id = [[dicFeed valueForKey: @"id"] intValue];
            NSString* email = [dicFeed valueForKey: @"email"];
            NSString* name = [dicFeed valueForKey: @"name"];
            
            User* u = [[User alloc] init];
            u.user_id = user_id;
            u.name = name;
            u.email = email;
//            u.avatar = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", u.fb_id];
            
            [self.arrUsers addObject: u];
        }
    }
    
    return self;
}

- (void) mergeFeed: (Feed*) f
{
    if(f.arrUsers != nil && [f.arrUsers count] > 0)
    {
        for(User* u in f.arrUsers)
        {
            [self.arrUsers addObject: u];
        }
    }
}

- (User*) getUserInfo: (int) index
{
    return [self.arrUsers objectAtIndex: index];
}

- (NSArray*) getDonatedUsernames
{
    if(self.arrUsers != nil && [self.arrUsers count] > 0)
    {
        NSMutableArray* arrNames = [[NSMutableArray alloc] init];
        for(User* u in self.arrUsers)
        {
            if(u.name != nil)
            {
                [arrNames addObject: u.name];
            }
        }
        
        return arrNames;
    }
    
    return nil;
}

- (DONATED_STATUS) getDonatedStatus
{
    NSArray* arrNames = [self getDonatedUsernames];
    if(arrNames != nil && [arrNames count] > 0)
    {
        //Full Donated.
        if(self.donated_amount >= self.pre_amount)
        {
            return FULL_DONATED;
        }
        else
        {
            return DONATING;
        }
    }
    else
    {
        return NO_DONATED;
    }
}


- (BOOL) isCreatedByCurrentUser
{
    if(self.post_user_id == [AppEngine sharedInstance].currentUser.user_id)
    {
        return YES;
    }
    
    return NO;
}

@end
