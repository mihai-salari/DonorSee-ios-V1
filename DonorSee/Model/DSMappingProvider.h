//
//  DSMappingProvider.h
//  DonorSee
//
//  Created by Keval on 13/08/16.
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
@end
