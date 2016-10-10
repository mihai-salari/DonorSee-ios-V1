//
//  Event.h
//  DonorSee
//
//  Copyright © 2016 miroslave. All rights reserved.
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

@property (nonatomic, readwrite) BOOL           is_read;
@property (nonatomic, assign) int               gift_amount_cents;

@property (nonatomic, strong) NSString          *photo_urls;
@property (nonatomic, strong) NSString          *video_urls;
- (NSMutableArray*) getMedia;
@end


