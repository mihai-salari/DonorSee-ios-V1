//
//  Feed.h
//  DonorSee
//
//  Created by star on 3/1/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feed : NSObject
{
    
}

@property (nonatomic, strong) NSString          *feed_id;
@property (nonatomic, strong) NSNumber          *owner_id;
@property (nonatomic, strong) NSString          *feed_description;
@property (nonatomic, strong) NSString          *photo;
@property (nonatomic, strong) NSString          *videoURL;
@property (nonatomic, assign) NSString          *register_date;
@property (nonatomic, strong) NSDate            *created_at;
@property (nonatomic, assign) int               pre_amount;
@property (nonatomic, assign) int               donated_amount;
@property (nonatomic, assign) int               post_user_id;
@property (nonatomic, assign) int               donated_user_count;
@property (nonatomic, assign) int               donated_count;
@property (nonatomic, strong) NSMutableArray    *arrUsers;
@property (nonatomic, strong) User              *postUser;
@property (nonatomic, assign) BOOL              is_gave;
@property (nonatomic, assign) BOOL              is_follower;
@property (nonatomic, strong) NSString          *stripe_user_id;
@property (nonatomic, strong) NSString          *gift_type;


- (id) initWithHomeFeed: (NSDictionary*) dicFeed;
- (id) initWithDictionary: (NSDictionary*) dicFeed;
- (id) initWithManagedObject: (NSManagedObject*) objFeed;
- (id) initWithProfileFeed: (NSDictionary*) dicFeed;

- (void) mergeFeed: (Feed*) f;
- (NSArray*) getDonatedUsernames;
- (User*) getUserInfo: (int) index;
- (DONATED_STATUS) getDonatedStatus;
- (BOOL) isCreatedByCurrentUser;
- (NSString*) getProjectImage;
- (NSString*) getFeedType;
@end
