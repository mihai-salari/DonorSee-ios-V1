//
//  Event.h
//  DonorSee
//
//  Copyright © 2016 DonorSee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property (nonatomic, strong) NSNumber          *event_id;


@property (nonatomic, strong) NSString          *type;
@property (nonatomic, strong) NSString          *message;


@property (nonatomic, strong) NSDate            *created_at;
@property (nonatomic, strong) NSDate            *updated_at;

@property (nonatomic, strong) User              *creator;
@property (nonatomic, strong) User              *recipient;

@property (nonatomic, strong) Feed              *feed;

@end
