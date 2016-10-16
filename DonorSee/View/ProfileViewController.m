//
//  ProfileViewController.m
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "ProfileViewController.h"
#import "UploadTableViewCell.h"
#import "FundedTableViewCell.h"
#import "SettingsTableViewCell.h"

#import "UploadViewController.h"

#import "SSARefreshControl.h"
#import <MessageUI/MessageUI.h>
//#import "JAmazonS3ClientManager.h"
#import "AuthView.h"
#import "DetailFeedViewController.h"
#import "FEMMapping.h"
#import "DSMappingProvider.h"
#import "FEMDeserializer.h"
#import "Event.h"
#import "SignInViewController.h"
#import "FollowersViewController.h"
#import "NSString+Formats.h"
#import "VideoPlayer.h"

@interface ProfileViewController() <UITableViewDataSource, UITableViewDelegate, SSARefreshControlDelegate, UploadTableViewCellDelegate, SettingsTableViewCellDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, AuthViewDelegate>
{
    int                 currentPage;
    BOOL                isLoadedFunds;
    BOOL                isLoadedUpload;
    
    NSMutableArray      *arrFunds;
    NSMutableArray      *arrUploads;
    NSArray             *arrSettings;
}

@property (nonatomic, strong) AuthView              *viSignInFB;

@property (nonatomic, strong) IBOutlet UIImageView  *ivUserAvatar;
@property (nonatomic, strong) IBOutlet UILabel      *lbUsername;
@property (nonatomic, weak) IBOutlet UILabel        *lbDonatedAmount;

@property (nonatomic, strong) IBOutlet UIView       *viCategory;
@property (nonatomic, strong) IBOutlet UIButton     *btFunded;
@property (nonatomic, strong) IBOutlet UIButton     *btUploads;
@property (nonatomic, strong) IBOutlet UIButton     *btSettings;
@property (nonatomic, strong) IBOutlet UIView       *viActiveLine;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *constraintLeftForActiveLine;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *constraintRightForActiveLine;

@property (nonatomic, strong) IBOutlet UIView       *viContent;
@property (nonatomic, strong) IBOutlet UIView       *viFundedContent;
@property (nonatomic, strong) IBOutlet UITableView  *tbFunded;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingFunded;
@property (nonatomic, strong) IBOutlet UILabel      *lbNoFunded;
@property (strong, nonatomic) SSARefreshControl     *refreshFunded;
@property (nonatomic, strong) IBOutlet UIView       *viFundedFooter;

@property (nonatomic, strong) IBOutlet UIView       *viUploadContent;
@property (nonatomic, strong) IBOutlet UITableView  *tbUpload;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingUpload;
@property (nonatomic, strong) IBOutlet UILabel      *lbNoUploaded;
@property (strong, nonatomic) SSARefreshControl     *refreshUpload;

@property (nonatomic, strong) IBOutlet UIView       *viSettingsContent;
@property (nonatomic, strong) IBOutlet UITableView  *tbSettings;
@property (nonatomic, strong) IBOutlet UIButton     *btLogout;

@property (nonatomic, weak) IBOutlet UIView         *viWithdraw;
@property (nonatomic, weak) IBOutlet UIView         *viWithdrawDialog;
@property (nonatomic, weak) IBOutlet UILabel        *lbAvailableAmount;
@property (nonatomic, weak) IBOutlet UIView         *viWithdrawEmail;
@property (nonatomic, weak) IBOutlet UITextField    *tfWithdrawEmail;
@property (nonatomic, weak) IBOutlet UIView         *viWithdrawAmount;
@property (nonatomic, weak) IBOutlet UITextField    *tfWithdrawAmount;
@property (nonatomic, weak) IBOutlet UIButton       *btWithdraw;
@property (weak, nonatomic) IBOutlet UIToolbar      *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *btDone;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;

@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *receivedMoneyLabel;


@end

@implementation ProfileViewController
@synthesize viSignInFB;

@synthesize ivUserAvatar;
@synthesize lbUsername;
@synthesize lbDonatedAmount;

