//
//  OtherUserViewController.m
//  DonorSee
//
//  Created by star on 3/9/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "OtherUserViewController.h"
#import "UploadTableViewCell.h"
#import "SSARefreshControl.h"
#import "DonateViewController.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "FeedTableViewCell.h"
#import "Branch.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "FollowersViewController.h"
#import "NSString+Formats.h"

@interface OtherUserViewController () <UITableViewDataSource, UITableViewDelegate, SSARefreshControlDelegate, MFMailComposeViewControllerDelegate, FBSDKSharingDelegate>
{
    int                         offset;
    BOOL                        isEnded;
}

@property (strong, nonatomic) SSARefreshControl               *refreshControl;
@property (weak, nonatomic) IBOutlet UIView                 *viHeader;
@property (weak, nonatomic) IBOutlet UILabel                *lbUsername;
@property (weak, nonatomic) IBOutlet UIImageView            *ivProfile;
@property (weak, nonatomic) IBOutlet UIView                 *viFooter;
@property (weak, nonatomic) IBOutlet UILabel                *lbFollowers;
@property (weak, nonatomic) IBOutlet UIButton               *btHeart;
@property (weak, nonatomic) IBOutlet UILabel                *lbFollowStatus;
@property (weak, nonatomic) IBOutlet UIView                 *viFollow;
@property (weak, nonatomic) IBOutlet UIButton               *btSettings;
@property (weak, nonatomic) IBOutlet UILabel *receivedAmountLabel;

@end

@implementation OtherUserViewController
@synthesize tbMain;
@synthesize refreshControl;
@synthesize viHeader;
@synthesize lbUsername;
@synthesize ivProfile;
@synthesize viFooter;
@synthesize lbFollowers;
@synthesize btHeart;
@synthesize viFollow;
@synthesize lbFollowStatus;
@synthesize btSettings;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initMember
{
    [super initMember];
    
    lbUsername.text = self.selectedUser.name;
    
    ivProfile.layer.masksToBounds = YES;
    ivProfile.layer.cornerRadius = ivProfile.frame.size.width / 2.0;
    ivProfile.contentMode = UIViewContentModeScaleAspectFill;
    [ivProfile sd_setImageWithURL: [NSURL URLWithString: self.selectedUser.avatar] placeholderImage: [UIImage imageNamed: @"default-profile-pic.png"]];

    [tbMain registerNib: [UINib nibWithNibName: @"FeedTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FeedTableViewCell class])];
    [tbMain.infiniteScrollingView setCustomView: viFooter forState:SVInfiniteScrollingStateStopped];
    
    __weak OtherUserViewController *weakSelf = self;
    [tbMain addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadFeeds: NO];
    }];
    
    self.refreshControl = [[SSARefreshControl alloc] initWithScrollView: tbMain andRefreshViewLayerType:SSARefreshViewLayerTypeOnScrollView];
    self.refreshControl.delegate = self;
    
    if([AppEngine sharedInstance].currentUser == nil || self.selectedUser.user_id == [AppEngine sharedInstance].currentUser.user_id)
    {
        viFollow.hidden = YES;
        btSettings.hidden = YES;
    }
    
    [self getUserFollowStatus];
    
    [self updateFollowUI];
    
    [self updaseUserInfo];
    
    isEnded = NO;
    offset = 0;
    [self loadFeeds: YES];
    
    
}
- (void)updaseUserInfo{
    [[NetworkClient sharedClient] getUserInfo: [AppEngine sharedInstance].currentUser.user_id
                                      success:^(NSDictionary *userInfo) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            // show received amount
                                              NSString *receivedAmount = [userInfo valueForKey:@"amount_received_cents"];
                                              int centsReceived =  [receivedAmount intValue];
                                              self.receivedAmountLabel.text = [NSString stringWithFormat: @"$%@", [NSString StringWithAmountCents:centsReceived]];
                                              
                                          });
                                          
                                      } failure:^(NSString *errorMessage) {
                                          
                                          
                                          
                                      }];
    

}

