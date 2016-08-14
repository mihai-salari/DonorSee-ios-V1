//
//  JAmazonS3ClientManager.h
//  SongBooth
//
//  Created by Eric Yang on 9/19/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import "JS3FileUploader.h"
#import "JS3FileDownloader.h"

@interface JAmazonS3ClientManager : NSObject

+ (JAmazonS3ClientManager *)defaultManager;
- (AmazonS3Client *)client;
- (S3TransferManager *)tm;

#pragma mark cdn url methods
- (NSString*) getPathForPhoto: (NSString*) itemKey;

#pragma mark Methods for Upload
- (JS3FileUploader *)uploadPostPhotoData:(NSData *)data
                                 fileKey:(NSString*)fileKey
                        withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress
                           completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;

- (void)deleteFile:(NSString*)bucketName keyName:(NSString*)keyName;
@end