@synthesize viCategory;
@synthesize btFunded;
@synthesize tbFunded;
@synthesize loadingFunded;
@synthesize lbNoFunded;
@synthesize refreshFunded;
@synthesize viFundedFooter;
@synthesize viActiveLine;
@synthesize constraintLeftForActiveLine;
@synthesize constraintRightForActiveLine;

@synthesize btUploads;
@synthesize tbUpload;
@synthesize loadingUpload;
@synthesize lbNoUploaded;
@synthesize refreshUpload;

@synthesize btSettings;

@synthesize viContent;
@synthesize viFundedContent;
@synthesize viUploadContent;

@synthesize viSettingsContent;
@synthesize tbSettings;
@synthesize btLogout;

@synthesize viWithdraw;
@synthesize lbAvailableAmount;
@synthesize viWithdrawDialog;
@synthesize viWithdrawEmail;
@synthesize tfWithdrawEmail;
@synthesize viWithdrawAmount;
@synthesize tfWithdrawAmount;
@synthesize btWithdraw;
@synthesize toolBar;
@synthesize btDone;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) initMember
{
    [super initMember];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadAllFeeds)
                                                 name:NOTI_UPDATE_FUNDED_FEED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadAllFeeds)
                                                 name:NOTI_UPDATE_FUNDED_FEED_AFTER_REMOVE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadAllFeeds)
                                                 name:NOTI_UPDATE_FOLLOW_FEED
                                               object:nil];
    
    arrFunds = [[NSMutableArray alloc] init];
    arrUploads = [[NSMutableArray alloc] init];
    
    ivUserAvatar.layer.masksToBounds = YES;
    ivUserAvatar.layer.cornerRadius = ivUserAvatar.frame.size.width / 2.0;
    ivUserAvatar.contentMode = UIViewContentModeScaleAspectFill;
    
    btFunded.selected = YES;
    isLoadedFunds = NO;
    isLoadedUpload = NO;
    
    _settingsBtn.hidden = YES;

    [tbFunded registerNib: [UINib nibWithNibName: @"FundedTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FundedTableViewCell class])];
    tbFunded.tableFooterView = viFundedFooter;
    
    [tbUpload registerNib: [UINib nibWithNibName: @"UploadTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([UploadTableViewCell class])];

    arrSettings = @[@{@"icon": @"withdraw_icon.png", @"title": @"Transaction History"},
                    @{@"icon": @"edit_profile.png", @"title": @"Edit Profile"},
                    @{@"icon": @"rate_us.png", @"title": @"Rate Us"},
                    @{@"icon": @"email_feedback.png", @"title": @"Email us Feedback"},
//                    @{@"icon": @"help.png", @"title": @"Help"},
                    @{@"icon": @"", @"title": @"Show amount given"},
                    ];
    
    [tbSettings registerNib: [UINib nibWithNibName: @"SettingsTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([SettingsTableViewCell class])];
    tbSettings.tableFooterView = btLogout;
    
    refreshFunded = [[SSARefreshControl alloc] initWithScrollView: tbFunded andRefreshViewLayerType:SSARefreshViewLayerTypeOnScrollView];
    refreshFunded.delegate = self;

    refreshUpload = [[SSARefreshControl alloc] initWithScrollView: tbUpload andRefreshViewLayerType:SSARefreshViewLayerTypeOnScrollView];
    refreshUpload.delegate = self;
    
    [self initAuthUI];
    [self initWithdrawUI];
    
    currentPage = TAB_FUNDED;
    [self updatePages];
    [self loadFundedFeeds];
    
    //NSLog(@"%f",[AppEngine sharedInstance].currentUser.pay_amount);
    
}

- (void) loadAllFeeds
{
    [self loadMyFeeds];
    [self loadFundedFeeds];
}

- (void) loadFundedFeeds
{
    if([arrFunds count] == 0)
    {
        loadingFunded.hidden = NO;
        [loadingFunded startAnimating];
    }
    
    isLoadedFunds = YES;
    [[NetworkClient sharedClient] getFundedFeeds: [AppEngine sharedInstance].currentUser.user_id
                                     success:^(NSArray *arrFeed) {
                                         
                                         [loadingFunded stopAnimating];
                                         loadingFunded.hidden = YES;
                                         [refreshFunded endRefreshing];
                                         
                                         [arrFunds removeAllObjects];
                                         if(arrFeed != nil && [arrFeed count] > 0)
                                         {
                                             /*
                                             for(NSDictionary* dicItem in arrFeed)
                                             {
                                                 Feed* f = [[Feed alloc] initWithProfileFeed: dicItem];
                                                 [[CoreHelper sharedInstance] addFeed: f];
                                                 [arrFunds addObject: f];
                                             }*/
                                             [arrFunds addObjectsFromArray:arrFeed];
                                             lbNoFunded.hidden = YES;
                                         }
                                         else
                                         {
                                             lbNoFunded.hidden = NO;
                                         }
                                         
                                         [tbFunded reloadData];
                                         
                                     } failure:^(NSString *errorMessage) {
                                         
                                         [loadingFunded stopAnimating];
                                         loadingFunded.hidden = YES;
                                         [refreshFunded endRefreshing];
                                         
                                     }];
}

- (void) loadMyFeeds
{
    if([arrUploads count] == 0)
    {
        loadingUpload.hidden = NO;
        [loadingUpload startAnimating];
    }
    
    isLoadedUpload = YES;
    [[NetworkClient sharedClient] getMyFeeds: [AppEngine sharedInstance].currentUser.user_id
                                     success:^(NSArray *arrFeed) {
                                         
                                         [loadingUpload stopAnimating];
                                         loadingUpload.hidden = YES;
                                         [refreshUpload endRefreshing];
                                         
                                         [arrUploads removeAllObjects];
                                         
                                         if(arrFeed != nil && [arrFeed count] > 0)
                                         {
                                             /*
                                             for(NSDictionary* dicItem in arrFeed)
                                             {
                                                 Feed* f = [[Feed alloc] initWithProfileFeed: dicItem];
                                                 if(![self isExistFeedAlready: f array: arrUploads])
                                                 {
                                                     [[CoreHelper sharedInstance] addFeed: f];
                                                     [arrUploads addObject: f];
                                                 }
                                             }*/
                                             [arrUploads addObjectsFromArray:arrFeed];
                                             lbNoUploaded.hidden = YES;
                                         }
                                         else
                                         {
                                             lbNoUploaded.hidden = NO;
                                         }
                                         
                                         [tbUpload reloadData];
                                         
                                     } failure:^(NSString *errorMessage) {
                                        
                                         [loadingUpload stopAnimating];
                                         loadingUpload.hidden = YES;
                                         [refreshUpload endRefreshing];
                                         
                                     }];
}

- (BOOL) isExistFeedAlready: (Feed*) f array: (NSArray*) array
{
    for(Feed* item in array)
    {
        if([item.feed_id isEqualToString: f.feed_id])
        {
            [item mergeFeed: f];
            return YES;
        }
    }
    
    return NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self checkAuthView];
}

- (void) checkAuthView
{
    if([AppEngine sharedInstance].currentUser)
    {
        viSignInFB.hidden = YES;
        [self updateProfileInfo];
        _settingsBtn.hidden = NO;
    }
    else
    {
        viSignInFB.hidden = NO;
    }
}

- (void) updateProfileInfo
{
    [AppEngine sharedInstance].isShowDonatedAmount = [[CoreHelper sharedInstance] getIsShowDonatedAmount];
    
    lbUsername.text = [AppEngine sharedInstance].currentUser.name;
    [ivUserAvatar sd_setImageWithURL: [NSURL URLWithString: [AppEngine sharedInstance].currentUser.avatar] placeholderImage: [UIImage imageNamed: DEFAULT_USER_IMAGE]];
    lbDonatedAmount.hidden = ![AppEngine sharedInstance].isShowDonatedAmount;
    
    [[NetworkClient sharedClient] getUserInfo: [AppEngine sharedInstance].currentUser.user_id
                                      success:^(NSDictionary *userInfo) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSNumber * amountGivenCents = [userInfo valueForKey:@"amount_given_cents"];
                                              
                                              int cents = 0;
                                              if ([amountGivenCents isKindOfClass: [NSNumber class]]){
                                                  cents = [amountGivenCents intValue];
                                              }
                                              
                                          
                                              lbDonatedAmount.text = [NSString stringWithFormat: @"$%@ Given", [NSString StringWithAmountCents:cents]];
                                          
                                              
                                              // show received amount
                                              NSNumber *receivedAmount = [userInfo valueForKey:@"amount_received_cents"];
                                              
                                              int centsReceived = 0;
                                              if ([receivedAmount isKindOfClass: [NSNumber class]]){
                                                  centsReceived = [receivedAmount intValue];
                                              }
                                              
                                              self.receivedMoneyLabel.text = [NSString stringWithFormat: @"$%@", [NSString StringWithAmountCents:centsReceived]];
                                              
                                              // show follower count
                                              NSString *followersString = [userInfo valueForKey:@"followers_count"];
                                              self.followersCountLabel.text = [NSString stringWithFormat:@"%d", [followersString intValue]];
                                              });
                                          
                                      } failure:^(NSString *errorMessage) {
                                          
                                          [loadingUpload stopAnimating];
                                          loadingUpload.hidden = YES;
                                          [refreshUpload endRefreshing];
                                          
                                      }];
    
    [self loadFundedFeeds];
    [self loadMyFeeds];
    
    [tbSettings reloadData];
}

- (IBAction) actionCategory:(UIButton*)sender
{
    if(sender == btFunded)
    {
        currentPage = TAB_FUNDED;
        if(!isLoadedFunds)
        {
            isLoadedFunds = YES;
            [self loadFundedFeeds];
        }
    }
    else if(sender == btUploads)
    {
        currentPage = TAB_UPLOAD;
        if(!isLoadedUpload)
        {
            isLoadedUpload = YES;
            [self loadMyFeeds];
        }
    }
    else
    {
        currentPage = TAB_SETTINGS;
    }
    
    [self updatePages];
}

- (IBAction) actionSeeMoreProjects:(id)sender
{
    self.tabBarController.selectedIndex = 0;
}

#pragma mark - Auth.

- (void) initAuthUI
{
    CGRect rect = CGRectMake(0, TOP_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOP_BAR_HEIGHT - TAB_BAR_HEIGHT);
//    viSignInFB = [[AuthView alloc] initAuthView: rect isAskingPaypal: NO parentView: self delegate: self];
    viSignInFB = [[AuthView alloc] initAuthView: rect parentView: self delegate: self];
    viSignInFB.hidden = YES;
    [self.view addSubview: viSignInFB];
    
    //[self showSignupPage];
}

- (void) successAuth
{
    [self checkAuthView];
}

- (void) failAuth
{
    [self showSignupPage];
}

- (void) showSignupPage {
    
    if([AppEngine sharedInstance].currentUser) return;
    
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
    // this method gets called in MainVC when your SecondVC is dismissed
    NSLog(@"Dismissed SecondViewController");
    [self checkAuthView];
}

- (void) updatePages
{
    viFundedContent.hidden = YES;
    viUploadContent.hidden = YES;
    viSettingsContent.hidden = YES;
    
    if(currentPage == TAB_FUNDED)
    {
        viFundedContent.hidden = NO;
        btFunded.selected = YES;
        btFunded.titleLabel.font = [UIFont fontWithName: FONT_MEDIUM size: 14.0];
        btUploads.selected = NO;
        btUploads.titleLabel.font = [UIFont fontWithName: FONT_LIGHT size: 14.0f];
        btSettings.selected = NO;
        btSettings.titleLabel.font = [UIFont fontWithName: FONT_LIGHT size: 14.0f];
        
        constraintLeftForActiveLine.constant = 0;
        constraintRightForActiveLine.constant = self.view.frame.size.width - btFunded.frame.size.width;
    }
    else if(currentPage == TAB_UPLOAD)
    {
        viUploadContent.hidden = NO;
        btFunded.selected = NO;
        btFunded.titleLabel.font = [UIFont fontWithName: FONT_LIGHT size: 14.0];
        btUploads.selected = YES;
        btUploads.titleLabel.font = [UIFont fontWithName: FONT_MEDIUM size: 14.0f];
        btSettings.selected = NO;
        btSettings.titleLabel.font = [UIFont fontWithName: FONT_LIGHT size: 14.0];
        
        constraintLeftForActiveLine.constant = btUploads.frame.origin.x;
        constraintRightForActiveLine.constant = self.view.frame.size.width - btFunded.frame.size.width - btUploads.frame.size.width;
    }
    else
    {
        viSettingsContent.hidden = NO;
        btFunded.selected = NO;
        btFunded.titleLabel.font = [UIFont fontWithName: FONT_LIGHT size: 14.0];
        btUploads.selected = NO;
        btUploads.titleLabel.font = [UIFont fontWithName: FONT_LIGHT size: 14.0];
        btSettings.selected = YES;
        btSettings.titleLabel.font = [UIFont fontWithName: FONT_MEDIUM size: 14.0];
        constraintLeftForActiveLine.constant = btSettings.frame.origin.x;
        constraintRightForActiveLine.constant = 0;
    }
    
    [self.view layoutIfNeeded];
}

- (void) followFeed:(Feed *)f
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailFeedViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"DetailFeedViewController"];
    nextView.selectedFeed = f;
    [self.navigationController pushViewController: nextView animated: YES];
}

