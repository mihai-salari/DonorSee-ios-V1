//
//  Global.h
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#ifndef Global_h
#define Global_h

#define     TEST_FLAG                           0

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPAD_PRO (IS_IPAD && SCREEN_MAX_LENGTH == 1366.0)

//#define     kAPIBaseURLString                   @"http://192.168.2.31/donorsee/webservice"
//#define     kAPIBaseURLString                   @"http://ec2-52-38-29-235.us-west-2.compute.amazonaws.com/donorsee/webservice"
//#define     kAPIBaseURLString                   @"https://donorsee.com/donorsee/webservice/"
//#define     kAPIBaseURLString                   @"https://donorsee-api-staging.herokuapp.com/"


//=========================================================================================================
//SERVER URL
//#define     kAPIBaseURLString                   @"https://api.donorsee.com/"
#define     kAPIBaseURLString                   @"https://api-staging.donorsee.com"

//STRIPE

// TESTING
#define     STRIPE_PUBLISHABLE_KEY              @"pk_test_ALLXQ4toDK0RVyF6c3hTtSha"
#define     STRIPE_API_KEY                      @"sk_test_cKtHGMWGhJRSkaEZSmQ3DVfm"

// LIVE
//#define     STRIPE_PUBLISHABLE_KEY              @"pk_live_2bBCB03bBfosymy4YKkyxbtG"
//#define     STRIPE_API_KEY                      @"sk_live_iRxXaivs67BfgaMwdZwt5YwE"

//=========================================================================================================

#define     STRIPE_CONNECT_CHARGES_URL          @"https://api.stripe.com/v1/charges"
#define     STRIPE_CONNECT_CUSTOMER_URL         @"https://api.stripe.com/v1/customers"
#define     STRIPE_CONNECT_TOKENS_URL           @"https://api.stripe.com/v1/tokens"


#define     DONORSEE_STRIPE_ID                  @"acct_18MJ8MDAyu7GKAGH"


#define     APP_STORE_URL                       @"https://itunes.apple.com/us/app/donorsee/id1093861994?ls=1&mt=8"

#define     ADMIN_EMAIL                         @"admin@donorsee.com"
#define     COLOR_MAIN                          [UIColor colorWithRed: 8.0/255.0 green: 117.0/255.0 blue: 125.0/255.0 alpha:1.0]
#define     COLOR_FEED_TEXT                     [UIColor colorWithRed: 153.0/255.0 green: 153.0/255.0 blue: 153.0/255.0 alpha:1.0]
#define     MAX_DESCRIPTION_LENGTH              1500
#define     MAX_PRICE                           99999
#define     MIN_PRICE                           1
#define     IMAGE_COMPRESSION                   0.5
#define     FETCH_LIMIT                         10
#define     NOTIFICATIONS_FETCH_LIMIT           20
#define     TAB_BAR_HEIGHT                      68.0f
#define     TOP_BAR_HEIGHT                      77.0f
#define     REQUEST_TIME_OUT                    20
#define     PASSWORD_MAX_LENGTH                 5
#define     MAX_POST_COUNT_DAY                  5
#define     TWITTER_MAX_LENGTH                  85

#define     FONT_REGULAR                        @"HelveticaNeue"
#define     FONT_THIN                           @"HelveticaNeue-Thin"
#define     FONT_MEDIUM                         @"HelveticaNeue-Medium"
#define     FONT_LIGHT                          @"HelveticaNeue-Light"
#define     DEFAULT_USER_IMAGE                  @"default-profile-pic.png"


typedef enum
{
    TAB_FUNDED,
    TAB_UPLOAD,
    TAB_SETTINGS,
    
} PROFILE_TAB;

typedef enum
{
    NO_DONATED,
    FULL_DONATED,
    DONATING,
    
} DONATED_STATUS;

typedef enum
{
    REPORT_FEED,
    REPORT_USER,
    
} REPORT_TYPE;


typedef enum
{
    ACTIVITY_DONATED,
    ACTIVITY_FULL_DONATED,
    ACTIVITY_FOLLOW_MESSAGE,
    
} ACTIVITY_TYPE;

