//
//  NetworkClient.m
//  EverybodyRun
//
//  Created by star on 2/11/16.
//  Copyright © 2016 samule. All rights reserved.
//

#import "NetworkClient.h"
#import <AFNetworking/AFNetworking.h>
#import <EventKit/EventKit.h>
#import "Notification.h"
#import "FEMMapping.h"
#import "DSMappingProvider.h"
#import "FEMDeserializer.h"

@implementation NetworkClient

+ (NetworkClient*)sharedClient
{
    static NetworkClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURL *url = [NSURL URLWithString: kAPIBaseURLString];
        client = [[NetworkClient alloc] initWithBaseURL: url];
        
        AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        [client setRequestSerializer:jsonRequestSerializer];
        
        NSString *apiToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_token"];
        [client.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", apiToken] forHTTPHeaderField:@"Authorization"];
        
        [client.requestSerializer setTimeoutInterval: REQUEST_TIME_OUT];

        //Response;
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializer];
        client.responseSerializer = responseSerializer;
        //client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    });
    
    
    return client;
}

- (void) GETRequest: (NSString *)URLString
         parameters: (nullable id)parameters
            success:(nullable void (^)(id responseObject))success
            failure:(nullable void (^)(NSError *error))failure
{
    [self GET: URLString
   parameters: parameters
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
     }];
}

- (void) PostRequest: (NSString *)URLString
         parameters: (nullable id)parameters
            success:(nullable void (^)(id responseObject))success
            failure:(nullable void (^)(NSError *error))failure
{
    [self POST: URLString
    parameters: parameters
      progress:^(NSProgress * _Nonnull uploadProgress) {
          
      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
          success(responseObject);
          
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          failure(error);
      }];
}

- (void) signUp: (NSString*) first_name
      last_name: (NSString*) last_name
          email: (NSString*) email
       password: (NSString*) password
         avatar: (NSString*) avatar
        success: (void (^)(NSDictionary *dicUser))success
        failure: (void (^)(NSString *errorMessage))failure
{
    //NSString* name = [NSString stringWithFormat: @"%@ %@", first_name, last_name];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       first_name, @"first_name",
                                       last_name, @"last_name",
                                       email, @"email",
                                       password, @"password",
                                       avatar, @"photo_url",
                                       nil];
    
    [self PostRequest: @"users"
           parameters: parameters
              success:^(id responseObject) {
                  
                  NSDictionary* dicUser = responseObject[@"user"];
                  success(dicUser);
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) login: (NSString*) email
      password: (NSString*) password
       success: (void (^)(NSDictionary *dicUser))success
       failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       email, @"email",
                                       password, @"password",
                                       nil];
    
    [self PostRequest: @"login"
           parameters: parameters
              success:^(id responseObject) {
                  
                  if ([responseObject objectForKey:@"token"]) {
                      NSString *token = [responseObject objectForKey:@"token"];
                      [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"api_token"];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                  }
                  
                  if ([responseObject objectForKey:@"user"]) {
                      NSDictionary* dicUser = responseObject[@"user"];
                      
                      //User *_user = [[User alloc] initWithJSONDict:dicUser];
                      
                      success(dicUser);
                  } else {
                      failure(@"User UnAuthorised");
                  }
                  
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) updateProfile: (NSString*) firstName
              lastName: (NSString*) lastName
           oldPassword: (NSString*) oldPassword
           newPassword: (NSString*) newPassword
                avatar: (NSString*) avatar
              isFBUser: (BOOL) isFBUser
               success: (void (^)(NSDictionary *dicUser))success
               failure: (void (^)(NSString *errorMessage))failure
{
    NSString* name = [NSString stringWithFormat: @"%@ %@", firstName, lastName];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"user_id",
                                       name, @"name",
                                       nil];
    
    if(avatar != nil)
    {
        [parameters setObject: avatar forKey: @"avatar"];
    }
    
    if(!isFBUser)
    {
        [parameters setObject: oldPassword forKey: @"old_password"];
        [parameters setObject: newPassword forKey: @"new_password"];
    }
    
    [self PostRequest: @"user_api/update_profile.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSDictionary* dicUser = responseObject[@"user"];
                      success(dicUser);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) loginWithFB: (NSString*) fbid
                name: (NSString*) name
               email: (NSString*) email
             success: (void (^)(NSDictionary *dicUser))success
             failure: (void (^)(NSString *errorMessage))failure
{
    NSString* avatar = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fbid];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       fbid, @"fb_id",
                                       name, @"name",
                                       email, @"email",
                                       avatar, @"avatar",
                                       [AppEngine getValidString: [AppEngine sharedInstance].currentDeviceToken], @"device_token",
                                       nil];
    
    [self PostRequest: @"user_api/login_facebook.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSDictionary* dicUser = responseObject[@"user"];
                      success(dicUser);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) forgotPassword: (NSString*) email
                success: (void (^)(NSDictionary *responseObject))success
                failure: (void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       email, @"email",
                                       nil];
    
    
    [self PostRequest: @"user_api/forgotpassword.php"
           parameters: parameters
              success:^(id responseObject) {
                  success(responseObject);
              } failure:^(NSError *error) {
                  failure(error);
              }];
}

