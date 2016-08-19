//
//  Notification.h
//  DonorSee
//
//  Created by Keval on 30/06/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

@interface Notification : NSObject

@property (nonatomic, assign) int       notification_id;
@property (nonatomic, assign) int       feed_id;
@property (nonatomic, assign) int       is_read;
@property (nonatomic, retain) NSString  *message;
@property (nonatomic, retain) NSString  *pic;
@property (nonatomic, retain) NSString  *user_avatar;
@property (nonatomic, assign) int       register_date;
@property (nonatomic, assign) int       user_id;
@property (nonatomic, assign) int       type;
@property (nonatomic, assign) NSDate    *date;

@property (nonatomic, retain) Feed          *feed;
@property (nonatomic, retain) User          *user;
@property (nonatomic, retain) User          *recipient;


- (id) initWithDictionary: (NSDictionary*) dicItem;

@end
