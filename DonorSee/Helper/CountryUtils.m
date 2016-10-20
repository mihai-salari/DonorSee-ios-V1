//
//  CountryUtils.m
//  DonorSee
//
//  Created by Bogdan on 10/20/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CountryUtils.h"

@implementation CountryUtils: NSObject


-(NSString *) getCountryCodeByName: (NSString*) countryName{
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    NSMutableArray *countries = [NSMutableArray arrayWithCapacity:[countryCodes count]];
    
    for (NSString *countryCode in countryCodes)
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *country = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"] displayNameForKey: NSLocaleIdentifier value: identifier];
        [countries addObject: country];
    }
    
    NSDictionary *codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
    
    return [codeForCountryDictionary objectForKey:countryName];
}

-(NSString *) getCountryNameByCode: (NSString*) countryCode{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"];
    return [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
}


-(NSMutableArray *) getSortedCountryArray {
    NSArray *countryArray = [NSLocale ISOCountryCodes];
    
    NSMutableArray *sortedCountryArray = [[NSMutableArray alloc] init];
    
    for (NSString *countryCode in countryArray) {
        [sortedCountryArray addObject: [self getCountryNameByCode:countryCode]];
    }
    
    [sortedCountryArray sortUsingSelector:@selector(localizedCompare:)];
    
    return sortedCountryArray;
}

@end
