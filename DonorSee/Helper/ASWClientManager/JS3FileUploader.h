//
//  JS3FileUploader.h
//  SongBooth
//
//  Created by Eric Yang on 9/19/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSRuntime/AWSRuntime.h>

@interface JS3FileUploader : NSOperation<AmazonServiceRequestDelegate>
{
    
}
@property (copy) J_DID_COMPLETE_CALL_BACK_BLOCK           completeBlock2;

- (id)initWithData:(NSData *)data bucketName:(NSString *)bucketName fileKey:(NSString*)fileKey fileExtension:(NSString *)extension publicAccessAble:(BOOL)isPublic inProgressBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progressBlock completedBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)completeBlock;

@end
