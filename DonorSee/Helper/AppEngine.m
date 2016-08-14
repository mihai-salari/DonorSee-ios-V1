//
//  AppEngine.m
//  EverybodyRun
//
//  Created by star on 1/31/16.
//  Copyright © 2016 samule. All rights reserved.
//

#import "AppEngine.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AppEngine

//====================================================================================================
+ (AppEngine*)sharedInstance
{
    static AppEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppEngine alloc] init];
    });
    
    return sharedInstance;
}

//====================================================================================================
+ (BOOL)emailValidate:(NSString *)strEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

//====================================================================================================
+ (UIAlertController*) showMessage: (NSString*) message title: (NSString*) title
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil message: message preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction: okAction];
    return alert;
}

//====================================================================================================
+ (UIAlertController*)showAlertWithText:(NSString*) message
{
    return [AppEngine showMessage: message title: @"Warnning"];
}

//====================================================================================================
+ (UIAlertController*)showErrorWithText:(NSString*) message
{
    return [AppEngine showMessage: message title: @"Error"];
}

//====================================================================================================
+ (NSString*) getValidString: (NSString*) value
{
    if(value == nil || [value isKindOfClass: [NSNull class]])
    {
        return @"";
    }
    return value;
}

+ (NSString*) getUUID
{
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

+ (NSString *)md5: (NSString*) string
{
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString*) getFirstName: (NSString*) name
{
    if(name == nil || [name length] == 0) return @"";
    NSArray* array = [name componentsSeparatedByString: @" "];
    if(array != nil && [array count] >= 1)
    {
        return [array firstObject];
    }
    
    return @"";
}

+ (NSString*) getLastName: (NSString*) name
{
    if(name == nil || [name length] == 0) return @"";
    NSArray* array = [name componentsSeparatedByString: @" "];
    if(array != nil && [array count] >= 2)
    {
        return [array lastObject];
    }
    
    return @"";
}

+ (float) getDistance: (CLLocation*) loc1 loc2: (CLLocation*) loc2
{
    CLLocationDistance meters = [loc1 distanceFromLocation:loc2];
    return meters / 1609.34;
}

//====================================================================================================
+ (NSString*) getImageName
{
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMddHHmmssSSS"];
    NSString* name = [NSString stringWithFormat: @"DonorSee%@", [formatter stringFromDate: date]];
    return name;
}

+ (NSString *)dataTimeStringFromDate:(NSDate *)date
{
    NSTimeInterval interval = [date timeIntervalSinceNow];
    double elapse = 0 - (double)interval;
    //    NSLog(@"Date: %@", date);
    if (elapse < 60) {
        if(elapse<1)
            elapse=1;
        return [NSString stringWithFormat:@"%ds", (int)elapse];
    }
    else if (elapse < 60 * 60) {
        int minute = round(elapse / 60);
        return [NSString stringWithFormat:@"%dm", minute];
        //    } else if (elapse < 1.5 * 60 * 60) {
        //        return @"An hour";
    } else if (elapse < 24 * 60 * 60) {
        int hour = round(elapse / 60 / 60);
        return [NSString stringWithFormat:@"%dh", hour];
        //    } else if (elapse < 48 * 60 * 60) {
        //        return @"Yesterday";
    } else if (elapse < 7 * 24 * 60 * 60) {
        int day = floor(elapse / 24 / 60 / 60);
        return [NSString stringWithFormat:@"%dd", day];
    } else//(elapse < 365 * 24 * 60 * 60)
    {
        int day = floor(elapse / 24 / 60 / 60/7);
        return [NSString stringWithFormat:@"%dw", day];
    }
}

+ (NSString*) dateTimeStringFromTimestap:(int)time;
{
    NSDate* date=[NSDate dateWithTimeIntervalSince1970: time];
    return [self dataTimeStringFromDate:date];
}

@end
