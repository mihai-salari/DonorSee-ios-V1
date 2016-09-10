//
//  FeedViewController.m
//  DonorSee
//
//  Created by star on 3/11/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "FeedViewController.h"
#import "DetailFeedViewController.h"
#import "OtherUserViewController.h"
#import "Branch.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "SignInViewController.h"

@interface FeedViewController () <MFMailComposeViewControllerDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) User *followUserOnSignUp;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) initMember
{
    [super initMember];
    
    arrItemFeeds = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAllCells:)
                                                 name:NOTI_UPDATE_FUNDED_FEED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContentAfterRemove:)
                                                 name:NOTI_UPDATE_FUNDED_FEED_AFTER_REMOVE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedFollowForFeed:)
                                                 name:NOTI_UPDATE_FOLLOW_FEED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedFollowForFeed:)
                                                 name:NOTI_UPDATE_FOLLOW_USER
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateAllCells: (NSNotification*) notification
{
    //return;
    if([notification.object isKindOfClass: [Feed class]])
    {
        Feed* f = notification.object;
        int index = 0;
        for(Feed* item in arrItemFeeds)
        {
            if([item.feed_id isEqual: f.feed_id])
            {
                [arrItemFeeds replaceObjectAtIndex: index withObject: f];
                [self.tbMain reloadData];
                break;
            }
            
            index ++;
        }
    }
}

- (void) finishedFollowForFeed: (NSNotification*) notification
{
    if([notification.object isKindOfClass: [User class]])
    {
        User* user = notification.object;
        for(Feed* item in arrItemFeeds)
        {
            if(item.post_user_id == user.user_id)
            {
                item.postUser = user;
            }
        }
        [self.tbMain reloadData];
    }
}

- (void) updateContentAfterRemove: (NSNotification*) notification
{
    if([notification.object isKindOfClass: [Feed class]])
    {
        Feed* f = notification.object;
        for(Feed* item in arrItemFeeds)
        {
            if([item.feed_id isEqual: f.feed_id])
            {
                [arrItemFeeds removeObject: item];
                [self.tbMain reloadData];
                break;
            }
        }
    }
}

- (void) selectFeed: (Feed*) f
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailFeedViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"DetailFeedViewController"];
    nextView.selectedFeed = f;
    nextView.isVisibleFromNotification = YES;
    [self.navigationController pushViewController: nextView animated: YES];
}

- (void) selectUser: (User*) user
{
    //    if([AppEngine sharedInstance].currentUser && [user.fb_id isEqualToString: [AppEngine sharedInstance].currentUser.fb_id])
    //    {
    //        //Go to Profile Page.
    //        self.tabBarController.selectedIndex = 2;
    //    }
    //    else
    //    {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OtherUserViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"OtherUserViewController"];
    nextView.selectedUser = user;
    [self.navigationController pushViewController: nextView animated: YES];
    //    }
}

- (void) followUser: (User*) user
{
    if ([AppEngine sharedInstance].currentUser == nil) {
        _followUserOnSignUp = user;
        [self showSignupPage];
        return;
    }
    
    [SVProgressHUD showWithStatus: @"Following..." maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] followUser: [AppEngine sharedInstance].currentUser.user_id
                                following_id: user.user_id
                                     success:^(User *followerUser, User *followingUser) {
                                         
                                         [SVProgressHUD dismiss];
                                         //followingUser.followed = YES;
                                         user.followed = YES;
                            
                                         [[NSNotificationCenter defaultCenter] postNotificationName: NOTI_UPDATE_FOLLOW_FEED
                                                                                             object: followingUser];
                                     } failure:^(NSString *errorMessage) {
                                         
                                         [SVProgressHUD dismiss];
                                         [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                         
                                     }];
}

- (void) unfollowUser: (User*) user
{
    if ([AppEngine sharedInstance].currentUser == nil) {
        _followUserOnSignUp = user;
        [self showSignupPage];
        return;
    }
    
    [SVProgressHUD showWithStatus: @"Unfollowing..." maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] unfollowUser: [AppEngine sharedInstance].currentUser.user_id
                                  following_id: user.user_id
                                       success:^(User *followerUser, User *followingUser) {
                                         
                                           [SVProgressHUD dismiss];
                                           user.followed = NO;
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName: NOTI_UPDATE_FOLLOW_FEED
                                                                                               object: followingUser];

                                         
                                     } failure:^(NSString *errorMessage) {
                                         
                                         [SVProgressHUD dismiss];
                                         [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                         
                                     }];
}

