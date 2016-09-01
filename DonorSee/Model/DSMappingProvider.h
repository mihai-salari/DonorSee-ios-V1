//
//  DSMappingProvider.h
//  DonorSee
//
//  Copyright © 2016 miroslave. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "FEMObjectMapping.h"

@interface DSMappingProvider : NSObject

+ (FEMObjectMapping *) userMapping;
+ (FEMObjectMapping *) projectsMapping;
+ (FEMObjectMapping *) eventMapping;
+ (FEMObjectMapping *) notificationMapping;
+ (FEMObjectMapping *)eventMappingForNotification;
+ (FEMObjectMapping *)eventMappingForTransactionHistory;
+ (FEMObjectMapping *)eventMappingForTransactionHistoryReceive;

+ (FEMObjectMapping *) giftsMapping;
@end