#pragma mark -
#pragma mark Profile Settings menu action

- (IBAction)onShowSettingsMenu:(id)sender {
    UIAlertController* controller = [UIAlertController alertControllerWithTitle: nil
                                                                        message: @"Report"
                                                                 preferredStyle: UIAlertControllerStyleActionSheet];
    
    //Get Profile Link
    UIAlertAction* getProfileAction = [UIAlertAction actionWithTitle: @"Copy Profile Link To Dashboard"
                                                               style: UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                                 //[self getProfileLink];
                                                                 [self getProfileLinkForUserid:[AppEngine sharedInstance].currentUser.user_id];
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

- (void) shareProfile
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Share" message: @"" preferredStyle: UIAlertControllerStyleActionSheet];
    
    //Facebook.
    UIAlertAction* fbAction = [UIAlertAction actionWithTitle: @"Facebook" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareUserInFacebook:[AppEngine sharedInstance].currentUser.user_id];
        
    }];
    [alert addAction: fbAction];
    
    //Twitter.
    UIAlertAction* twitterAction = [UIAlertAction actionWithTitle: @"Twitter" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        [self shareUserInTwitter:[AppEngine sharedInstance].currentUser.user_id];
                                    }];
    [alert addAction: twitterAction];
    
    
    //Email.
    UIAlertAction *emailAction = [UIAlertAction actionWithTitle: @"Email" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareUserInEmail:[AppEngine sharedInstance].currentUser.user_id];
        
    }];
    [alert addAction: emailAction];
    
    //Cancel.
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction: cancelAction];
    [self presentViewController: alert animated: YES completion: nil];
}

