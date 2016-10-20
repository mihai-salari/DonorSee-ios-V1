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
#import "Cloudinary/Cloudinary.h"
#import "AppDelegate.h"
#import "MediaFile.h"

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
        
        
        [client.requestSerializer setTimeoutInterval: REQUEST_TIME_OUT];

        //Response;
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializer];
        client.responseSerializer = responseSerializer;
        //client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    });
    
    
    return client;
}

- (void)addTokenIfExist{
    NSString *apiToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_token"];
    if ([apiToken isKindOfClass:[NSString class]] && ![apiToken isEqualToString:@""]){
        [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", apiToken] forHTTPHeaderField:@"Authorization"];
    }
}

- (void) GETRequest: (NSString *)URLString
         parameters: (nullable id)parameters
            success:(nullable void (^)(id responseObject))success
            failure:(nullable void (^)(NSError *error))failure
{
    [self addTokenIfExist];

    
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
    [self addTokenIfExist];
    
    [self POST: URLString
    parameters: parameters
      progress:^(NSProgress * _Nonnull uploadProgress) {
          
      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
          success(responseObject);
          
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          failure(error);
      }];
}

- (void) DeleteRequest: (NSString *)URLString
          parameters: (nullable id)parameters
             success:(nullable void (^)(id responseObject))success
             failure:(nullable void (^)(NSError *error))failure
{
    [self addTokenIfExist];
    
    [self DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void) updateDeviceToken {
    
    //[AppEngine sharedInstance].currentDeviceToken = @"3de17731eef7b45b033940867066a41a944c455738a5acd40b4286c359e96d6e";
    
    if ([AppEngine sharedInstance].currentDeviceToken != nil) {
        
        if([AppEngine sharedInstance].currentUser != nil) {
            
            int user_id = [AppEngine sharedInstance].currentUser.user_id;
            
            [self PostRequest: [NSString stringWithFormat:@"users/%i/device-tokens", user_id]
                   parameters: @{@"token":[AppEngine sharedInstance].currentDeviceToken}
                     success:^(id responseObject) {
                         NSLog(@"Device Token saved: %@", [AppEngine sharedInstance].currentDeviceToken);                         
                     } failure:^(NSError *error) {
                         
                         //failure(MSG_DISCONNECT_INTERNET);
                     }];
            
        }
    }
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
                                       nil];
    
    if (![avatar isEqualToString:@""]) {
        [parameters setValue:avatar forKey:@"photo_url"];
    }
    



        [self POST:@"users" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if ([responseObject objectForKey:@"token"]) {
                NSString *token = [responseObject objectForKey:@"token"];
                [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"api_token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSDictionary* dicUser = responseObject[@"user"];
            success(dicUser);
            [self updateDeviceToken];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSInteger statusCode = 0;
            
            NSHTTPURLResponse *httpResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            
            if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                statusCode = httpResponse.statusCode;
            }
            
            if (statusCode == 400) {
                
                NSData *responseErrorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseErrorData
                                                                     options:kNilOptions
                                                                       error:&error];
                
                if ([json objectForKey:@"errors"] != nil) {
                    
                    NSDictionary *errors = [json objectForKey:@"errors"];
                    if ([errors objectForKey:@"email"]) {
                        NSArray *emailerror = [NSArray arrayWithArray:[errors objectForKey:@"email"]];
                        if (emailerror.count > 0) {
                            failure(emailerror.firstObject);
                            return;
                        }
                    }
                }
            }
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
                      success(dicUser);
                      [self updateDeviceToken];
                  } else {
                      failure(@"User UnAuthorised");
                  }
                  
                  
              } failure:^(NSError *error) {
                  
                  NSInteger statusCode = 0;
                  
                  NSHTTPURLResponse *httpResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];

                  
                  if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                      statusCode = httpResponse.statusCode;
                  }
                  
                  if (statusCode == 401 || statusCode == 404) {
                      
                      NSData *responseErrorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                      NSError* error;
                      NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseErrorData
                                                                           options:kNilOptions
                                                                             error:&error];
                      
                      if ([json objectForKey:@"message"] != nil) {
                          failure([json objectForKey:@"message"]);
                          return;
                      }
                      
                      
                      
                  }

                  
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
    
    [self addTokenIfExist];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       firstName, @"first_name",
                                       lastName, @"last_name",
                                       nil];
    
    //[NSNumber numberWithInt: [AppEngine sharedInstance].currentUser.user_id], @"user_id",
    
    
    
    if(avatar != nil)
    {
        [parameters setObject: avatar forKey: @"photo_url"];
    }
    
    if (![newPassword isEqualToString:@""]) {
        [parameters setObject: newPassword forKey: @"password"];
    }
    
    [self PATCH:[NSString stringWithFormat:@"users/%i",[AppEngine sharedInstance].currentUser.user_id] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

- (void) loginWithFB: (NSString*) fbid
           firstName: (NSString*) firstName
            lastName: (NSString*) lastName
               email: (NSString*) email
             success: (void (^)(NSDictionary *dicUser))success
             failure: (void (^)(NSString *errorMessage))failure
{
    NSString* avatar = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fbid];

    NSDictionary *parameters = @{@"fb_id":fbid, @"first_name":firstName, @"last_name":lastName, @"email":email, @"photo_url":avatar};
    
    
    [self PostRequest: @"login/facebook"
           parameters: parameters
              success:^(id responseObject) {
                  
                  if ([responseObject objectForKey:@"token"]) {
                      NSString *token = [responseObject objectForKey:@"token"];
                      [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"api_token"];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                  }
                  
                  if ([responseObject objectForKey:@"user"]) {
                      NSDictionary* dicUser = responseObject[@"user"];
                      success(dicUser);
                      [self updateDeviceToken];
                  } else {
                      failure(@"User UnAuthorised");
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) forgotPassword: (NSString*) email
                success: (void (^)(NSDictionary *responseObject))success
                failure: (void (^)(NSString *errorMessage))failure
{
    
    [self addTokenIfExist];
    
    [self GET:[NSString stringWithFormat:@"users/password-reset?email=%@", email] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(@{@"message":@"Password has been successfully changed"});
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

- (void) verifyPin:(NSString *)pin
       newPassword:(NSString *)newPassword
             email:(NSString *)email
           success: (void (^)(NSDictionary *responseObject))success
           failure: (void (^)(NSString *errorMessage))failure
{
    
    [self addTokenIfExist];
    
    NSDictionary *parameters = @{@"pin":pin, @"email":email, @"new_password":newPassword};
    
    [self PostRequest: @"users/password-reset"
           parameters: parameters
              success:^(id responseObject) {
                  
                  if ([responseObject objectForKey:@"token"]) {
                      NSString *token = [responseObject objectForKey:@"token"];
                      [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"api_token"];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                  }
                  
                  if ([responseObject objectForKey:@"user"]) {
                      NSDictionary* dicUser = responseObject[@"user"];
                      success(dicUser);
                      [self updateDeviceToken];
                  } else {
                      failure(@"User UnAuthorised");
                  }
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
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
    [self GETRequest: [NSString stringWithFormat:@"users/%i", user_id]
           parameters: nil
              success:^(id responseObject) {
                  
                  success(responseObject);
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) getTransactionHistory: (int) user_id
                       success: (void (^)(NSArray *transactions))success
                       failure: (void (^)(NSString *errorMessage))failure
{
    [self GETRequest: [NSString stringWithFormat:@"users/%i/gifts", user_id]
          parameters: nil
             success:^(id responseObject) {
                 
                 success(responseObject);
                 
             } failure:^(NSError *error) {
                 
                 failure(MSG_DISCONNECT_INTERNET);
             }];
}


- (void) getReceivedGiftsTransactionHistory: (int) user_id
                       success: (void (^)(NSArray *transactions))success
                       failure: (void (^)(NSString *errorMessage))failure
{
    [self GETRequest: [NSString stringWithFormat:@"users/%i/received-gifts", user_id]
          parameters: nil
             success:^(id responseObject) {
                 
                 success(responseObject);
                 
             } failure:^(NSError *error) {
                 
                 failure(MSG_DISCONNECT_INTERNET);
             }];
}


- (void) postFeed: (MediaFile*) mediaFile
      description: (NSString*) description
           amount: (int) amount
          user_id: (int) user_id
        feed_type: (NSString*) feed_type
          country: (NSString*) country
          success: (void (^)(NSDictionary *dicFeed, NSDictionary* dicUser))success
          failure: (void (^)(NSString *errorMessage))failure
{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                
                                      description, @"description",
                                      [NSNumber numberWithInt: amount*100], @"goal_amount_cents",
                                      feed_type, @"gift_type",
                                      nil];

    
    if(mediaFile.mediaType == VIDEO){
        [parameters setObject:mediaFile.mediaURL forKey:@"video_url"];
    }else{
        [parameters setObject:mediaFile.mediaURL forKey:@"photo_url"];
    }
    
    if(country!=nil){
        [parameters setObject:country forKey:@"country_code"];
    }
    
    
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
- (void) UpdatepostFeed: (MediaFile*) mediaFile
      description: (NSString*) description
           amount: (int) amount
          user_id: (int) user_id
        gift_type: (NSString*) gift_type
          country:(NSString*) country
          success: (void (^)(NSDictionary *dicFeed, NSDictionary* dicUser))success
          failure: (void (^)(NSString *errorMessage))failure
{
    
    [self addTokenIfExist];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       description, @"description",
                                       [NSNumber numberWithInt: amount*100], @"goal_amount_cents",
                                       nil];
    
    if(mediaFile.mediaURL!=nil){
        if(mediaFile.mediaType == VIDEO){
            [parameters setObject:mediaFile.mediaURL forKey:@"video_url"];
        }else{
            [parameters setObject:mediaFile.mediaURL forKey:@"photo_url"];
        }
    }
    
    if(country != nil){
        [parameters setObject:country forKey:@"country_code"];
    }
    
    if(gift_type!=nil){
        [parameters setObject:gift_type  forKey:@"gift_type"];
    }
    
    NSLog(@"%d",[AppEngine sharedInstance].currentUser.lastSelectedId);
    [self PATCH:[NSString stringWithFormat:@"projects/%i",[AppEngine sharedInstance].currentUser.lastSelectedId] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        NSDictionary* dicFeed = responseObject;
        NSDictionary* dicUser = responseObject[@"owner"];
        success(dicFeed, dicUser);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}

- (void) getSingleFeed: (NSString*) feed_id
               success: (void (^)(NSDictionary *dicFeed))success
               failure: (void (^)(NSString *errorMessage))failure
{
    
    [self GETRequest: [NSString stringWithFormat:@"projects/%@", feed_id]
           parameters: nil
              success:^(id responseObject) {
                  
                  NSLog(@"response = %@", responseObject);
                  
                  success(responseObject);
                  
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
                                       [NSNumber numberWithInt: user_id], @"owner_id",
                                       [NSNumber numberWithInt: offset], @"offset",
                                       [NSNumber numberWithInt: limit], @"limit",
                                       nil];
    
    [self GETRequest: @"projects"
           parameters: parameters
              success:^(id responseObject) {
                  
                  NSLog(@"response = %@", responseObject);
                  FEMMapping *mapping = [DSMappingProvider projectsMapping];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  success(arrFeeds);
                  
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
                                       nil];
    
    [self GETRequest: @"projects/personal"
           parameters: parameters
              success:^(id responseObject) {
                  
                  FEMMapping *mapping = [DSMappingProvider projectsMapping];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  success(arrFeeds);                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) getStaffPicksFeeds: (int) limit
                     offset: (int) offset
                    success: (void (^)(NSArray *arrFeed))success
                    failure: (void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: offset], @"offset",
                                       [NSNumber numberWithInt: limit], @"limit",
                                       nil];
    
    [self GETRequest: @"projects/staff-picks"
          parameters: parameters
             success:^(id responseObject) {
                 
                 FEMMapping *mapping = [DSMappingProvider projectsMapping];
                 NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                 success(arrFeeds);
             } failure:^(NSError *error) {
                 
                 failure(MSG_DISCONNECT_INTERNET);
             }];

}

- (void) getMyFeeds: (int) user_id
            success: (void (^)(NSArray *arrFeed))success
            failure: (void (^)(NSString *errorMessage))failure;
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt: user_id], @"owner_id",
                                       nil];
    
    [self GETRequest: @"projects"
           parameters: parameters
              success:^(id responseObject) {
                  
                  FEMMapping *mapping = [DSMappingProvider projectsMapping];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  success(arrFeeds);
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) getFundedFeeds: (int) user_id
                success: (void (^)(NSArray *arrFeed))success
                failure: (void (^)(NSString *errorMessage))failure
{
    /*
    [self GETRequest: [NSString stringWithFormat:@"users/%i/gifts", user_id]
           parameters: nil
              success:^(id responseObject) {
                  FEMMapping *mapping = [DSMappingProvider giftsMapping];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  success(arrFeeds);
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];*/
    
    [self addTokenIfExist];
    
    
//    [self GET: @"projects/given-to"
//   parameters: nil
//     progress:^(NSProgress * _Nonnull downloadProgress) {
//         
//     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//         success(responseObject);
//     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//         failure(error);
//     }];
    
    [self GETRequest:@"projects/given-to"
          parameters: nil
             success:^(id responseObject) {
                // FEMMapping *mapping = [DSMappingProvider NewgiftsMapping];
                // NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                 NSArray* arr =[NSArray arrayWithObject:responseObject];
                 NSArray* arrFeeds =[arr objectAtIndex:0];
                 NSLog(@"%d",arrFeeds.count);
                 success(arrFeeds);
             } failure:^(NSError *error) {
                 
                 failure(MSG_DISCONNECT_INTERNET);
             }];
}

- (void) removeFeed: (Feed*) f
            user_id: (int) user_id
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure
{
    
    [self addTokenIfExist];
    
    NSString *path = [NSString stringWithFormat:@"projects/%@", f.feed_id];
    
    
    [self DELETE:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSInteger statusCode = 0;
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if (statusCode == 403) {
        
            NSData *responseErrorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseErrorData
                                                                 options:kNilOptions
                                                                   error:&error];

            if ([json objectForKey:@"message"] != nil) {
                failure([json objectForKey:@"message"]);
                return;
            }
            
            
            
        }
        
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

- (void) getUserSavedCards:(int) user_id
                   success: (void (^)(NSArray* cards))success
                   failure: (void (^)(NSString *errorMessage))failure
{
    
    [self GETRequest:[NSString stringWithFormat:@"users/%i/cards", user_id] parameters:nil success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

- (void) saveUserCard:(int) user_id
         stripe_token: (NSString *) stripe_token
              success: (void (^)(NSDictionary* cardInfo))success
              failure: (void (^)(NSString *errorMessage))failure
{
    [self PostRequest:[NSString stringWithFormat:@"users/%i/cards", user_id] parameters:@{@"token":stripe_token} success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}


- (void) removeUserCard:(int) user_id
         card_id: (NSString *) card_id
              success: (void (^)(NSDictionary* cardInfo))success
              failure: (void (^)(NSString *errorMessage))failure
{
    
    [self DeleteRequest:[NSString stringWithFormat:@"users/%i/cards/%@", user_id, card_id] parameters:nil success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}



- (void) createGift: (NSString *) feed_id
             amount: (int) amount
          gift_type: (NSString*) gift_type
            success: (void (^)(NSDictionary* dicDonate))success
            failure: (void (^)(NSString *errorMessage))failure
{
    [self PostRequest:[NSString stringWithFormat:@"projects/%@/gifts", feed_id]
           parameters:@{@"amount_cents":[NSNumber numberWithInt:amount*100],
                        @"gift_type":gift_type
                        }
              success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}
#pragma mark -
#pragma mark Stripe Connect API Related.

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

- (void) getStripeKey: (void (^)(NSDictionary* stripeInfo))success
                 failure: (void (^)(NSString *errorMessage))failure
{
    [self GETRequest: @"config"
          parameters: nil
             success:^(id responseObject) {
                 success(responseObject);
             } failure:^(NSError *error) {
                 failure(MSG_DISCONNECT_INTERNET);
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
    [self addTokenIfExist];
    
    NSString *path = [NSString stringWithFormat:@"users/%i/notifications/%i", [AppEngine sharedInstance].currentUser.user_id, activity_id];
    [self PATCH:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"responseObject %@", responseObject);
        [[AppDelegate getDelegate].mainTabBar updateNotificationBadge];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         //NSLog(@"error %@", error);
    }];
}

- (void) readNotification: (int) notification_id
{
    [self addTokenIfExist];
    
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
    [self addTokenIfExist];
    
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
    
    NSString *path = [NSString stringWithFormat:@"users/%i/notifications", [AppEngine sharedInstance].currentUser.user_id];
    
    [self GETRequest: path
           parameters: nil
              success:^(id responseObject) {
                  
                  FEMMapping *mapping = [DSMappingProvider eventMappingForNotification];
                  NSMutableArray* arrActivityResults = [[NSMutableArray alloc] init];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  [arrActivityResults addObjectsFromArray:arrFeeds];
                  success(arrActivityResults);
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
    
}

- (void) getActivitiesForFeed: (Feed*) f
                      success: (void (^)(NSArray* arrActivities, Feed* feed))success
                      failure: (void (^)(NSString *errorMessage))failure
{
    
    NSString *path = [NSString stringWithFormat:@"projects/%@/timeline", f.feed_id];
    
    [self GETRequest: path
           parameters: nil
              success:^(id responseObject) {
                  
                  //NSLog(@"responseObject %@", responseObject);
                  
                  FEMMapping *mapping = [DSMappingProvider eventMapping];
                  NSMutableArray* arrActivityResults = [[NSMutableArray alloc] init];
                  NSArray* arrFeeds = [FEMDeserializer collectionFromRepresentation:responseObject mapping:mapping];
                  [arrActivityResults addObjectsFromArray:arrFeeds];
                  success(arrActivityResults, f);
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

    NSString *path = [NSString stringWithFormat:@"users/%d/followers", following_id];
    
    [self addTokenIfExist];
    
    
    [self POST:path parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if (statusCode == 201) {
            success(nil,nil);
            return;
        }
        failure(MSG_DISCONNECT_INTERNET);
    }];
}


- (void) unfollowUser: (int) follower_id
         following_id: (int) following_id
              success: (void (^)(User* followerUser, User* followingUser))success
              failure: (void (^)(NSString *errorMessage))failure
{
    [self addTokenIfExist];
    
    NSString *path = [NSString stringWithFormat:@"users/%d/followers", following_id];
    
    [self DELETE:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //NSLog(@"responseObject %@", responseObject);
        success(nil,nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error %@", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if (statusCode == 204) {
            success(nil,nil);
            return;
        }
        
        failure(MSG_DISCONNECT_INTERNET);
    }];
    /*
    [self PostRequest: path
           parameters: nil
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
     
     */
}

#pragma Follow Messages.

- (void) postFollowMessage: (NSString*) message
                    photos: (NSArray*) arrPhotos
                    videos: (NSArray*) arrVideos
                      feed: (Feed*) f
                   success: (void (^)(void))success
                   failure: (void (^)(NSString *errorMessage))failure
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:message forKey:@"message"];
    if (arrPhotos.count > 0) {
        [parameters setValue:arrPhotos forKey:@"photo_urls"];
    }
    if (arrVideos.count > 0) {
        [parameters setValue:arrVideos forKey:@"video_urls"];
    }
    
    
    NSString *path = [NSString stringWithFormat:@"projects/%@/updates", f.feed_id];
    
    [self PostRequest: path
           parameters: parameters
              success:^(id responseObject) {
                  
                  success();
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}

- (void) postProjectComment:(NSString *)message
                       feed: (Feed*) f
                    success: (void (^)(void))success
                    failure: (void (^)(NSString *errorMessage))failure
{
    //projects/project_id/comments
    NSString *path = [NSString stringWithFormat:@"projects/%@/comments", f.feed_id];
    
    [self PostRequest: path
           parameters: @{@"message":message}
              success:^(id responseObject) {
                  
                  success();
                  
              } failure:^(NSError *error) {
                  
                  failure(MSG_DISCONNECT_INTERNET);
              }];
}


#pragma mark - Report.
- (void) reportFeed: (Feed*) f
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure
{

    [self addTokenIfExist];
    
    [self POST:[NSString stringWithFormat:@"projects/%@/abuse-reports", f.feed_id] parameters:@{@"message":@"Test user"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if (statusCode == 201) {
            success();
            return;
        }
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

- (void) reportUser: (User*) u
            success: (void (^)(void))success
            failure: (void (^)(NSString *errorMessage))failure
{
    [self addTokenIfExist];
    
    [self POST:[NSString stringWithFormat:@"users/%i/abuse-reports", u.user_id] parameters:@{@"message":@"Test user"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if (statusCode == 201) {
            success();
            return;
        }
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
    NSString *path = [NSString stringWithFormat:@"users/%i/notifications/unread/count", user_id];
    
    [self GETRequest:path parameters:nil success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}

- (void) getUserFollowStatus:(int) selectedUser_id
                     user_id:(int) user_id
                     success: (void (^)(NSArray *followStatus))success
                     failure: (void (^)(NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"users/%d/followers?limit=100", selectedUser_id];
    
    [self GETRequest:path parameters:nil success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
}

- (void) getUserFollowingStatus:(int) selectedUser_id
                     user_id:(int) user_id
                     success: (void (^)(NSArray *followStatus))success
                     failure: (void (^)(NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"users/%d/following?limit=100", selectedUser_id];
    
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


#pragma mark -
#pragma mark Image upload to Cloudinary
- (void) uploadImage:(NSData *) data
             success: (void (^)(NSDictionary *photoInfo))success
             failure: (void (^)(NSString *errorMessage))failure
{
    [self GETRequest:@"photos/presign" parameters:nil success:^(id responseObject) {
        
        NSLog(@"responseObject %@", responseObject);
        if ([responseObject objectForKey:@"url"]) {
            NSString *url = [responseObject objectForKey:@"url"];
            
            CLCloudinary *mobileCloudinary = [[CLCloudinary alloc] initWithUrl:url];
            [mobileCloudinary.config setValue:@"donorsee" forKey:@"cloud_name"];
            
            CLUploader* mobileUploader = [[CLUploader alloc] init:mobileCloudinary delegate:nil];
            
            [mobileUploader upload:data options:responseObject withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
                if (successResult) {
                    NSString* publicId = [successResult valueForKey:@"public_id"];
                    NSLog(@"Block upload success. Public ID=%@, Full result=%@", publicId, successResult);
                    success(successResult);
                } else {
                    NSLog(@"Block upload error: %@, %d", errorResult, code);
                    failure(errorResult);
                    
                }
            } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
                NSLog(@"Block upload progress: %d/%d (+%d)", totalBytesWritten, totalBytesExpectedToWrite, bytesWritten);
            }];
        } else {
            failure(MSG_DISCONNECT_INTERNET);
        }
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

- (void) uploadVideo: (NSData *) data
             success: (void (^)(NSDictionary *photoInfo))success
             failure: (void (^)(NSString *errorMessage))failure
{
    [self GETRequest:@"photos/presign" parameters:nil success:^(id responseObject) {
        
        NSLog(@"responseObject %@", responseObject);
        if ([responseObject objectForKey:@"url"]) {
            
            
            NSDictionary* config = [self getVideoConfig: responseObject];
    
            
            NSString *url = [responseObject objectForKey:@"url"];
            
            CLCloudinary *mobileCloudinary = [[CLCloudinary alloc] initWithUrl:url];
            [mobileCloudinary.config setValue:@"donorsee" forKey:@"cloud_name"];
            
            
            
            [mobileCloudinary.config setValue:@"ileub0hk_unsigned_video" forKey:@"upload_preset"];
            [mobileCloudinary.config setValue:@"video" forKey:@"resource_type"];
            
            
            
            CLUploader* mobileUploader = [[CLUploader alloc] init:mobileCloudinary delegate:nil];
            
            
            
            [mobileUploader unsignedUpload:data uploadPreset:@"ileub0hk_unsigned_video" options:config withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
                if (successResult) {
                    NSString* publicId = [successResult valueForKey:@"public_id"];
                    NSLog(@"Block upload success. Public ID=%@, Full result=%@", publicId, successResult);
                    success(successResult);
                } else {
                    NSLog(@"Block upload error: %@, %d", errorResult, code);
                    failure(errorResult);
                }
                
            }andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
                NSLog(@"Block upload progress: %d/%d (+%d)", totalBytesWritten, totalBytesExpectedToWrite, bytesWritten);
            }];

        } else {
            failure(MSG_DISCONNECT_INTERNET);
        }
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

- (NSMutableDictionary*) getVideoConfig:(NSDictionary*) preset {
    NSMutableDictionary* config = [[NSMutableDictionary alloc] init];
    
    [config setObject: [preset objectForKey:@"api_key"] forKey:@"api_key"];
    [config setObject: [preset objectForKey:@"folder"] forKey:@"folder"];
    [config setObject: [preset objectForKey:@"signature"] forKey:@"signature"];
    [config setObject: @"donorsee"  forKey:@"cloud_name"];
    [config setObject: @"ileub0hk_unsigned_video" forKey:@"upload_preset"];
    [config setObject: @"video" forKey:@"resource_type"];
    //[config setValue: @"true" forKey:@"unsigned"];
    
    return config;
}

- (void) cancelMonthlyDonation:(NSString*) project_id
                success: (void (^)(NSDictionary* info))success
                failure: (void (^)(NSString *errorMessage))failure
{
    
    [self DeleteRequest:[NSString stringWithFormat:@"/projects/%@/gifts/monthly", project_id] parameters:nil success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(MSG_DISCONNECT_INTERNET);
    }];
    
}

@end
