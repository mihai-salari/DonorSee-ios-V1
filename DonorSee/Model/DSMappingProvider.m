//
//  DSMappingProvider.m
//  DonorSee
//
//  Created by Keval on 13/08/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "DSMappingProvider.h"
#import "Event.h"
#import "Notification.h"

@implementation DSMappingProvider

// Helpers
+ (FEMAttribute *)mappingOfNSStringToIntNumberProperty:(NSString *)property toKeyPath:(NSString *)keyPath {
    return [[FEMAttribute alloc] initWithProperty:property keyPath:keyPath map:^id(id value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [NSNumber numberWithInt:[value intValue]];
        }
        return nil;
    } reverseMap:^id(id value) {
        return value;
    }];
}

+ (FEMAttribute *)mappingOfNSStringToDoubleNumberProperty:(NSString *)property toKeyPath:(NSString *)keyPath {
    return [[FEMAttribute alloc] initWithProperty:property keyPath:keyPath map:^id(id value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [NSNumber numberWithDouble:[value doubleValue]];
        }
        return nil;
    } reverseMap:^id(id value) {
        return value;
    }];
}

+ (FEMAttribute *)mappingOfNSStringToDateProperty:(NSString *)property toKeyPath:(NSString *)keyPath {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    return [[FEMAttribute alloc] initWithProperty:property keyPath:keyPath map:^id(id value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [formatter dateFromString:value];
        }
        return nil;
    } reverseMap:^id(id value) {
        return [formatter stringFromDate:value];
    }];
    
}

+ (FEMObjectMapping *) userMapping {
    FEMObjectMapping *mapping = [[FEMObjectMapping alloc] initWithObjectClass:[User class]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"user_id" toKeyPath:@"id"]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"avatar" toKeyPath:@"photo_url"]];
    
    [mapping addAttributesFromArray:@[@"first_name", @"last_name", @"email", @"stripe_connected", @"stripe_customer", @"fb_id", @"can_receive_gifts"]];
    
    FEMAttribute *nameAttribute = [[FEMAttribute alloc] initWithProperty:@"name" keyPath:nil map:^id _Nullable(id  _Nonnull value) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            return [NSString stringWithFormat:@"%@ %@", [value objectForKey:@"first_name"], [value objectForKey:@"last_name"]];
        }
        
        return nil;
    } reverseMap:^id _Nullable(id  _Nonnull value) {
        return nil;
    }];
    
    [mapping addAttribute:nameAttribute];
    
    return mapping;
}

+ (FEMObjectMapping *) projectsMapping {
    
    FEMObjectMapping *mapping = [[FEMObjectMapping alloc] initWithObjectClass:[Feed class]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"feed_id" toKeyPath:@"id"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"owner_id" toKeyPath:@"owner_id"]];    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"pre_amount" toKeyPath:@"goal_amount_cents"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"donated_amount" toKeyPath:@"stats.amount_raised_cents"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"donated_user_count" toKeyPath:@"stats.giver_count"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"donated_count" toKeyPath:@"stats.gift_count"]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"is_gave" toKeyPath:@"user.is_giver"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"is_follower" toKeyPath:@"user.is_follower"]];
    
    //String
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"feed_description" toKeyPath:@"description"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"photo" toKeyPath:@"photo_url"]];

    // Date
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"created_at" toKeyPath:@"created_at"]];
    
    //
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"postUser" keyPath:@"owner"];
    
    return mapping;
}

+ (FEMObjectMapping *) giftsMapping {
    
    FEMObjectMapping *mapping = [[FEMObjectMapping alloc] initWithObjectClass:[Event class]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"event_id" toKeyPath:@"id"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"gift_amount_cents" toKeyPath:@"amount_cents"]];
    
    [mapping addRelationshipMapping:[self projectsMapping] forProperty:@"feed" keyPath:@"project"];
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"creator" keyPath:@"user"];
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"recipient" keyPath:@"recipient"];
    
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"created_at" toKeyPath:@"created_at"]];
    
    return mapping;
    
}

+ (FEMObjectMapping *)eventMapping {
    FEMObjectMapping *mapping = [[FEMObjectMapping alloc] initWithObjectClass:[Event class]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"event_id" toKeyPath:@"id"]];
    // Date
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"created_at" toKeyPath:@"created_at"]];
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"updated_at" toKeyPath:@"updated_at"]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"type" toKeyPath:@"type"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"message" toKeyPath:@"message"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"is_read" toKeyPath:@"is_read"]];
    
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"creator" keyPath:@"creator"];
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"recipient" keyPath:@"recipient"];
    
    [mapping addRelationshipMapping:[self projectsMapping] forProperty:@"feed" keyPath:@"project"];
    
    //[mapping addAttribute:[FEMAttribute mappingOfProperty:@"photo_urls" toKeyPath:@"photo_urls"]];
    
    FEMAttribute *photoAttribute = [[FEMAttribute alloc] initWithProperty:@"photo_urls" keyPath:@"photo_urls" map:^id _Nullable(id  _Nonnull value) {
        if ([value isKindOfClass:[NSArray class]]) {
            return [value componentsJoinedByString:@","];
        }
        
        return nil;
    } reverseMap:^id _Nullable(id  _Nonnull value) {
        return nil;
    }];
    
    [mapping addAttribute:photoAttribute];
    
    return mapping;
}

+ (FEMObjectMapping *)eventMappingForNotification {
    FEMObjectMapping *mapping = [[FEMObjectMapping alloc] initWithObjectClass:[Event class]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"event_id" toKeyPath:@"id"]];
    // Date
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"created_at" toKeyPath:@"event.created_at"]];
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"updated_at" toKeyPath:@"event.updated_at"]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"type" toKeyPath:@"event.type"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"message" toKeyPath:@"event.message"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"is_read" toKeyPath:@"is_read"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"gift_amount_cents" toKeyPath:@"event.gift.amount_cents"]];
    
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"creator" keyPath:@"event.creator"];
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"recipient" keyPath:@"event.recipient"];
    
    [mapping addRelationshipMapping:[self projectsMapping] forProperty:@"feed" keyPath:@"event.project"];
    
    return mapping;
}

+ (FEMObjectMapping *)eventMappingForTransactionHistory {
    FEMObjectMapping *mapping = [[FEMObjectMapping alloc] initWithObjectClass:[Event class]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"event_id" toKeyPath:@"id"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"gift_amount_cents" toKeyPath:@"amount_cents"]];
    
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"created_at" toKeyPath:@"event.created_at"]];
    
    [mapping addRelationshipMapping:[self projectsMapping] forProperty:@"feed" keyPath:@"project"];
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"creator" keyPath:@"user"];
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"recipient" keyPath:@"recipient"];
    
    return mapping;
}


+ (FEMObjectMapping *)notificationMapping {
    FEMObjectMapping *mapping = [[FEMObjectMapping alloc] initWithObjectClass:[Notification class]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"notification_id" toKeyPath:@"id"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"message" toKeyPath:@"message"]];
    
    [mapping addAttributesFromArray:@[@"type", @"message"]];
    
    [mapping addRelationshipMapping:[self projectsMapping] forProperty:@"feed" keyPath:@"project"];
    
    return mapping;
}


@end