#pragma mark - UITableView.

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == tbFunded || tableView == tbUpload)
    {
        return 12.0;
    }
    
    return 0.01f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == tbSettings)
    {
        return 50.0;
    }
    
    return 0.01f;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tbFunded)
    {
        return arrFunds.count;
    }
    else if(tableView == tbUpload)
    {
        return arrUploads.count;
    }
    else
    {
        return arrSettings.count;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbFunded || tableView == tbUpload)
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
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbFunded)
    {
        FundedTableViewCell *cell = (FundedTableViewCell*)[tableView dequeueReusableCellWithIdentifier: NSStringFromClass([FundedTableViewCell class]) forIndexPath:indexPath];
        cell.delegate = self;
        NSDictionary *dic=[arrFunds objectAtIndex:indexPath.row];
        Event *f =[[Event alloc]init];
        f.event_id=[dic objectForKey:@"id"];
        //f.type
        f.message=[dic objectForKey:@"description"];
       // f.created_at
        //f.updated_at
        //f.creator
        //f.recipient
        
        //f.is_read
        NSDictionary *dicStatus=[dic objectForKey:@"stats"];
        f.gift_amount_cents=[[dicStatus objectForKey:@"amount_raised_cents"] intValue];
        f.photo_urls=[dic objectForKey:@"photo_url"];
        
        Feed *objFeed=[[Feed alloc]init];
        objFeed.feed_id=[dic objectForKey:@"id"];
        objFeed.pre_amount=[[dic objectForKey:@"goal_amount_cents"] intValue];
        objFeed.photo = [dic valueForKey:@"photo_url"];
        objFeed.videoURL = [dic valueForKey:@"video_url"];
        
        f.feed=objFeed;
       // objFeed.pre_amount=[dic objectForKey:@""];
        
        //Event* f = [arrFunds objectAtIndex: indexPath.row];
        [cell setDonateFeed: f];
        return cell;
    }
    else if(tableView == tbUpload)
    {
        UploadTableViewCell *cell = (UploadTableViewCell*)[tableView dequeueReusableCellWithIdentifier: NSStringFromClass([UploadTableViewCell class]) forIndexPath:indexPath];
        Feed* f = [arrUploads objectAtIndex: indexPath.row];
        cell.delegate = self;
        cell.btSmall1.tag=indexPath.row;
        [cell.btSmall1 addTarget:self action:@selector(EditProject:) forControlEvents:UIControlEventTouchDown];
        
        [cell setFeed: f];
        return cell;
    }
    else
    {
        SettingsTableViewCell *cell = (SettingsTableViewCell*)[tableView dequeueReusableCellWithIdentifier: NSStringFromClass([SettingsTableViewCell class]) forIndexPath:indexPath];
        [cell setItem: [arrSettings objectAtIndex: indexPath.row] isShowDonatedAmount: [AppEngine sharedInstance].isShowDonatedAmount];
        cell.delegate = self;
        return cell;
    }
}