- (void) addPaypal: (NSString*) paypalEmail
           success: (void (^)(void))success
           failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       paypalEmail, @"paypal",
                                       [NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"user_id",
                                       nil];
    
    [self PostRequest: @"user_api/add_paypal.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  success();
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) getUserInfo: (int) user_id
             success: (void (^)(NSDictionary *dicUser))success
             failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: user_id], @"user_id",
                                       nil];
    
    [self PostRequest: @"user_api/get_my_info.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSDictionary* dicUser = responseObject[@"user"];
                      success(dicUser);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) postFeed: (NSString*) imageURL
      description: (NSString*) description
           amount: (int) amount
          user_id: (int) user_id
          success: (void (^)(NSDictionary *dicFeed, NSDictionary* dicUser))success
          failure: (void (^)(NSString *errorMessage))failure
{
    NSString *stripe_user_id = @"";
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"stripe_userid"]) {
        stripe_user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"stripe_userid"];
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       imageURL, @"photo_url",
                                       description, @"description",
                                       [NSNumber numberWithInt: amount], @"goal_amount_cents",
                                       nil];
    
    [self PostRequest: @"projects"
           parameters: parameters
              success:^(id responseObject) {
                  
                  NSDictionary* dicFeed = responseObject;
                  NSDictionary* dicUser = responseObject[@"owner"];
                  success(dicFeed, dicUser);
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) getSingleFeed: (NSString*) feed_id
               success: (void (^)(NSDictionary *dicFeed))success
               failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       feed_id, @"feed_id",
                                       nil];
    
    [self PostRequest: @"feed_api/get_single_feed.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  NSLog(@"response = %@", responseObject);
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSDictionary* dicFeed = responseObject[@"data"][@"feed"];
                      success(dicFeed);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];

}

- (void) getUserFeeds: (int) user_id
                limit: (int) limit
               offset: (int) offset
              success: (void (^)(NSArray *arrFeed))success
              failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: user_id], @"user_id",
                                       [NSNumber numberWithInt: offset], @"offset",
                                       [NSNumber numberWithInt: limit], @"limit",
                                       [NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"current_user_id",
                                       nil];
    
    [self PostRequest: @"feed_api/get_user_feed.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  NSLog(@"response = %@", responseObject);
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSArray* arrFeeds = responseObject[@"data"][@"feeds"];
                      success(arrFeeds);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}