typedef enum
{
    HOME_STAFF_PICKS,
    HOME_GLOBAL,
    HOME_PERSONAL,
    
} HOME_TYPE;


//AWS.
#define     AWS_ACCESS_KEY_ID                   @"AKIAI5C7IJ7OZ4NCUVHA"
#define     AWS_SECRET_KEY                      @"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"
#define     BUCKET_PHOTO                        @"com.donorsee.photo"
typedef void(^J_IN_PROGRESS_CALL_BACK_BLOCK)(float progress);
typedef void(^J_DID_COMPLETE_CALL_BACK_BLOCK)(NSString *obj);//NSObject *obj


//Paypal
#define     PAYPAL_SANDBOX_ID                   @"AR-pInhAotJisQiVpGpYqHPpL9U-m0TrL2OL9dyEbZMLn9jgHvSAkRiR-nfCWXNF92nzzB5PRAEOV3py"
#define     PAYPAL_LIVE_ID                      @"AdOO3_-mqFEUZjwAUVw7WjWHSsgVx71xCXqBcrFRGx2fynOAa6ry0iVcI4Hu5LL8IRKwbfFxNvQUOdlC"

/////////////////////////////////////// Message. /////////////////////////////////////////////
#define     MSG_INVALID_FIRST_NAME              @"Please input a valid first name."
#define     MSG_INVALID_LAST_NAME               @"Please input a valid last name."
#define     MSG_INVALID_BIO_INFO                @"Please input a bio information."
#define     MSG_INVALID_EMAIL                   @"Please input a valid email address."
#define     MSG_INVALID_PASSWORD                @"Password must be 6 characters long."
#define     MSG_INVALID_PHOTO                   @"Please add a photo to continue."
#define     MSG_INVALID_DESCRIPTION             @"Please input valid description."
#define     MSG_DISCONNECT_INTERNET             @"Can't connect with server. Please check your internet connection."
#define     MSG_INVALID_AMOUNT                  @"Please input valid amount."
#define     MSG_INFO_AMOUNT                     @"We recommend that you fundraise about 10% more than what the need actually costs to account for fees and unexpected expenses."
#define     MSG_WITHDRAW_SUCCESS                @"We will send your money in the next 24 hours."
#define     MSG_INFO_WITHDRAW                   @"This is how much money has been donated to you after a 6.9% credit card and transaction fee."
#define     MSG_INVALID_MESSAGE                 @"Please input valid message."
#define     MSG_ERROR_UPLOADING_IMAGE           @"Can't upload photo. Please check your internet connection."
#define     MSG_INVALID_PAYPAL_EMAIL            @"Please input valid Paypal Email address."
#define     MSG_REPORT                          @"Thank you for reporting this photo. We will review within 24hrs and ban the content if it violates the DonorSee Terms of Service."
#define     MSG_REPORT_USER                     @"We will review within 24hrs and block user if there has been a violation the DonorSee Terms of Service."
#define     MSG_SHARE_USER                      @"Share User!"
#define     MSG_MAX_POST_PROJECT                @"For now, we only allow 5 posts per day. Come back tomorrow to post more projects!"

#define     MSG_FEED_DELETED                    @"Project that you are looking for is deleted"

////////////////////////////////////// Notification. /////////////////////////////////////////

#define     NOTI_UPDATE_FUNDED_FEED                 @"NotificationUpdatedFundedFeed"
#define     NOTI_UPDATE_FUNDED_FEED_AFTER_REMOVE    @"NotificationUpdatedFundedFeedAfterRemove"
#define     NOTI_UPDATE_FOLLOW_FEED                 @"NotificationUpdatedFeed"
#define     NOTI_UPDATE_FOLLOW_USER                 @"NotificationUpdatedUser"

#define     FEED_TYPE_DEFAULT                       @"one-time"
#define     FEED_TYPE_MONTHLY                       @"monthly"

#define     MSG_CANCEL_MONTHLY_DONATION             @"Are you sure you want to cancel monthly donation to this project?"


#endif /* Global_h */