- (void) refreshFeeds
{
    [self clearAllFeeds];
    [self loadFeeds: YES];
}

- (void) loadFeeds: (BOOL) isFirstLoading
{
    if(offset == 0 && isFirstLoading)
    {
        [SVProgressHUD show];
    }
    [[NetworkClient sharedClient] getUserFeeds: self.selectedUser.user_id
                                         limit: FETCH_LIMIT
                                        offset: offset
                                       success:^(NSArray *arrResult) {
                                           
                                           [SVProgressHUD dismiss];
                                           [self.refreshControl endRefreshing];
                                           
                                           if(arrResult != nil)
                                           {
                                               /*
                                               for(NSDictionary* dicItem in arrResult)
                                               {
                                                   Feed* f = [[Feed alloc] initWithHomeFeed: dicItem];
                                                   [[CoreHelper sharedInstance] addFeed: f];
                                                   
                                                   if(f.post_user_id == self.selectedUser.user_id)
                                                   {
                                                       f.postUser = self.selectedUser;
                                                   }
                                                   
                                                   [arrItemFeeds addObject: f];
                                               }*/
                                               
                                               [arrItemFeeds addObjectsFromArray:arrResult];
                                               
                                               offset += (int)[arrResult count];
                                               if([arrResult count] > 0)
                                               {
                                                   isEnded = NO;
                                               }
                                               else
                                               {
                                                   isEnded = YES;
                                               }
                                           }
                                           else
                                           {
                                               isEnded = YES;
                                           }
                                           
                                           [tbMain.infiniteScrollingView stopAnimating];
                                           tbMain.showsInfiniteScrolling = !isEnded;
                                           [tbMain reloadData];
                                           
                                       } failure:^(NSString *errorMessage) {
                                           [SVProgressHUD dismiss];
                                           [tbMain.infiniteScrollingView stopAnimating];
                                       }];
}

- (void) clearAllFeeds
{
    offset = 0;
    isEnded = NO;
    
    [arrItemFeeds removeAllObjects];
    [tbMain reloadData];
}

- (void) getUserFollowStatus {
    
    if (_selectedUser.user_id == [AppEngine sharedInstance].currentUser.user_id) {
      
        [[NetworkClient sharedClient] getUserFollowingStatus:_selectedUser.user_id user_id:_selectedUser.user_id success:^(NSArray *followStatus) {
            lbFollowers.text = [NSString stringWithFormat: @"%lu", (unsigned long)followStatus.count];
        } failure:^(NSString *errorMessage) {
            
        }];
        
        return;
    }
    
    [[NetworkClient sharedClient] getUserFollowStatus:_selectedUser.user_id user_id:[AppEngine sharedInstance].currentUser.user_id success:^(NSArray *followStatus) {
        
        if (followStatus.count > 0) {
            NSPredicate *isCurrentUserFollowingPredicate = [NSPredicate predicateWithFormat:@"id == %d", [AppEngine sharedInstance].currentUser.user_id];
            NSArray *filteredList = [followStatus filteredArrayUsingPredicate:isCurrentUserFollowingPredicate];
            if (filteredList.count > 0) {
                _selectedUser.followed = YES;
            } else {
                _selectedUser.followed = NO;
            }
            [self updateFollowUI];
            [self updaseUserInfo];
            [tbMain reloadData];
        }
        lbFollowers.text = [NSString stringWithFormat: @"%lu", (unsigned long)followStatus.count];
    } failure:^(NSString *errorMessage) {
        
    }];
}

#pragma mark - UITableView.
//
//- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return viHeader;
//}
//
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
//    return 15.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrItemFeeds.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedTableViewCell *cell = (FeedTableViewCell*)[tableView dequeueReusableCellWithIdentifier: NSStringFromClass([FeedTableViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    Feed* f = [arrItemFeeds objectAtIndex: indexPath.row];
    [cell setDonateFeed: f isDetail: NO];
    [cell updateFollowStatus:_selectedUser.followed];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FeedTableViewCell getHeight];
}

