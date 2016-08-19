//
//  AppDelegate.m
//  DonorSee
//
//  Created by star on 2/28/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "PayPalMobile.h"
#import "Branch.h"
#import "DetailFeedViewController.h"
#import "OtherUserViewController.h"

#import <Stripe/Stripe.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : PAYPAL_LIVE_ID,
                                                           PayPalEnvironmentSandbox : PAYPAL_SANDBOX_ID}];
    
    
    
    //Branch.
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        // params are the deep linked params associated with the link that the user clicked before showing up.
        NSLog(@"deep link data: %@", [params description]);
        
        if(params != nil && [params valueForKey: @"feed_id"] != nil)
        {
            [self gotoDetailPage: params];
        }
        else if(params != nil && [params valueForKey: @"user_id"] != nil)
        {
            [self gotoOtherProfile: params];
        }

    }];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    [application registerForRemoteNotifications];
    
    
    // STRIPE INTEGRATION
    [Stripe setDefaultPublishableKey:STRIPE_PUBLISHABLE_KEY];
    
    // USER DEFAULTS
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"-1", @"stripe_userid",@"-1",@"devicetoken",@"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNjh9.1ynooVdTHcw6HaN4ZUtPR1ukhjzRiMDBBCXWyp5AKpU", @"api_token",
                                 nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    return YES;
}

+(AppDelegate*) getDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.absoluteString containsString:@"donorseestripe"]) {
        
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSArray *queryItems = [components queryItems];
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        
        for (NSURLQueryItem *item in queryItems)
        {
            [dict setObject:[item value] forKey:[item name]];
            if ([item.name isEqualToString:@"stripe_userid"]) {
                
                [[NSUserDefaults standardUserDefaults] setValue:item.value forKey:@"stripe_userid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"STRIPE_ACCOUNT_SIGNUP" object:self];
                
            }
        }
    }
    
    
    [[Branch getInstance] handleDeepLink:url];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler
{
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    return handledByBranch;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
//    NSDictionary *userData = [[PushNotificationManager pushManager] getCustomPushDataAsNSDict:userInfo];
//    NSLog(@"pushwoosh userData = %@", userData);
//    if(userData != nil)
//    {
//        [self gotoDetailPage: userData];
//    }
    [[Branch getInstance] handlePushNotification:userInfo];
}

- (void) gotoDetailPage: (NSDictionary*) params
{
    if(params != nil && [params valueForKey: @"feed_id"] != nil)
    {
        //Get Feed Data.
        [SVProgressHUD show];
        NSString* feed_id = [NSString stringWithFormat: @"%d", [[params valueForKey: @"feed_id"] intValue]];
        [[NetworkClient sharedClient] getSingleFeed: feed_id
                                            success:^(NSDictionary *dicFeed) {
                                                
                                                [SVProgressHUD dismiss];
                                                
                                                if(dicFeed != nil)
                                                {
                                                    Feed* f = [[Feed alloc] initWithHomeFeed: dicFeed];
                                                    
                                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                    DetailFeedViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"DetailFeedViewController"];
                                                    nextView.selectedFeed = f;
                                                    
                                                    if(self.navigator != nil)
                                                    {
                                                        [self.navigator pushViewController: nextView animated: YES];
                                                    }
                                                }
                                                
                                            } failure:^(NSString *errorMessage) {
                                                
                                                [SVProgressHUD dismiss];
                                                
                                            }];
    }
}

- (void) gotoOtherProfile: (NSDictionary*) params
{
    if(params != nil && [params valueForKey: @"user_id"] != nil)
    {
        //Get Feed Data.
        [SVProgressHUD show];
        int user_id = [[params valueForKey: @"user_id"] intValue];
        [[NetworkClient sharedClient] getUserInfo: user_id
                                          success:^(NSDictionary *dicUser) {
                                            
                                              [SVProgressHUD dismiss];
                                              if(dicUser != nil)
                                              {
                                                  FEMMapping *userMapping = [DSMappingProvider userMapping];
                                                  User *u = [FEMDeserializer objectFromRepresentation:dicUser mapping:userMapping];
                                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                  OtherUserViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"OtherUserViewController"];
                                                  nextView.selectedUser = u;
                                                  
                                                  if(self.navigator != nil)
                                                  {
                                                      [self.navigator pushViewController: nextView animated: YES];
                                                  }
                                              }
                                          } failure:^(NSString *errorMessage) {

                                              [SVProgressHUD dismiss];
                                              
                                          }];
         
    }
}

// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //[[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"%@",hexToken);
    
    //NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    //deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [AppEngine sharedInstance].currentDeviceToken = hexToken;
    NSLog(@"device token = %@", [AppEngine sharedInstance].currentDeviceToken);
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //[[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}




@end