- (void) getHomeFeeds: (int) limit
               offset: (int) offset
              success: (void (^)(NSArray *arrFeed))success
              failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: offset], @"offset",
                                       [NSNumber numberWithInt: limit], @"limit",
                                       nil];
    
    
    
    [self GETRequest: @"projects"
           parameters: parameters
              success:^(id responseObject) {
                  
                  FEMMapping *mapping = [DSMappingProvider projectsMapping];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  success(arrFeeds);
                  /*
                  NSLog(@"response = %@", responseObject);
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSArray* arrFeeds = responseObject[@"data"][@"feeds"];
                      success(arrFeeds);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  */
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) getPersonalFeeds: (int) limit
                   offset: (int) offset
                  success: (void (^)(NSArray *arrFeed))success
                  failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: offset], @"offset",
                                       [NSNumber numberWithInt: limit], @"limit",
                                       [NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"owner_id",
                                       nil];
    
    [self GETRequest: @"projects"
           parameters: parameters
              success:^(id responseObject) {
                  
                  FEMMapping *mapping = [DSMappingProvider projectsMapping];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  success(arrFeeds);
                  /*
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSArray* arrFeeds = responseObject[@"data"][@"feeds"];
                      success(arrFeeds);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }*/
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) getMyFeeds: (int) user_id
            success: (void (^)(NSArray *arrFeed))success
            failure: (void (^)(NSString *errorMessage))failure;
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: user_id], @"user_id",
                                       nil];
    
    [self PostRequest: @"feed_api/get_my_feed.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  NSLog(@"response = %@", responseObject);
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSArray* arrFeeds = responseObject[@"data"][@"feeds"];
                      success(arrFeeds);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) getFundedFeeds: (int) user_id
                success: (void (^)(NSArray *arrFeed))success
                failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: user_id], @"user_id",
                                       nil];
    
    [self PostRequest: @"feed_api/get_funded_feed.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  NSLog(@"response = %@", responseObject);
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      if([[responseObject allKeys] containsObject: @"data"])
                      {
                          NSArray* arrFeeds = responseObject[@"data"][@"feeds"];
                          success(arrFeeds);
                      }
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) removeFeed: (Feed*) f
            user_id: (int) user_id
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       f.feed_id, @"feed_id",
                                       [NSNumber numberWithInt: user_id], @"user_id",
                                       nil];
    
    [self PostRequest: @"feed_api/delete_feed.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  NSLog(@"response = %@", responseObject);
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      success();
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

#pragma mark - Donate 
- (void) postDonate: (int) user_id
            feed_id: (NSString*) feed_id
             amount: (int) amount
            success: (void (^)(NSDictionary* dicDonate))success
            failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       feed_id, @"feed_id",
                                       [NSNumber numberWithInt: amount], @"amount",
                                       [NSNumber numberWithInt: user_id], @"user_id",
                                       nil];
    
    [self PostRequest: @"donate_api/post_donate.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSDictionary* dicDonate = responseObject[@"donate"];
                      success(dicDonate);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) postStripeDonate: (int) user_id
                  feed_id: (NSString*) feed_id
         source_stripe_id: (NSString*) source_stripe_id
             stripe_token: (NSString *) stripe_token
                   amount: (int) amount
                  success: (void (^)(NSDictionary* dicDonate))success
                  failure: (void (^)(NSString *errorMessage))failure
{
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", STRIPE_API_KEY] forHTTPHeaderField:@"Authorization"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    int fee = amount * 100 * 0.07;
    NSDictionary *parameters = @{@"amount":[NSNumber numberWithInt:amount*100],
                                 @"currency":@"usd",
                                 @"source":stripe_token,
                                 @"destination":source_stripe_id,
                                 @"application_fee":[NSNumber numberWithInteger:fee],
                                 @"description":@"Charged for DonorSee donation"
                                 };
    
    [manager POST:STRIPE_CONNECT_CHARGES_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"success!");
        
        [self postDonate:user_id feed_id:feed_id amount:amount success:success failure:failure];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

- (void) createStipeAccountForUser: (int)user_id
                             email: (NSString *)email
                      stripe_token: (NSString *) stripe_token
                           success: (void (^)(NSDictionary* dicDonate))success
                           failure: (void (^)(NSString *errorMessage))failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", STRIPE_API_KEY] forHTTPHeaderField:@"Authorization"];
    
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters = @{@"source":stripe_token,
                                 @"email":email };
    
    [manager POST:STRIPE_CONNECT_CUSTOMER_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success!");
        
        /*
         
         {
         "account_balance" = 0;
         created = 1467873265;
         currency = "<null>";
         "default_source" = "card_18UW5YDAyu7GKAGHiDgrN7so";
         delinquent = 0;
         description = "<null>";
         discount = "<null>";
         email = "kk@gmail.com";
         id = "cus_8m4EjrivGrc0o2";
         livemode = 0;
         metadata =     {
         };
         object = customer;
         shipping = "<null>";
         sources =     {
         data =         (
         {
         "address_city" = "<null>";
         "address_country" = "<null>";
         "address_line1" = "<null>";
         "address_line1_check" = "<null>";
         "address_line2" = "<null>";
         "address_state" = "<null>";
         "address_zip" = "<null>";
         "address_zip_check" = "<null>";
         brand = Visa;
         country = US;
         customer = "cus_8m4EjrivGrc0o2";
         "cvc_check" = pass;
         "dynamic_last4" = "<null>";
         "exp_month" = 9;
         "exp_year" = 2017;
         fingerprint = mGuJ4OCxm6svEHlG;
         funding = credit;
         id = "card_18UW5YDAyu7GKAGHiDgrN7so";
         last4 = 4242;
         metadata =                 {
         };
         name = "<null>";
         object = card;
         "tokenization_method" = "<null>";
         }
         );
         "has_more" = 0;
         object = list;
         "total_count" = 1;
         url = "/v1/customers/cus_8m4EjrivGrc0o2/sources";
         };
         subscriptions =     {
         data =         (
         );
         "has_more" = 0;
         object = list;
         "total_count" = 0;
         url = "/v1/customers/cus_8m4EjrivGrc0o2/subscriptions";
         };
         }
         */
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

- (void) getUserSavedCardsFromStripe:(NSString *)stripe_id
                             success: (void (^)(NSDictionary* dicDonate))success
                             failure: (void (^)(NSString *errorMessage))failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", STRIPE_API_KEY] forHTTPHeaderField:@"Authorization"];
    
    NSString *listCardsURL = [NSString stringWithFormat:@"%@/%@/sources?object=card", STRIPE_CONNECT_CUSTOMER_URL, stripe_id];
    
    [manager GET:listCardsURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"responseObject %@", responseObject);
        
        if ([responseObject objectForKey:@"data"]) {
            success(responseObject);
        }
            
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}


- (void) getStripeTokenForSavedCard:(NSString *)stripe_car_id
                            success: (void (^)(NSDictionary* dicDonate))success
                            failure: (void (^)(NSString *errorMessage))failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", STRIPE_API_KEY] forHTTPHeaderField:@"Authorization"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters = @{@"card":stripe_car_id};
    
    [manager POST:STRIPE_CONNECT_TOKENS_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject %@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - Withdraw.
- (void) withdrawMoney: (NSString*) email
               message: (NSString*) message
                amount: (NSString*) amount
               user_id: (int) user_id
               success: (void (^)(NSDictionary* dicWithdraw))success
               failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       email, @"email",
                                       message, @"message",
                                       amount, @"amount",
                                       [NSNumber numberWithInt: user_id], @"user_id",
                                       nil];
    
    [self PostRequest: @"withdraw_api/post_withdraw.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSDictionary* dicWithdraw = responseObject[@"withdraw"];
                      success(dicWithdraw);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

#pragma mark - Activities.

- (void) readActivity: (int) activity_id
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: activity_id], @"activity_id",
                                       nil];
    
    [self PostRequest: @"activity_api/read_activity.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                  }
                  
              } failure:^(NSError *error) {
                  
              }];

}