-(IBAction)EditProject:(UIButton*)sender
{
    Feed* f = [arrUploads objectAtIndex: sender.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadViewController *myVC = (UploadViewController *)[storyboard instantiateViewControllerWithIdentifier:@"UploadViewController"];
    myVC.isUpdateMode=TRUE;
    myVC.objFeed=f;
    [AppEngine sharedInstance].currentUser.lastSelectedId=[f.feed_id intValue];
    [self.navigationController pushViewController:myVC animated:TRUE];
    //[self presentViewController:myVC animated:YES completion:nil];
    
}
- (void) changedShowDonatedAmount:(BOOL)isShowDonatedAmount
{
    [[CoreHelper sharedInstance] setIsShowDonatedAmount: isShowDonatedAmount];    
    [self updateProfileInfo];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbFunded)
    {
        return 110.0;
    }
    else if(tableView == tbUpload)
    {
        return 145.0;
    }
    else
    {
        return [SettingsTableViewCell getHeight];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: NO];
    if(tableView == tbSettings)
    {
        if(indexPath.row == 0)
        {
            [self withdrawMoney];
        }
        else if(indexPath.row == 1)
        {
            [self editProfile];
        }
        else if(indexPath.row == 2)
        {
            [self rateUs];
        }
        else if(indexPath.row == 3)
        {
            [self emailUsFeedback];
        }
        else if(indexPath.row == 4)
        {
            [self help];
        }
        else
        {

        }
    }
}

