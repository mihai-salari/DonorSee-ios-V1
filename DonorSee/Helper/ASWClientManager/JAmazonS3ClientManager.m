//
//  JAmazonS3ClientManager.m
//  SongBooth
//
//  Created by Eric Yang on 9/19/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "JAmazonS3ClientManager.h"
#import "JS3FileUploader.h"
#import "JS3FileDownloader.h"

@interface JAmazonS3ClientManager (Private)

- (NSURL *)preSignedUrlForItem:(NSString *)itemKey itemType:(NSString *)type inBucket:(NSString *)bucket;

@end

@implementation JAmazonS3ClientManager
{
    NSOperationQueue *_mainQueue;
    AmazonS3Client *_s3Client;
    S3TransferManager *_s3TManager;
    
    NSMutableDictionary *_preSignedUrlDict;
}

//====================================================================================================
static JAmazonS3ClientManager *_manager = nil;
+ (JAmazonS3ClientManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[JAmazonS3ClientManager alloc] init];
    });
    return _manager;
}

//====================================================================================================
- (id)init
{
    if (self = [super init]) {
        _s3Client = [[AmazonS3Client alloc] initWithAccessKey:AWS_ACCESS_KEY_ID withSecretKey:AWS_SECRET_KEY];
        _mainQueue = [[NSOperationQueue alloc] init];
        _preSignedUrlDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//====================================================================================================
- (AmazonS3Client *)client
{
    return _s3Client;
}

//====================================================================================================
- (S3TransferManager *)tm
{
    return _s3TManager;
}

#pragma mark get url methods

//====================================================================================================
- (NSString*) getPathForPhoto: (NSString*) itemKey
{
    return [[NSString stringWithFormat: @"https://s3.amazonaws.com/%@/%@", BUCKET_PHOTO, itemKey] stringByAddingPercentEncodingWithAllowedCharacters: NSCharacterSet.URLQueryAllowedCharacterSet];
}

#pragma mark Methods for Pre-signed Url

//====================================================================================================
- (NSString *)urlLocalFilePath
{
    return [NSString stringWithFormat:@"%@preSignedUrls.plist", NSTemporaryDirectory()];
}

//====================================================================================================
- (void)loadSavedPreSignedUrls
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self urlLocalFilePath]];
    if (dict) {
        [_preSignedUrlDict setDictionary:dict];
    }
}

//====================================================================================================
- (void)savePreSignedUrls
{
    [_preSignedUrlDict writeToFile:[self urlLocalFilePath] atomically:NO];
}

//====================================================================================================
- (NSURL *)preSignedUrlForItem:(NSString *)itemKey itemType:(NSString *)type inBucket:(NSString *)bucket
{
    if (!itemKey) {
        return nil;
    }
    if ([_preSignedUrlDict objectForKey:itemKey]) {
        return [NSURL URLWithString:[_preSignedUrlDict objectForKey:itemKey]];
    }
    S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
    override.contentType = type;
    S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
    gpsur.key     = itemKey;
    gpsur.bucket  = bucket;
    gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600 * 24 * 30 * 120];  // keep alive for ten years
    gpsur.responseHeaderOverrides = override;
    NSURL *url = [_s3Client getPreSignedURL:gpsur];
    [_preSignedUrlDict setObject:url.absoluteString forKey:itemKey];
    [self savePreSignedUrls];
    return url;
}

//====================================================================================================
- (NSURL *)preSignedUrlForPostPhoto:(NSString *)itemKey
{
    return [self preSignedUrlForItem:itemKey itemType:@"image/jpeg" inBucket: BUCKET_PHOTO];
}

#pragma mark Methods for Delete

//====================================================================================================
- (void)deleteFile:(NSString*)bucketName keyName:(NSString*)keyName
{
    [_s3Client deleteObjectWithKey:keyName withBucket:bucketName];
}
                                       
#pragma mark Methods for Upload

//====================================================================================================
- (JS3FileUploader *)uploadPostPhotoData:(NSData *)data
                                 fileKey:(NSString*)fileKey
                        withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress
                           completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName: BUCKET_PHOTO fileKey:fileKey inProgress:progress completed:complete];
}

//====================================================================================================
- (JS3FileUploader *)uploadData:(NSData *)data
                     bucketName:(NSString *)bucketName
                        fileKey:(NSString*)fileKey
                     inProgress:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress
                      completed:(J_DID_COMPLETE_CALL_BACK_BLOCK)completed
{
    if (!data || !data.length)
    {
        return nil;
    }
    
    NSString *extension =@"jpg";
    JS3FileUploader *uploader = [[JS3FileUploader alloc] initWithData:data
                                                           bucketName:bucketName
                                                              fileKey:fileKey
                                                        fileExtension:extension
                                                     publicAccessAble:YES
                                                      inProgressBlock:progress completedBlock:completed];
    [_mainQueue addOperation:uploader];
    return uploader;
}

#pragma mark Download
//====================================================================================================
- (JS3FileDownloader *)downloadData:(NSString *)bucketName
                            fileKey:(NSString*)fileKey
                         inProgress:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress
                          completed:(J_DID_COMPLETE_CALL_BACK_BLOCK)completed
{
    NSString *extension = @"mp4";
    JS3FileDownloader *downloader = [[JS3FileDownloader alloc] initWithBucketName:bucketName
                                                                          fileKey:fileKey
                                                                    fileExtension:extension
                                                                 publicAccessAble:YES
                                                                  inProgressBlock:progress completedBlock:completed];
    [_mainQueue addOperation:downloader];
    return downloader;
}

//====================================================================================================
@end