- (void) readNotification: (int) notification_id
{
    NSString *path = [NSString stringWithFormat:@"activity_api/read_notification.php?notification_id=%i", notification_id];
    [self PostRequest: path
           parameters: nil
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                  }
                  
              } failure:^(NSError *error) {
                  
              }];
    
}


- (void) getNotifications: (void (^)(NSArray* notifications))success
                 failure: (void (^)(NSString *errorMessage))failure
{
    
    NSString *path = [NSString stringWithFormat:@"activity_api/get_notification.php?user_id=%i", [AppEngine sharedInstance].currentUser.user_id];
    
    [self PostRequest: path
           parameters: nil
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  NSMutableArray* arrActivityResults = [[NSMutableArray alloc] init];
                  if(status && responseObject[@"notification"] != [NSNull null])
                  {
                      NSArray* arrActivites = responseObject[@"notification"];
                      if(arrActivites != nil)
                      {
                          for(NSDictionary* dicItem in arrActivites)
                          {
                              Notification* a = [[Notification alloc] initWithDictionary: dicItem];
                              [arrActivityResults addObject: a];
                          }
                      }
                  }
                  success(arrActivityResults);
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
    
}
- (void) getMyActivities: (void (^)(NSArray* arrActivities))success
                 failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"user_id",
                                       nil];
    
    [self PostRequest: @"activity_api/get_my_activity.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  int status = [responseObject[@"success"] boolValue];
                  NSMutableArray* arrActivityResults = [[NSMutableArray alloc] init];
                  if(status && responseObject[@"activities"] != [NSNull null])
                  {
                      NSArray* arrActivites = responseObject[@"activities"];
                      if(arrActivites != nil)
                      {
                          for(NSDictionary* dicItem in arrActivites)
                          {
                              Activity* a = [[Activity alloc] initActivityWithDictionary: dicItem];
                              [arrActivityResults addObject: a];
                          }
                      }
                  }
                  success(arrActivityResults);
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
    
}