- (void) showSignupPage {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignInViewController *signInView = [storyboard instantiateViewControllerWithIdentifier: @"SignInView"];
    signInView.isModelView = YES;
    UINavigationController *signinNav = [[UINavigationController alloc] initWithRootViewController:signInView];
    [signinNav setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didDismissSecondViewController)
     name:@"LOGIN_COMPLETE"
     object:nil];
    
    [self.navigationController presentViewController:signinNav animated:YES completion:^{
        
    }];
}

- (void)didDismissSecondViewController
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LOGIN_COMPLETE" object:nil];
    if([AppEngine sharedInstance].currentUser != nil)
    {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[self showPaymentOption];
            [self followUser:_followUserOnSignUp];
        });
    }
}




#pragma mark -
#pragma mark Handlers accessed from profile view

- (void) getProfileLinkForUserid:(int)userid
{
    //[SVProgressHUD show];

    NSString *user = [NSString stringWithFormat:@"%i",userid];
   // NSData *plainData = [[NSString stringWithFormat:@"%i", userid] dataUsingEncoding:NSUTF8StringEncoding];
  //  NSString *base64String = [plainData base64EncodedStringWithOptions:0];
  //  NSString *url = [NSString stringWithFormat:@"https://donorsee.com/public-profile/%@", base64String];
    NSString *url = [NSString stringWithFormat:@"https://donorsee.com/profile/%@", user];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = url;
    
    /*
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: userid], @"user_id", nil];
    [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
     {
         [SVProgressHUD dismiss];
         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
         pasteboard.string = url;
     }];
    */
}

#pragma mark -
#pragma mark - shareUserInFacebook [ SHARE in FACEBOOK METHOD ]

- (void) shareUserInFacebook:(int)userid
{
    [SVProgressHUD show];
    
    NSString *user = [NSString stringWithFormat:@"%i",userid];
    NSString *fbUrl = [NSString stringWithFormat:@"https://donorsee.com/profile/%@", user];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", userid ], @"user_id", nil];
    [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
     {
         [SVProgressHUD dismiss];
             NSLog(@"urlurlurlurl : %@", url);
         FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
         content.contentDescription = MSG_SHARE_USER;
       //  content.contentURL = [NSURL URLWithString: url];
         content.contentURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@",fbUrl]];
         FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
         dialog.mode = FBSDKShareDialogModeFeedWeb;
         dialog.shareContent = content;
         dialog.delegate = self;
         dialog.fromViewController = self;
         [dialog show];
     }];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"fb share cancelled");
}

#pragma mark -
#pragma mark - shareUserInTwitter [ SHARE in TWITTER METHOD ]


- (void) shareUserInTwitter:(int)userid
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [SVProgressHUD show];
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", userid ], @"user_id", nil];
        [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
         {
             [SVProgressHUD dismiss];
             [tweetSheet setInitialText: MSG_SHARE_USER];
             
             NSString *user = [NSString stringWithFormat:@"%i",userid];
             NSString *tweeterUrl = [NSString stringWithFormat:@"https://donorsee.com/profile/%@", user];
             
             [tweetSheet addURL: [NSURL URLWithString: tweeterUrl]];
             SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                 if (result == SLComposeViewControllerResultCancelled)
                 {
                     NSLog(@"delete");
                 } else
                 {
                     NSLog(@"post twitter");
                 }
             };
             
             tweetSheet.completionHandler = myBlock;
             [self presentViewController:tweetSheet animated:YES completion:nil];
         }];
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"No Twitter Accounts"
                                                                       message: @"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok"
                                                           style: UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
        [alert addAction: okAction];
        [self presentViewController: alert animated: YES completion: nil];
    }
}


#pragma mark -
#pragma mark - shareUserInEmail [ SHARE in EMAIL METHOD ]

- (void) shareUserInEmail:(int)userid
{
    if([MFMailComposeViewController canSendMail])
    {
        [SVProgressHUD show];
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", userid ], @"user_id", nil];
        [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
         {
             [SVProgressHUD dismiss];
             
             NSString *user = [NSString stringWithFormat:@"%i",userid];
             NSString *emailUrl = [NSString stringWithFormat:@"https://donorsee.com/profile/%@", user];
             
             NSString *messageBody = [NSString stringWithFormat: @"%@\n%@", MSG_SHARE_USER, emailUrl];
             MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
             mc.mailComposeDelegate = self;
             [mc setMessageBody: messageBody isHTML:NO];
             [self presentViewController:mc animated:YES completion:NULL];
             
         }];
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Failure" message: @"Your device doesn't support email." preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction: okAction];
        [self presentViewController: alert animated: YES completion: nil];
    }
}

#pragma mark -
#pragma mark - Mail_composier [ MAIL COMPOSER DELEGATE METHOD ]


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