#pragma mark - Feed Delegate.

- (void) donateFeed:(Feed *)f
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DonateViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"DonateViewController"];
    nextView.selectedFeed = f;
    [self.navigationController pushViewController: nextView animated: YES];
}

#pragma mark Refresh Delegate.

- (void)beganRefreshing
{
    [self loadDataSource];
}

- (void)loadDataSource {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self clearAllFeeds];
            [self loadFeeds: NO];
        });
        
    });
}

- (void) selectUser: (User*) user
{
    
}

#pragma mark - Follow.
- (IBAction) actionFollow:(id)sender
{
    if(self.selectedUser.followed)
    {
        [self unfollowUser: self.selectedUser];
    }
    else
    {
        [self followUser: self.selectedUser];
    }
    
}

- (void) finishedFollowForFeed: (NSNotification*) notification
{
    [super finishedFollowForFeed: notification];
    [self getUserFollowStatus];
}

- (void) updateFollowUI
{
    //Follow
    if(self.selectedUser.followed)
    {
        lbFollowStatus.text = @"FOLLOWING";
        [btHeart setImage: [UIImage imageNamed: @"heart_sel.png"] forState: UIControlStateNormal];
    }
    else
    {
        lbFollowStatus.text = @"FOLLOW";
        [btHeart setImage: [UIImage imageNamed: @"heart.png"] forState: UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark
- (IBAction)onShowFollowers:(id)sender {
    
    if (![lbFollowers.text isEqualToString:@"0"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FollowersViewController *followersController = [storyboard instantiateViewControllerWithIdentifier:@"FollowersView"];
        followersController.selectedUser = self.selectedUser;
        [self.navigationController pushViewController:followersController animated:YES];
    }
}


#pragma mark - Report.

- (IBAction) actionReport:(id)sender
{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle: nil
                                                                        message: @"Report"
                                                                 preferredStyle: UIAlertControllerStyleActionSheet];
    
    //Block User
    if([AppEngine sharedInstance].currentUser != nil && self.selectedUser.user_id != [AppEngine sharedInstance].currentUser.user_id)
    {
        UIAlertAction* blockAction = [UIAlertAction actionWithTitle: @"Block User"
                                                              style: UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                
                                                                [self blockUser];
                                                            }];
        [controller addAction: blockAction];
    }

    //Get Profile Link
    UIAlertAction* getProfileAction = [UIAlertAction actionWithTitle: @"Copy Profile Link To Dashboard"
                                                          style: UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                            [self getProfileLink];
                                                        }];
    [controller addAction: getProfileAction];

    //Share Profile
    UIAlertAction* shareProfileAction = [UIAlertAction actionWithTitle: @"Share Profile"
                                                          style: UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                            [self shareProfile];
                                                        }];
    [controller addAction: shareProfileAction];
    
    //Cancel
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: @"Cancel"
                                                           style: UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    [controller addAction: cancelAction];
    [self presentViewController: controller animated: YES completion: nil];
}

- (void) blockUser
{
    [SVProgressHUD showWithStatus: @"Reporting..." maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] reportUser: _selectedUser
                                     success:^{
                                        
                                         [SVProgressHUD dismiss];
                                         [self presentViewController: [AppEngine showAlertWithText: MSG_REPORT_USER]
                                                            animated: YES
                                                          completion: nil];
                                         
                                     } failure:^(NSString *errorMessage) {
                                         
                                         [SVProgressHUD dismiss];
                                         [self presentViewController: [AppEngine showErrorWithText: MSG_DISCONNECT_INTERNET]
                                                            animated: YES
                                                          completion: nil];

                                         
                                     }];
}