#pragma mark - Settings.

- (void) withdrawMoney
{
    [self showWithdrawDialog];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    id nextView = [storyboard instantiateViewControllerWithIdentifier: @"WithdrawViewController"];
//    [self.navigationController pushViewController: nextView animated: YES];
}

- (void) editProfile
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id nextView = [storyboard instantiateViewControllerWithIdentifier: @"EditProfileViewController"];
    [self.navigationController pushViewController: nextView animated: YES];
}

- (void) rateUs
{
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: APP_STORE_URL]];
}

- (void) emailUsFeedback
{
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Feedback on DonorSee"];
        [mailViewController setToRecipients: [NSArray arrayWithObject: ADMIN_EMAIL]];
        NSString* strMessage = @"Thanks for being an early adopter of DonorSee! We appreciate your feedback.";
        [mailViewController setMessageBody: strMessage isHTML:NO];
        [self presentViewController: mailViewController animated: YES completion: nil];
    }
    else
    {
        [self presentViewController: [AppEngine showAlertWithText: @"Device is unable to send email in its current state."]
                           animated: YES
                         completion: nil];
    }
}

- (void) help
{
    
}

- (IBAction) logout
{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle: nil
                                                                        message: @"Are you sure you want to log out?"
                                                                 preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* actionYes = [UIAlertAction actionWithTitle: @"Yes"
                                                        style: UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                          [[NSUserDefaults standardUserDefaults] setValue:@"-1" forKey:@"stripe_userid"];
                                                          [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"api_token"];
                                                          [[NSUserDefaults standardUserDefaults] synchronize];
                                                          
                                                          [AppEngine sharedInstance].currentUser = nil;
                                                          [[CoreHelper sharedInstance] logout];
                                                          [self.navigationController popToRootViewControllerAnimated: YES];
                                                          
                                                      }];
    [controller addAction: actionYes];
    
    UIAlertAction* actionNo = [UIAlertAction actionWithTitle: @"No"
                                                       style: UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                     }];
    [controller addAction: actionNo];
    [self presentViewController: controller animated: YES completion: nil];
}

