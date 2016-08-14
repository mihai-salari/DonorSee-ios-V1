//
//  Activity.h
//  DonorSee
//
//  Created by star on 3/16/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject
{
    
}

@property (nonatomic, assign) int           activity_id;
@property (nonatomic, assign) int           receiver_user_id;
@property (nonatomic, assign) int           feed_id;
@property (nonatomic, assign) int           register_date;
@property (nonatomic, assign) int           type;
@property (nonatomic, assign) int           amount;
@property (nonatomic, assign) int           user_id;
@property (nonatomic, retain) NSString      *user_name;
@property (nonatomic, retain) NSString      *user_email;
@property (nonatomic, retain) NSString      *user_avatar;
@property (nonatomic, assign) int           object_id;
@property (nonatomic, assign) BOOL          is_read;
@property (nonatomic, assign) NSDate        *date;


@property (nonatomic, retain) Feed          *feed;

@property (nonatomic, retain) FollowMessage *followMessage;

- (id) initActivityWithDictionary: (NSDictionary*) dicItem;
@end
