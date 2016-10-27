//
//  Event.m
//  DonorSee
//
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "Event.h"
#import "MediaFile.h"

@implementation Event

- (NSMutableArray*) getMedia
{
    NSMutableArray *mediaArray = [[NSMutableArray alloc] init];
    
    if(_video_urls!=nil){
        NSArray *videos = [_video_urls componentsSeparatedByString:@","];
        for(NSString* videoKey in videos)
        {
            if(videoKey!=nil){
                MediaFile *mediaFile = [[MediaFile alloc] init];
                mediaFile.mediaURL = videoKey;
                mediaFile.mediaType = VIDEO;
                [mediaArray addObject:mediaFile];
                
            }
        }
    }
    
    if(_photo_urls!=nil){
        NSArray *photos = [_photo_urls componentsSeparatedByString:@","];
        for(NSString* photoKey in photos)
        {
            if(photoKey!=nil){
                MediaFile *mediaFile = [[MediaFile alloc] init];
                mediaFile.mediaURL = photoKey;
                mediaFile.mediaType = PICTURE;
                [mediaArray addObject:mediaFile];
            }
        }
    }
    
    return mediaArray;
}

@end
