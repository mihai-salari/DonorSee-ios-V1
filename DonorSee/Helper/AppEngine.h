//
//  AppEngine.h
//  EverybodyRun
//
//  Created by star on 1/31/16.
//  Copyright © 2016 samule. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppEngine : NSObject
{
    
}

@property (nonatomic, retain) User      *currentUser;

@property (nonatomic, assign) BOOL      locationServiceEnabled;
@property (nonatomic, assign) float     currentLatitude;
@property (nonatomic, assign) float     currentLongitude;
@property (nonatomic, retain) NSString  *currentDeviceToken;
@property (nonatomic, assign) BOOL      isShowDonatedAmount;

//@property (nonatomic, retain) NSString  *currentAddress;

+ (AppEngine*) sharedInstance;
+ (BOOL) emailValidate:(NSString *)strEmail;
+ (NSString*) getValidString: (NSString*) value;
+ (UIAlertController*) showMessage: (NSString*) message title: (NSString*) title;
+ (UIAlertController*) showAlertWithText:(NSString*)message;
+ (UIAlertController*) showErrorWithText:(NSString*)message;
+ (NSString *)md5: (NSString*) string;
+ (NSString*) getUUID;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size;
+ (NSString*) getFirstName: (NSString*) name;
+ (NSString*) getLastName: (NSString*) name;
+ (NSString*) getImageName;
+ (NSString*) dateTimeStringFromTimestap:(int)time;
+ (NSString *)dataTimeStringFromDate:(NSDate *)date;
+ (float) getDistance: (CLLocation*) loc1 loc2: (CLLocation*) loc2;

@end
