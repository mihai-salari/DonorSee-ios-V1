//
//  DSMappingProvider.h
//  DonorSee
//
//  Copyright © 2016 DonorSee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEMObjectMapping.h"

@interface DSMappingProvider : NSObject

+ (FEMObjectMapping *) userMapping;
+ (FEMObjectMapping *) projectsMapping;
+ (FEMObjectMapping *) eventMapping;
@end