- (void) getActivitiesForFeed: (Feed*) f
                      success: (void (^)(NSArray* arrActivities, Feed* feed))success
                      failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       f.feed_id, @"project",
                                       nil];
    
    [self GETRequest: @"events"
           parameters: parameters
              success:^(id responseObject) {
                  
                  //NSLog(@"responseObject %@", responseObject);
                  
                  FEMMapping *mapping = [DSMappingProvider eventMapping];
                  NSMutableArray* arrActivityResults = [[NSMutableArray alloc] init];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  [arrActivityResults addObjectsFromArray:arrFeeds];
                  success(arrActivityResults, f);
                  /*
                  int status = [responseObject[@"success"] boolValue];
                  
                  NSMutableArray* arrFollowMessageResults = [[NSMutableArray alloc] init];
                  
                  if(status)
                  {
                      if (responseObject[@"feed"] == [NSNull null]) {
                          failure(MSG_FEED_DELETED);
                          return;
                      }
                      
                      NSDictionary* dicFeed = responseObject[@"feed"];
                      Feed* f = [[Feed alloc] initWithHomeFeed: dicFeed];
                      
                      NSArray* arrFollowMessages = responseObject[@"follow_messages"];
                      if(arrFollowMessages != nil)
                      {
                          for(NSDictionary* dicItem in arrFollowMessages)
                          {
                              FollowMessage* m = [[FollowMessage alloc] initWithDictionary: dicItem];
                              [arrFollowMessageResults addObject: m];
                          }
                      }
                      
                      NSArray* arrActivites = responseObject[@"activities"];
                      BOOL isFullyFunded = NO;
                      if(arrActivites != nil)
                      {
                          for(NSDictionary* dicItem in arrActivites)
                          {
                              Activity* a = [[Activity alloc] initActivityWithDictionary: dicItem];
                              if(a.type == ACTIVITY_FOLLOW_MESSAGE)
                              {
                                  for(FollowMessage* m in arrFollowMessageResults)
                                  {
                                      if(m.message_id == a.object_id)
                                      {
                                          a.followMessage = m;
                                          break;
                                      }
                                  }
                              }
                              //
                              
                              
                              if (a.type != ACTIVITY_FULL_DONATED)
                              {
                                  [arrActivityResults addObject: a];
                              } else {
                                  if (!isFullyFunded) {
                                      //[arrActivityResults addObject: a];
                                      //a.type = ACTIVITY_DONATED;
                                      
                                      isFullyFunded = YES;
                                      Activity* b = [[Activity alloc] initActivityWithDictionary: dicItem];
                                      [arrActivityResults addObject: b];
                                  } else {
                                      [arrActivityResults addObject: a];
                                      a.type = ACTIVITY_DONATED;
                                  }
                              }
                          }
                      }
                      
                      success(arrActivityResults, f);
                  }
                  else
                  {
                      failure(MSG_DISCONNECT_INTERNET);                      
                  }*/
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

#pragma mark - Follow
- (void) followUser: (int) follower_id
       following_id: (int) following_id
            success: (void (^)(User* followerUser, User* followingUser))success
            failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: follower_id], @"follower_id",
                                       [NSNumber numberWithInt: following_id], @"following_id",
                                       nil];
    
    [self PostRequest: @"follow_api/follow_user.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  BOOL status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSDictionary* dicFollower = responseObject[@"follower_user"];
                      NSDictionary* dicFollowing = responseObject[@"following_user"];
                      
                      User* followerUser = [[User alloc] initUserWithDictionary: dicFollower];
                      User* followingUser = [[User alloc] initUserWithDictionary: dicFollowing];
                      
                      success(followerUser, followingUser);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}


