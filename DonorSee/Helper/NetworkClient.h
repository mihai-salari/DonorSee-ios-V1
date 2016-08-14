//
//  NetworkClient.h
//  EverybodyRun
//
//  Created by star on 2/11/16.
//  Copyright © 2016 samule. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@interface NetworkClient : AFHTTPSessionManager
{
    
}

+ (NetworkClient*) sharedClient;
- (void) cancelAllRequest;

- (void) signUp: (NSString*) first_name
      last_name: (NSString*) last_name
          email: (NSString*) email
       password: (NSString*) password
         avatar: (NSString*) avatar
        success: (void (^)(NSDictionary *dicUser))success
        failure: (void (^)(NSString *errorMessage))failure;

- (void) login: (NSString*) email
      password: (NSString*) password
       success: (void (^)(NSDictionary *dicUser))success
       failure: (void (^)(NSString *errorMessage))failure;


- (void) loginWithFB: (NSString*) fbid
                name: (NSString*) name
               email: (NSString*) email
             success: (void (^)(NSDictionary *dicUser))success
             failure: (void (^)(NSString *errorMessage))failure;

- (void) forgotPassword: (NSString*) email
                success: (void (^)(NSDictionary *responseObject))success
                failure: (void (^)(NSError *error))failure;

- (void) updateProfile: (NSString*) firstName
              lastName: (NSString*) lastName
           oldPassword: (NSString*) oldPassword
           newPassword: (NSString*) newPassword
                avatar: (NSString*) avatar
              isFBUser: (BOOL) isFBUser
               success: (void (^)(NSDictionary *dicUser))success
               failure: (void (^)(NSString *errorMessage))failure;

- (void) getUserInfo: (int) user_id
             success: (void (^)(NSDictionary *dicUser))success
             failure: (void (^)(NSString *errorMessage))failure;

- (void) addPaypal: (NSString*) paypalEmail
           success: (void (^)(void))success
           failure: (void (^)(NSString *errorMessage))failure;

//Feed.
- (void) postFeed: (NSString*) imageURL
      description: (NSString*) description
           amount: (int) amount
          user_id: (int) user_id
          success: (void (^)(NSDictionary *dicFeed, NSDictionary* dicUser))success
          failure: (void (^)(NSString *errorMessage))failure;

- (void) getHomeFeeds: (int) limit
               offset: (int) offset
              success: (void (^)(NSArray *arrFeed))success
              failure: (void (^)(NSString *errorMessage))failure;

- (void) getPersonalFeeds: (int) limit
                   offset: (int) offset
                  success: (void (^)(NSArray *arrFeed))success
                  failure: (void (^)(NSString *errorMessage))failure;

- (void) getSingleFeed: (NSString*) feed_id
               success: (void (^)(NSDictionary *dicFeed))success
               failure: (void (^)(NSString *errorMessage))failure;

- (void) getUserFeeds: (int) user_id
                limit: (int) limit
               offset: (int) offset
              success: (void (^)(NSArray *arrFeed))success
              failure: (void (^)(NSString *errorMessage))failure;

- (void) getMyFeeds: (int) user_id
            success: (void (^)(NSArray *arrFeed))success
            failure: (void (^)(NSString *errorMessage))failure;

- (void) getFundedFeeds: (int) user_id
                success: (void (^)(NSArray *arrFeed))success
                failure: (void (^)(NSString *errorMessage))failure;

- (void) removeFeed: (Feed*) f
            user_id: (int) user_id
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure;


//Donate Transaction.
- (void) postDonate: (int) user_id
            feed_id: (NSString*) feed_id
             amount: (int) amount
            success: (void (^)(NSDictionary* dicDonate))success
            failure: (void (^)(NSString *errorMessage))failure;

- (void) postStripeDonate: (int) user_id
                  feed_id: (NSString*) feed_id
         source_stripe_id: (NSString*) source_stripe_id
             stripe_token: (NSString *) stripe_token
                   amount: (int) amount
                  success: (void (^)(NSDictionary* dicDonate))success
                  failure: (void (^)(NSString *errorMessage))failure;

- (void)postStripeDonorSeeFeeForToken: (NSString *) stripe_token
                               amount: (int) amount
                              success: (void (^)(NSDictionary* dicDonate))success
                              failure: (void (^)(NSString *errorMessage))failure;

- (void) createStipeAccountForUser: (int)user_id
                             email: (NSString *)email
                      stripe_token: (NSString *) stripe_token
                           success: (void (^)(NSDictionary* dicDonate))success
                           failure: (void (^)(NSString *errorMessage))failure;

- (void) getUserSavedCardsFromStripe:(NSString *)stripe_id
                             success: (void (^)(NSDictionary* dicDonate))success
                             failure: (void (^)(NSString *errorMessage))failure;

- (void) getStripeTokenForSavedCard:(NSString *)stripe_car_id
                            success: (void (^)(NSDictionary* dicDonate))success
                            failure: (void (^)(NSString *errorMessage))failure;

//Withdraw Transaction.
- (void) withdrawMoney: (NSString*) email
               message: (NSString*) message
                amount: (NSString*) amount
               user_id: (int) user_id
               success: (void (^)(NSDictionary* dicWithdraw))success
               failure: (void (^)(NSString *errorMessage))failure;

//Activities.
- (void) getActivitiesForFeed: (Feed*) f
                      success: (void (^)(NSArray* arrActivities, Feed* f))success
                      failure: (void (^)(NSString *errorMessage))failure;

- (void) getNotifications: (void (^)(NSArray* notifications))success
                  failure: (void (^)(NSString *errorMessage))failure;

- (void) getMyActivities: (void (^)(NSArray* arrActivities))success
                 failure: (void (^)(NSString *errorMessage))failure;
- (void) readActivity: (int) activity_id;

//Follow.
- (void) followUser: (int) follower_id
       following_id: (int) following_id
            success: (void (^)(User* followerUser, User* followingUser))success
            failure: (void (^)(NSString *errorMessage))failure;

- (void) unfollowUser: (int) follower_id
         following_id: (int) following_id
              success: (void (^)(User* followerUser, User* followingUser))success
              failure: (void (^)(NSString *errorMessage))failure;

//Follow Messages.
- (void) postFollowMessage: (NSString*) message
                    photos: (NSArray*) arrPhotos
                      feed: (Feed*) f
                   success: (void (^)(void))success
                   failure: (void (^)(NSString *errorMessage))failure;

//Report.
- (void) reportFeed: (Feed*) f
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure;

- (void) reportUser: (User*) u
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure;

- (void) getUnReadCountInfo: (int) user_id
                    success: (void (^)(NSDictionary *dicUser))success
                    failure: (void (^)(NSString *errorMessage))failure;

// Notification
- (void) readNotification: (int) notification_id;

- (void) getUserFollowStatus:(int) selectedUser_id
                     user_id:(int) user_id
                     success: (void (^)(NSDictionary *followStatus))success
                     failure: (void (^)(NSString *errorMessage))failure;


// Check version number
- (void) checkAppVersion: (int) user_id
                 version:(NSString *)version
                 success: (void (^)(NSDictionary *dicUser))success
                 failure: (void (^)(NSString *errorMessage))failure;

@end