- (void) getProfileLink
{
    [SVProgressHUD show];
//    
//    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", _selectedUser.user_id ], @"user_id", nil];
//    [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
//     {
//         [SVProgressHUD dismiss];
//         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//         pasteboard.string = url;
//     }];
    
    NSString *user = [NSString stringWithFormat:@"%i",_selectedUser.user_id];
    // NSData *plainData = [[NSString stringWithFormat:@"%i", userid] dataUsingEncoding:NSUTF8StringEncoding];
    //  NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    //  NSString *url = [NSString stringWithFormat:@"https://donorsee.com/public-profile/%@", base64String];
    NSString *url = [NSString stringWithFormat:@"https://donorsee.com/profile/%@", user];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = url;

}

- (void) shareProfile
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Share" message: @"" preferredStyle: UIAlertControllerStyleActionSheet];
    
    //Facebook.
    UIAlertAction* fbAction = [UIAlertAction actionWithTitle: @"Facebook" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareUserInFacebook];
        
    }];
    [alert addAction: fbAction];
    
    //Twitter.
    UIAlertAction* twitterAction = [UIAlertAction actionWithTitle: @"Twitter" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        [self shareUserInTwitter];
                                    }];
    [alert addAction: twitterAction];
    
    
    //Email.
    UIAlertAction *emailAction = [UIAlertAction actionWithTitle: @"Email" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareUserInEmail];
        
    }];
    [alert addAction: emailAction];
    
    //Cancel.
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction: cancelAction];
    [self presentViewController: alert animated: YES completion: nil];
}

- (void) shareUserInFacebook
{
    //Amit--
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentDescription = MSG_SHARE_USER;
    content.contentURL = [NSURL URLWithString: [NSString stringWithFormat:@"https://donorsee.com/profile/%d", _selectedUser.user_id ]];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.mode = FBSDKShareDialogModeFeedWeb;
    dialog.shareContent = content;
    dialog.delegate = self;
    dialog.fromViewController = self;
    [dialog show];
    
    /*
     [SVProgressHUD show];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", _selectedUser.user_id ], @"user_id", nil];
    [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
         content.contentDescription = MSG_SHARE_USER;
         content.contentURL = [NSURL URLWithString: url];
         
         FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
         dialog.mode = FBSDKShareDialogModeFeedWeb;
         dialog.shareContent = content;
         dialog.delegate = self;
         dialog.fromViewController = self;
         [dialog show];
     }];*/
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

- (void) shareUserInTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        ;
        
        [tweetSheet setInitialText: MSG_SHARE_USER];
        [tweetSheet addURL: [NSURL URLWithString: [NSString stringWithFormat:@"https://donorsee.com/profile/%d", _selectedUser.user_id ]]];
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
        /*
         [SVProgressHUD show];
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", _selectedUser.user_id ], @"user_id", nil];
        [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
         {
             [SVProgressHUD dismiss];
             [tweetSheet setInitialText: MSG_SHARE_USER];
             [tweetSheet addURL: [NSURL URLWithString: url]];
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
         }];*/
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

- (void) shareUserInEmail
{
    if([MFMailComposeViewController canSendMail])
    {
        //Amit
        
        NSString *messageBody = [NSString stringWithFormat: @"%@\n%@", MSG_SHARE_USER, [NSString stringWithFormat:@"https://donorsee.com/profile/%d", _selectedUser.user_id ]];
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setMessageBody: messageBody isHTML:NO];
        [self presentViewController:mc animated:YES completion:NULL];
        /*
         //[SVProgressHUD show];
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", _selectedUser.user_id ], @"user_id", nil];
        [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
         {
             [SVProgressHUD dismiss];
             
             NSString *messageBody = [NSString stringWithFormat: @"%@\n%@", MSG_SHARE_USER, url];
             MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
             mc.mailComposeDelegate = self;
             [mc setMessageBody: messageBody isHTML:NO];
             [self presentViewController:mc animated:YES completion:NULL];
             
         }];*/
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
