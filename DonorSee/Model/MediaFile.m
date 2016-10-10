//
//  MediaFile.m
//  DonorSee
//
//  Created by Bogdan on 10/10/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaFile.h"

@implementation MediaFile

-(NSString*) getThumbnailURL{
    NSString* result;
    if(_mediaURL!=nil){
        if(_mediaType == PICTURE){
            result = _mediaURL;
        }else{
            NSRange lastDot = [_mediaURL rangeOfString:@"." options:NSBackwardsSearch];
            if(lastDot.location != NSNotFound) {
                result = [_mediaURL substringToIndex:lastDot.location];
                result = [result stringByAppendingString:@".jpg"];
            }
        }
    }else{
        result = @"";
    }
    
    return result;
}

@end
