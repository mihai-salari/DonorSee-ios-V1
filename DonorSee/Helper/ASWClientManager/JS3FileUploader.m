//
//  JS3FileUploader.m
//  SongBooth
//
//  Created by Eric Yang on 9/19/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "JS3FileUploader.h"
#import "JAmazonS3ClientManager.h"
//#import "NSString+J.h"

@implementation JS3FileUploader
{
    J_DID_COMPLETE_CALL_BACK_BLOCK _completeBlock11;
    J_IN_PROGRESS_CALL_BACK_BLOCK _progressBlock;
    BOOL _isExecuting;
    BOOL _isFinished;
    NSString *_bucketName;
    NSString *_keyName;
    NSData *_fileData;
    NSString *_fileExtension;
    BOOL _needPublicAccess;

}

@synthesize completeBlock2=_completeBlock11;

- (id)initWithData:(NSData *)data
        bucketName:(NSString *)bucketName
           fileKey:(NSString*)fileKey
     fileExtension:(NSString *)extension
  publicAccessAble:(BOOL)isPublic
   inProgressBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progressBlock
    completedBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)completeBlock
{
    if (self = [super init]) {
        _isExecuting = NO;
        _isFinished = NO;
        _progressBlock = progressBlock;
        [self setCompleteBlock2:completeBlock];
        _fileData = data;
        _bucketName = bucketName;
        _fileExtension = extension;
        _needPublicAccess = isPublic;
        _keyName = [NSString stringWithFormat:@"%@.%@",fileKey, _fileExtension];
    }
    return self;
}

-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return _isExecuting;
}

-(BOOL)isFinished
{
    return _isFinished;
}

- (void)start
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:_keyName inBucket:_bucketName];
    if([_fileExtension isEqualToString:@"jpg"])
    {
        putObjectRequest.contentType=@"image/jpeg";
    }
    else// if([_fileExtension isEqualToString:@"acc"])
        putObjectRequest.contentType=@"audio/mpeg";

    putObjectRequest.data = _fileData;
    putObjectRequest.delegate = self;
    if (_needPublicAccess) {
        putObjectRequest.cannedACL = [S3CannedACL publicRead];
    }
    [[[JAmazonS3ClientManager defaultManager] client] putObject:putObjectRequest];
}

#pragma mark - AmazonServiceRequestDelegate Implementations

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    if (_completeBlock11)
    {
        _completeBlock11([NSString stringWithString:_keyName]);
    }
    [self finish];
}

- (void) request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
//    NSLog(@"progress inner = %f", (float)totalBytesWritten / (float)totalBytesExpectedToWrite);
    if (_progressBlock) {
        _progressBlock((float)totalBytesWritten / (float)totalBytesExpectedToWrite);
    }
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    if (_completeBlock11) {
        _completeBlock11((NSString*)error);
    }
    [self finish];
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    NSLog(@"%@", exception);
    if (_completeBlock11) {
        _completeBlock11((NSString*)exception);
//        _completeBlock11(34);
    }
    [self finish];
}

#pragma mark - Helper Methods

-(void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished  = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    _bucketName = nil;
    _fileData = nil;
    _keyName = nil;
    _completeBlock11 = nil;
    _progressBlock = nil;
}

@end
