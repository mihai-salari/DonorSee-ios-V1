//
//  MediaFile.h
//  DonorSee
//
//  Created by Bogdan on 10/10/16.
//  Copyright © 2016 miroslave. All rights reserved.
//


@interface MediaFile : NSObject
{
   
}

@property (nonatomic, strong) NSString      *mediaURL;

@property (nonatomic)         enum MediaType mediaType;

typedef enum MediaType
{
    PICTURE,
    VIDEO
};

-(NSString*) getThumbnailURL;

@end
