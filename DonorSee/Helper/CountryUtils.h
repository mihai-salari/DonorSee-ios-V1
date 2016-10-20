//
//  CountryUtils.h
//  DonorSee
//
//  Created by Bogdan on 10/20/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryUtils : NSObject
{
    
}

-(NSString *) getCountryCodeByName: (NSString*) countryName;
-(NSString *) getCountryNameByCode: (NSString*) countryCode;
-(NSMutableArray *) getSortedCountryArray;


@end
