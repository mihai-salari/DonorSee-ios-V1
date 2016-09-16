//
//  NSString+Formats.m
//  DonorSee
//
//  Created by Yaroslav Kupyak on 9/17/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "NSString+Formats.h"

@implementation NSString (Formats)

+ (NSString *) StringWithAmountCents: (int) cents{
    int dollars = cents / 100;
    int centsRemainder = cents % 100;
    if (centsRemainder == 0){
        return [NSString stringWithFormat: @"%d", dollars];
    }
    else{
        return [NSString stringWithFormat: @"%d.%02d", dollars, centsRemainder];
    }
}


@end