- (void) unfollowUser: (int) follower_id
         following_id: (int) following_id
              success: (void (^)(User* followerUser, User* followingUser))success
              failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: follower_id], @"follower_id",
                                       [NSNumber numberWithInt: following_id], @"following_id",
                                       nil];
    
    [self PostRequest: @"follow_api/unfollow_user.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  BOOL status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      NSDictionary* dicFollower = responseObject[@"follower_user"];
                      NSDictionary* dicFollowing = responseObject[@"following_user"];
                      
                      User* followerUser = [[User alloc] initUserWithDictionary: dicFollower];
                      User* followingUser = [[User alloc] initUserWithDictionary: dicFollowing];
                      
                      success(followerUser, followingUser);
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

#pragma Follow Messages.

- (void) postFollowMessage: (NSString*) message
                    photos: (NSArray*) arrPhotos
                      feed: (Feed*) f
                   success: (void (^)(void))success
                   failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       f.feed_id, @"feed_id",
                                       [NSNumber numberWithInt: f.post_user_id], @"receiver_user_id",
                                       [NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"user_id",
                                       message, @"message",
                                       nil];
    
    if(arrPhotos != nil && [arrPhotos count] > 0)
    {
        NSString* photos = [arrPhotos componentsJoinedByString: @","];
        [parameters setObject: photos forKey: @"photos"];
    }
    
    [self PostRequest: @"follow_message_api/post_follow_message.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  BOOL status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      success();
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

#pragma mark - Report.
- (void) reportFeed: (Feed*) f
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       f.feed_id, @"object_id",
                                       [NSNumber numberWithInt: REPORT_FEED], @"type",
                                       [NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"user_id",
                                       [AppEngine sharedInstance].currentUser.email, @"email",
                                       nil];
    
    [self PostRequest: @"report_api/report_feed.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  BOOL status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      success();
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) reportUser: (User*) u
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: u.user_id], @"object_id",
                                       [NSNumber numberWithInt: REPORT_USER], @"type",
                                       [NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"user_id",
                                       [AppEngine sharedInstance].currentUser.email, @"email",
                                       nil];
    
    [self PostRequest: @"report_api/report_user.php"
           parameters: parameters
              success:^(id responseObject) {
                  
                  BOOL status = [responseObject[@"success"] boolValue];
                  if(status)
                  {
                      success();
                  }
                  else
                  {
                      NSString* message = responseObject[@"message"];
                      failure(message);
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}


- (void) cancelAllRequest
{
    
}

- (void) getUnReadCountInfo: (int) user_id
             success: (void (^)(NSDictionary *dicUser))success
             failure: (void (^)(NSString *errorMessage))failure
{
    
    NSString *path = [NSString stringWithFormat:@"activity_api/get_unread_count_notification.php?user_id=%i", user_id];
    
    [self GETRequest:path parameters:nil success:^(id responseObject) {
        int status = [responseObject[@"success"] boolValue];
        if(status)
        {
            //NSDictionary* dicUser = responseObject[@"user"];
            success(responseObject);
        }
        else
        {
            NSString* message = responseObject[@"message"];
            failure(message);
        }
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}

- (void) getUserFollowStatus:(int) selectedUser_id
                     user_id:(int) user_id
                     success: (void (^)(NSDictionary *followStatus))success
                     failure: (void (^)(NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"follow_api/is_follow.php?user_id=%i&logged_user_id=%i",selectedUser_id, user_id];
    
    [self GETRequest:path parameters:nil success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}

- (void) checkAppVersion: (int) user_id
                 version:(NSString *)version
                 success: (void (^)(NSDictionary *dicUser))success
                 failure: (void (^)(NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"user_api/check_version.php?user_id=%i&app_version=%@",user_id, version];
    
    [self GETRequest:path parameters:nil success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}

@end
