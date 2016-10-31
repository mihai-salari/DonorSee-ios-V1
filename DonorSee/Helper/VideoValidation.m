//
//  VideoValidation.m
//  DonorSee
//
//  Created by Bogdan on 10/27/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <Foundation/Foundation.h>
@implementation VideoValidation : NSObject

-(BOOL) videoIsValid: (NSURL *) mediaUrl {
    unsigned long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:mediaUrl.path error:nil].fileSize;
    return fileSize <= 100000000;
}

@end