#pragma mark - UploadTableCellDelegate.

- (void) emailFeed:(Feed *)f array:(NSArray *)arrEmails
{
    if([MFMailComposeViewController canSendMail])
    {
        NSString *messageBody = f.feed_description;
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        
        [mc setCcRecipients: arrEmails];
        [mc setMessageBody:messageBody isHTML:NO];
        
//        NSData* imageData;
//        if(imgShare)
//        {
//            imageData = UIImagePNGRepresentation(imgShare);
//        }
//        else
//        {
//            imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [[JAmazonS3ClientManager defaultManager] getPathForPhoto: f.photo]]];
//        }
//        
//        [mc addAttachmentData: imageData mimeType: @"image/png" fileName: @"donate"];
        [self presentViewController:mc animated:YES completion:NULL];
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

#pragma mark Refresh Delegate.

- (void)beganRefreshing
{
    [self loadDataSource];
}

- (void)loadDataSource {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(currentPage == TAB_FUNDED)
            {
                [self loadFundedFeeds];
            }
            else if(currentPage == TAB_UPLOAD)
            {
                [self loadMyFeeds];
            }
        });
        
    });
}

#pragma mark - Withdraw.

- (void) initWithdrawUI
{
    viWithdrawDialog.layer.masksToBounds = YES;
    viWithdrawDialog.layer.cornerRadius = 10.0;
    
    viWithdrawEmail.layer.masksToBounds = YES;
    viWithdrawEmail.layer.cornerRadius = 10.0;
    viWithdrawEmail.layer.borderWidth = 1.0;
    viWithdrawEmail.layer.borderColor = [UIColor colorWithRed: 195.0/255.0 green: 195.0/255.0 blue: 195.0/255.0 alpha: 1.0].CGColor;
    
    viWithdrawAmount.layer.masksToBounds = YES;
    viWithdrawAmount.layer.cornerRadius = 10.0;
    viWithdrawAmount.layer.borderWidth = 1.0;
    viWithdrawAmount.layer.borderColor = [UIColor colorWithRed: 195.0/255.0 green: 195.0/255.0 blue: 195.0/255.0 alpha: 1.0].CGColor;
    tfWithdrawAmount.inputAccessoryView = toolBar;
    
    btWithdraw.layer.masksToBounds = YES;
    btWithdraw.layer.cornerRadius = 20.0;
    
    viWithdraw.frame = self.view.bounds;
    [self.view addSubview: viWithdraw];
    viWithdraw.hidden = YES;
}

- (void) showWithdrawDialog
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FollowersViewController *followersController = [storyboard instantiateViewControllerWithIdentifier:@"FollowersView"];
    followersController.viewType = @"thistory";
    [self.navigationController pushViewController:followersController animated:YES];
}

- (void) hideWithdrawDialog
{
    [self hideKeyboard];
    viWithdraw.hidden = YES;
}

- (IBAction) actionCloseWithdraw:(id)sender
{
    [self hideWithdrawDialog];
}

