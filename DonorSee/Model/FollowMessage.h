//
//  FollowMessage.h
//  DonorSee
//
//  Created by star on 3/24/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FollowMessage : NSObject
{
    
}

@property (nonatomic, assign) int       message_id;
@property (nonatomic, assign) int       feed_id;
@property (nonatomic, assign) int       user_id;
@property (nonatomic, retain) NSString  *message;
@property (nonatomic, retain) NSArray   *arrPhotos;
@property (nonatomic, assign) int       register_date;

- (id) initWithDictionary: (NSDictionary*) dicItem;
@end
