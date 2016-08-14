//
//  User.h
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ObjectMap.h"

@interface User : NSObject
{
    
}

@property (nonatomic, assign) int           user_id;
@property (nonatomic, strong) NSString      *fb_id;
@property (nonatomic, strong) NSString      *name;
@property (nonatomic, strong) NSString      *email;
@property (nonatomic, strong) NSString      *avatar;
@property (nonatomic, assign) float         received_amount;
@property (nonatomic, assign) float         pay_amount;
@property (nonatomic, assign) int           following;
@property (nonatomic, assign) int           follower;
@property (nonatomic, assign) BOOL          followed;
@property (nonatomic, strong) NSString      *paypal;

// NEW PRO
@property (nonatomic, strong) NSString * created_at;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSString * updated_at;

- (id) initUserWithDictionary: (NSDictionary*) dicUser;
- (id) initUserWithManagedObject: (NSManagedObject*) objUser;

@end
