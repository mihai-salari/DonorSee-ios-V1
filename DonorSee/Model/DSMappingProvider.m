//
//  DSMappingProvider.m
//  DonorSee
//
//  Copyright © 2016 DonorSee. All rights reserved.
//

#import "DSMappingProvider.h"
#import "Event.h"

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
    
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToIntNumberProperty:@"user_id" toKeyPath:@"id"]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"avatar" toKeyPath:@"photo_url"]];
    
    [mapping addAttributesFromArray:@[@"first_name", @"last_name", @"email"]];
    
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
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToIntNumberProperty:@"feed_id" toKeyPath:@"id"]];
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToIntNumberProperty:@"owner_id" toKeyPath:@"owner_id"]];
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToIntNumberProperty:@"pre_amount" toKeyPath:@"goal_amount_cents"]];
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToIntNumberProperty:@"is_gave" toKeyPath:@"user.is_giver"]];
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToIntNumberProperty:@"is_follower" toKeyPath:@"user.is_follower"]];
    
    //String
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"feed_description" toKeyPath:@"description"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"photo" toKeyPath:@"photo_url"]];
    
    // Date
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"created_at" toKeyPath:@"created_at"]];
    
    //
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"postUser" keyPath:@"owner"];
    
    return mapping;
}

+ (FEMObjectMapping *)eventMapping {
    FEMObjectMapping *mapping = [[FEMObjectMapping alloc] initWithObjectClass:[Event class]];
    
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToIntNumberProperty:@"event_id" toKeyPath:@"id"]];
    // Date
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"created_at" toKeyPath:@"created_at"]];
    [mapping addAttribute:[DSMappingProvider mappingOfNSStringToDateProperty:@"updated_at" toKeyPath:@"updated_at"]];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"type" toKeyPath:@"type"]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"message" toKeyPath:@"message"]];
    
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"creator" keyPath:@"creator"];
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"recipient" keyPath:@"recipient"];
    
    [mapping addRelationshipMapping:[self projectsMapping] forProperty:@"feed" keyPath:@"project"];
    
    return mapping;
}

@end
