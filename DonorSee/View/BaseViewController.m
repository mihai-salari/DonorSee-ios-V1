//
//  BaseViewController.m
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "BaseViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation BaseViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self initMember];
}

- (void) initMember
{
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) checkAppVersion {
    if([AppEngine sharedInstance].currentUser != nil)
    {
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [[NetworkClient sharedClient] checkAppVersion:[AppEngine sharedInstance].currentUser.user_id version:appVersionString success:^(NSDictionary *dicUser) {
            NSLog(@"dicUser %@", dicUser);
            
            if ([dicUser objectForKey:@"success"]) {
                int successFlag = [[dicUser objectForKey:@"success"] intValue];
                if (successFlag == 0) {
                    if ([dicUser objectForKey:@"user"]) {
                        NSDictionary *user = [dicUser objectForKey:@"user"];
                        if ([user objectForKey:@"app_version"]) {
                            NSString *newVersionNumber = [user objectForKey:@"minimum_app_version"];
                            
                            NSString *alertTitle = @"Donorsee update available";
                            NSString *alertMessage = [NSString stringWithFormat:@"You have %@ version installed. Please update to %@ version from app store", appVersionString, newVersionNumber];
                            
                            UIAlertController *alertController = [UIAlertController
                                                                  alertControllerWithTitle:alertTitle
                                                                  message:alertMessage
                                                                  preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *cancelAction = [UIAlertAction
                                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                           style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction *action)
                                                           {
                                                               NSLog(@"Cancel action");
                                                           }];
                            
                            UIAlertAction *okAction = [UIAlertAction
                                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           NSString *iTunesLink = @"itms://itunes.apple.com/in/app/donorsee/id1093861994?mt=8";
                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                                       }];
                            
                            [alertController addAction:cancelAction];
                            [alertController addAction:okAction];
                            
                            [self presentViewController:alertController animated:YES completion:nil];
                        }
                        
                    }
                    
                    
                }
            }
            
        } failure:^(NSString *errorMessage) {
            
        }];
    }
}

- (void) gotoHomeView: (BOOL) animate
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id nextView = [storyboard instantiateViewControllerWithIdentifier: @"tabBarController"];
    [self.navigationController pushViewController: nextView animated: animate];
    
    [self checkAppVersion];
}

- (IBAction) actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void) signInFB: (void (^)(void)) completed
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [login logInWithReadPermissions: @[@"public_profile", @"email"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     {
         if (error)
         {
             [self presentViewController: [AppEngine showErrorWithText: error.description] animated: YES completion: nil];
         }
         else if (result.isCancelled)
         {
             NSLog(@"Cancelled");
         }
         else
         {
             NSLog(@"Logged in");
             if ([FBSDKAccessToken currentAccessToken])
             {
                 [SVProgressHUD showWithStatus: @"Sign in with Facebook..."];
                 
                 NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                 [parameters setValue:@"id, name, email, first_name, last_name" forKey:@"fields"];
                 
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters: parameters]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                  {
                      if (!error)
                      {
                          NSLog(@"fetched user:%@", result);
                          NSString* fbId = [result valueForKey: @"id"];
                          NSString* first_name = [result valueForKey: @"first_name"];
                          NSString* last_name = [result valueForKey: @"last_name"];
                          NSString* email = [result valueForKey: @"email"];
                          
                          
                          [[NetworkClient sharedClient] loginWithFB:fbId firstName:first_name lastName:last_name email:email success:^(NSDictionary *dicUser) {
                              [SVProgressHUD dismiss];
                              
                              FEMMapping *mapping = [DSMappingProvider userMapping];
                              User *u = [FEMDeserializer objectFromRepresentation:dicUser mapping:mapping];
                              u.fb_id = fbId;
                              
                              [[CoreHelper sharedInstance] addUser: u];
                              [[CoreHelper sharedInstance] setCurrentUserId: u.user_id];
                              [AppEngine sharedInstance].currentUser = u;
                              
                              completed();
                          } failure:^(NSString *errorMessage) {
                              [SVProgressHUD dismiss];
                              [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                          }];
                         
                      }
                      else
                      {
                          [SVProgressHUD dismiss];
                          [self presentViewController: [AppEngine showErrorWithText: error.description]
                                             animated: YES
                                           completion: nil];
                      }
                  }];
             }
         }
     }];
}

#pragma mark -
#pragma mark Check for Model
- (BOOL)isModal {
    if([self presentingViewController])
        return YES;
    if([[self presentingViewController] presentedViewController] == self)
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}

@end