- (void) checkDoneButton: (NSString*) text
{
    if([text length] == 0)
    {
        btDone.tintColor = [UIColor lightGrayColor];
    }
    else
    {
        btDone.tintColor = [UIColor blueColor];
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self checkDoneButton: textField.text];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self checkDoneButton: textField.text];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == tfWithdrawEmail)
    {
        [tfWithdrawAmount becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == tfWithdrawAmount)
    {
        if (string.length == 0)
        {
            NSString* text = textField.text;
            if([text length] > 0)
            {
                NSString *newString = [text substringToIndex:[text length] - 1];
                [self checkDoneButton: newString];
            }
            else
            {
                [self checkDoneButton: text];
            }
            
            return YES;
        }
        
        NSString *editedString = [tfWithdrawAmount.text stringByReplacingCharactersInRange:range withString:string];
        double editedStringValue = editedString.doubleValue;
        
        NSArray* array = [editedString componentsSeparatedByString: @"."];
        BOOL validateNumber = YES;
        if([array count] > 1)
        {
            NSString* afterPointString = [array lastObject];
            NSLog(@"afterPointString = %@", afterPointString);
            
            if([afterPointString length] > 2)
            {
                validateNumber = NO;
            }
        }
        
        BOOL result = (editedStringValue <= [AppEngine sharedInstance].currentUser.received_amount) & validateNumber;
        
        [self checkDoneButton: [NSString stringWithFormat: @"%@%@", textField.text, string]];
        return result;
    }
    
    return YES;
}

- (IBAction) actionInfo:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil
                                                                   message: MSG_INFO_WITHDRAW
                                                            preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok"
                                                       style: UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                     }];
    [alert addAction: okAction];
    [self presentViewController: alert animated: YES completion: nil];
}

- (IBAction) actionInputDone:(id)sender
{
    [tfWithdrawAmount resignFirstResponder];
}

- (void) hideKeyboard
{
    [tfWithdrawAmount resignFirstResponder];
    [tfWithdrawEmail resignFirstResponder];
}

- (IBAction) actionWithdraw:(id)sender
{
    [self hideKeyboard];
    
    NSString* email = tfWithdrawEmail.text;
    NSString* amount = tfWithdrawAmount.text;

    if(email == nil || ![AppEngine emailValidate: email])
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_EMAIL] animated: YES completion: nil];
        return;
    }
    
    if([amount floatValue] <= 0)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_AMOUNT] animated: YES completion: nil];
        return;
    }
    
    NSString* messageBody = [NSString stringWithFormat: @"%@ is asking withdraw.\r\nPaypal email address: %@\r\nWithdraw Amount: $%@",
                             [AppEngine sharedInstance].currentUser.name,
                             email,
                             amount];
    
    [SVProgressHUD showWithStatus: @"Withdrawing..." maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] withdrawMoney: email
                                        message: messageBody
                                         amount: amount
                                        user_id: [AppEngine sharedInstance].currentUser.user_id
                                        success:^(NSDictionary *dicWithdraw) {
                                            
                                            [SVProgressHUD dismiss];
                                            
                                            [AppEngine sharedInstance].currentUser.received_amount -= [amount floatValue];
                                            [self presentViewController: [AppEngine showAlertWithText: MSG_WITHDRAW_SUCCESS] animated: YES completion:^{
                                                
                                                lbAvailableAmount.text = [NSString stringWithFormat: @"$%0.2f", [AppEngine sharedInstance].currentUser.received_amount];
                                                tfWithdrawAmount.text = @"";
                                                tfWithdrawEmail.text = @"";
                                            }];
                                            
                                        } failure:^(NSString *errorMessage) {
                                            
                                            [SVProgressHUD dismiss];
                                        }];
}


- (IBAction)showFollowersButtonTapped:(id)sender {
    if (![self.followersCountLabel.text isEqualToString:@"0"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FollowersViewController *followersController = [storyboard instantiateViewControllerWithIdentifier:@"FollowersView"];
        followersController.selectedUser = [AppEngine sharedInstance].currentUser;
        [self.navigationController pushViewController:followersController animated:YES];
    }

    
}

-(void)openPlayer: (NSString*) videoURL;
{
    VideoPlayer *videoPlayer = [[VideoPlayer alloc] init];
    videoPlayer.viewController = self;
    [videoPlayer playVideo: videoURL];
}

@end
