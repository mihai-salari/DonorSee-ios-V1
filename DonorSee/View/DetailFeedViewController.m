//
//  DetailFeedViewController.m
//  DonorSee
//
//  Created by star on 3/9/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "DetailFeedViewController.h"
#import "FeedTableViewCell.h"
#import "DonateViewController.h"
#import "ActivityTableViewCell.h"
#import "OtherUserViewController.h"
#import "AppDelegate.h"
#import "PhotoCellView.h"
#import "PayPalMobile.h"
#import "AuthView.h"
#import "WebDonateViewController.h"
#import "StripeDonateViewController.h"
#import "SignInViewController.h"
#import "VideoPlayer.h"
#import "FollowUpViewController.h"
#import "CountryUtils.h"

@import ALCameraViewController;
@import CircleProgressView;

@interface DetailFeedViewController () <UITableViewDataSource, UITableViewDelegate, FeedTableViewCellDelegate, UITextFieldDelegate, PhotoCellViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PayPalPaymentDelegate, StripePaymentViewControllerDelegate, FollowUpViewControllerDelegate>
{
    NSMutableArray              *arrActivities;
    
    AuthView                    *viSignInFB;
    NSString                    *postusername;
    UIImage                    *postuserAvatar;
}
@property (weak, nonatomic) IBOutlet UIButton *btnPlayVideo;

@property (nonatomic, weak) IBOutlet UIView             *viHeader;
@property (weak, nonatomic) IBOutlet UIImageView        *ivUserAvatar;
@property (weak, nonatomic) IBOutlet UILabel            *lbUsername;
@property (weak, nonatomic) IBOutlet UILabel            *lbPostTime;
@property (weak, nonatomic) IBOutlet UIView             *viGive;
@property (weak, nonatomic) IBOutlet UIButton           *btGive;
@property (weak, nonatomic) IBOutlet UILabel            *lbGiveTitle;
@property (weak, nonatomic) IBOutlet UILabel            *lbMaxPrice;
@property (weak, nonatomic) IBOutlet UILabel            *lbDescription;
@property (weak, nonatomic) IBOutlet UIImageView        *ivFeed;
@property (weak, nonatomic) IBOutlet CircleProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView             *viInfo;

@property (nonatomic, weak) IBOutlet UITableView        *tbActivity;
@property (nonatomic, weak) IBOutlet UIButton           *btTrash;
@property (nonatomic, weak) IBOutlet UILabel            *lbDonatedCount;
@property (nonatomic, weak) IBOutlet UILabel            *lbRaisedAmount;

@property (nonatomic, weak) IBOutlet UIButton           *btFollowUp;

@property (nonatomic, weak) IBOutlet UIToolbar          *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem    *btDone;

@property (nonatomic, weak) IBOutlet UIView             *viDonateContainer;
@property (nonatomic, weak) IBOutlet UIView             *viDonateBar;
@property (nonatomic, weak) IBOutlet UITextField        *tfAmount;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitDonateContainerBottom;

@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property (weak, nonatomic) IBOutlet UIView *cancelRecurringView;

@property (weak, nonatomic) IBOutlet UIView *donateButtonView;

@property (weak, nonatomic) IBOutlet UIView *btDonate;
@property (weak, nonatomic) IBOutlet UILabel *lbMonthlyDonation;
@property (weak, nonatomic) IBOutlet UIStackView *vDonateButtonMonthly;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelRecurringGift;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableTop;

@property (weak, nonatomic) IBOutlet UIImageView *ivMap;

@property (weak, nonatomic) IBOutlet UIImageView *ivFlag;

@property (weak, nonatomic) IBOutlet UILabel *lbCountryName;

@end

@implementation DetailFeedViewController
@synthesize tbActivity;
@synthesize btTrash;
@synthesize lbDonatedCount;
@synthesize lbRaisedAmount;

@synthesize viHeader;
@synthesize ivUserAvatar;
@synthesize lbUsername;
@synthesize lbPostTime;
@synthesize viGive;
@synthesize btGive;
@synthesize lbGiveTitle;
@synthesize lbMaxPrice;
@synthesize lbDescription;
@synthesize ivFeed;
@synthesize progressView;
@synthesize viInfo;

@synthesize viDonateBar;
@synthesize tfAmount;
@synthesize btFollowUp;

@synthesize toolBar;
@synthesize btDone;
@synthesize viDonateContainer;
@synthesize constraitDonateContainerBottom;

@synthesize selectedFeed;

@synthesize ivMap;
@synthesize ivFlag;
@synthesize lbCountryName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.btDonate addGestureRecognizer:singleFingerTap];
    
   // self.tbActivity.tableHeaderView = viHeader;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self onDonate];
}

- (void) onDonate{
    [self hideKeyboard];
    
    if (!selectedFeed.postUser.can_receive_gifts) {
        [self presentViewController:[AppEngine showAlertWithText:@"Project owner doesn't have stripe account linked so cant recieve funds as of now"] animated:YES completion:nil];
        return;
    }
    
    
    float amount = [tfAmount.text floatValue];
    if(amount < MIN_PRICE || amount > MAX_PRICE)
    {
        [self presentViewController: [AppEngine showAlertWithText: [NSString stringWithFormat: @"Enter any price from $%d ~ $%d", MIN_PRICE, MAX_PRICE]] animated: YES completion: nil];
        return;
    }
    
    if([AppEngine sharedInstance].currentUser != nil)
    {
        [self showPaymentOption];
    }
    else
    {
        [self showSignupPage];
    }
}

- (IBAction)actionCancelRecurring:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil message: MSG_CANCEL_MONTHLY_DONATION preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Yes" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cancelRecurringDonation];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: @"No" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction: okAction];
    [alert addAction: cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];

}
- (IBAction)onPlayVideoTap:(id)sender {
    [self openPlayer:selectedFeed.videoURL];
}

- (void) openPlayer: (NSString*) videoURL{
    VideoPlayer *videoPlayer = [[VideoPlayer alloc] init];
    videoPlayer.viewController = self;
    [videoPlayer playVideo: videoURL];

}

- (void) cancelRecurringDonation {
    [SVProgressHUD showWithStatus: @"Cancelling..." maskType: SVProgressHUDMaskTypeClear];
    
    NSString *project_id = selectedFeed.feed_id;
    [[NetworkClient sharedClient] cancelMonthlyDonation:project_id success:^(NSDictionary *info) {
        selectedFeed.is_monthly_giver = NO;
        selectedFeed.amount_given_cents = 0;
        [SVProgressHUD dismiss];
        [self updateUserDonationStatus];
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD dismiss];
        [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
    }];

}


- (void) initMember
{
    [super initMember];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    lbMaxPrice.text = @"$";
    
    arrActivities = [[NSMutableArray alloc] init];
    
    [self updateUserDonationStatus];
    [self initPaypal];
    [self initHeaderUI];
    [self initFooterUI];
    [self initAuthUI];
    [self initCountyInfo];
    
    [tbActivity registerNib: [UINib nibWithNibName: @"ActivityTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([ActivityTableViewCell class])];

    if([AppEngine sharedInstance].currentUser == nil)
    {
        btTrash.hidden = YES;
    }
    else
    {
        btTrash.hidden = NO;
        [btTrash setImage: [UIImage imageNamed: @"flag_icon.png"] forState: UIControlStateNormal];
        if([selectedFeed isCreatedByCurrentUser])
        {
            [btTrash setImage: [UIImage imageNamed: @"delete.png"] forState: UIControlStateNormal];
        }
    }
    
    tfAmount.inputAccessoryView = toolBar;
    [self loadFeed];
    [self loadActivities];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

}

- (void) updateUserDonationStatus{
    if(selectedFeed.is_monthly_giver){
        _donateButtonView.hidden = YES;
        _constraintTableTop.constant = 61;
        _constraintTableBottom.constant = 0;
        _cancelRecurringView.hidden = NO;
        _btnCancelRecurringGift.layer.cornerRadius = 10.0;
        [_btnCancelRecurringGift setClipsToBounds:YES];
        _lbMonthlyDonation.text = [NSString stringWithFormat:@"You are giving $%d monthly to this project", selectedFeed.amount_given_cents / 100];
        _vDonateButtonMonthly.hidden = NO;
    }else{
        _constraintTableTop.constant = 0;
        _constraintTableBottom.constant = 85;
        _donateButtonView.hidden = NO;
        _cancelRecurringView.hidden = YES;
    }
    
    if([selectedFeed.gift_type isEqualToString: FEED_TYPE_MONTHLY]){
        _vDonateButtonMonthly.hidden = NO;
    }else{
        _vDonateButtonMonthly.hidden = YES;

    }
}

-(void) initCountyInfo{
    if(selectedFeed.country_code!=nil){
        ivMap.hidden = NO;
        lbCountryName.hidden = NO;
        ivFlag.hidden = NO;
        
        CountryUtils *countryUtils = [[CountryUtils alloc] init];
        lbCountryName.text = [countryUtils getCountryNameByCode:selectedFeed.country_code];
        [ivFlag setImage: [UIImage imageNamed: [selectedFeed.country_code lowercaseString]]];
        
    }else{
        ivMap.hidden = YES;
        lbCountryName.hidden = YES;
        ivFlag.hidden = YES;
    }
}

#pragma mark - Header.
- (void) initHeaderUI
{
    lbUsername.userInteractionEnabled = YES;
    UITapGestureRecognizer* gestureUsername = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapUsername)];
    gestureUsername.numberOfTapsRequired = 1;
    [lbUsername addGestureRecognizer: gestureUsername];
    
    ivUserAvatar.layer.cornerRadius = ivUserAvatar.frame.size.width / 2.0;
    ivUserAvatar.layer.masksToBounds = YES;
    ivUserAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer* gestureAvatar = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapUsername)];
    gestureAvatar.numberOfTapsRequired = 1;
    [ivUserAvatar addGestureRecognizer: gestureAvatar];
    
    btGive.layer.cornerRadius = btGive.frame.size.width / 2.0;
    btGive.layer.masksToBounds = YES;
    
    ivFeed.layer.masksToBounds = YES;
    ivFeed.contentMode = UIViewContentModeScaleAspectFill;
    
    progressView.trackBackgroundColor = [UIColor whiteColor];
    progressView.trackBorderColor = [UIColor whiteColor];
    progressView.trackFillColor = [UIColor colorWithRed: 234.0/255.0 green: 157.0/255.0 blue: 13.0/255.0 alpha: 1.0];
    
    /*
    //Fill out Info.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateFeedInfo];
        
        if (_isVisibleFromNotification) {
            [self loadFeed];
        }
    });*/
}

- (void) updateFeedInfo
{
    NSString* giftTitle = @"GIFT";
    if(selectedFeed.donated_count != 1)
    {
        giftTitle = @"GIFTS";
    }
    
    lbDonatedCount.text = [NSString stringWithFormat: @"%d %@", selectedFeed.donated_count, giftTitle];
    lbRaisedAmount.text = [NSString stringWithFormat: @"$%d RAISED", selectedFeed.donated_amount/100];
    
    NSURL* urlPhoto = [NSURL URLWithString: selectedFeed.getProjectImage];
    [ivFeed sd_setImageWithURL: urlPhoto];
    
    lbDescription.text = selectedFeed.feed_description;
    
    lbMaxPrice.numberOfLines = 1;
    lbMaxPrice.adjustsFontSizeToFitWidth = YES;
    [lbMaxPrice setMinimumScaleFactor:7.0/[UIFont labelFontSize]];

    lbMaxPrice.text = [NSString stringWithFormat: @"$%d", selectedFeed.pre_amount];
    float progress = (float)(selectedFeed.donated_amount/100) / (float)(selectedFeed.pre_amount /100);
    if(progress > 1) progress = 1;
    progressView.progress = progress;
    
    //User.
    postusername = [AppEngine getValidString: selectedFeed.postUser.name]; // to store post_user_name
    lbUsername.text = [AppEngine getValidString: selectedFeed.postUser.name];
    lbPostTime.text = [AppEngine dataTimeStringFromDate:selectedFeed.created_at];
    
    //to get post user image
    NSURL *imageURL = [NSURL URLWithString:selectedFeed.postUser.avatar];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    postuserAvatar = [UIImage imageWithData:imageData];
    
    [ivUserAvatar sd_setImageWithURL: [NSURL URLWithString: selectedFeed.postUser.avatar] placeholderImage: [UIImage imageNamed: @"default-profile-pic.png"]];
    
    lbGiveTitle.hidden = NO;
    
    if(selectedFeed.donated_amount >= selectedFeed.pre_amount)
    {
        lbMaxPrice.hidden = YES;
        
        if([selectedFeed.getFeedType isEqualToString:FEED_TYPE_MONTHLY]){
            lbGiveTitle.text = @"MONTH";
            [lbGiveTitle setFont:[UIFont systemFontOfSize:7]];
            lbGiveTitle.hidden = NO;
        }else{
            lbGiveTitle.hidden = YES;
        }
        
        
        [btGive setTitle: @"FUNDED!" forState: UIControlStateNormal];
    }
    else
    {
        lbMaxPrice.hidden = NO;
        lbGiveTitle.hidden = NO;
        [btGive setTitle: @"" forState: UIControlStateNormal];
        
        if([selectedFeed.getFeedType isEqualToString:FEED_TYPE_MONTHLY]){
            lbGiveTitle.text = @"LEFT/\nMONTH";
            [lbGiveTitle setFont:[UIFont systemFontOfSize:7]];
        }else{
            lbGiveTitle.text = @"LEFT";
            [lbGiveTitle setFont:[UIFont systemFontOfSize:10]];
        }
        
        if (selectedFeed.donated_amount == 0) {
            lbMaxPrice.text = [NSString stringWithFormat: @"$%d", selectedFeed.pre_amount/100];
        } else {
            lbMaxPrice.text = [NSString stringWithFormat: @"$%d", (selectedFeed.pre_amount/100 - selectedFeed.donated_amount/100)];
        }
        
    }

    if(selectedFeed.videoURL!=nil){
        _btnPlayVideo.hidden = NO;
    }else{
        _btnPlayVideo.hidden = YES;
    }
    
    [tbActivity reloadData];
    
    [self updateUserDonationStatus];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tbActivity beginUpdates];
        [self.tbActivity endUpdates];
    });
}

- (void) onTapUsername
{
    [self selectUser: selectedFeed.postUser];
}

- (void) showProjectDeletedAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil message: MSG_FEED_DELETED preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alert addAction: okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) loadFeed {
    
    [[NetworkClient sharedClient] getSingleFeed:selectedFeed.feed_id success:^(NSDictionary *dicFeed) {
        
        FEMMapping *mapping = [DSMappingProvider projectsMapping];
        self.selectedFeed = [FEMDeserializer objectFromRepresentation:dicFeed mapping:mapping];

        [self updateFeedInfo];
        
    } failure:^(NSString *errorMessage) {
        
    }];
    
}

- (void) loadActivities
{
    [SVProgressHUD show];
    [[NetworkClient sharedClient] getActivitiesForFeed: selectedFeed
                                               success:^(NSArray *array1, Feed* f) {
                                                  
                                                   [SVProgressHUD dismiss];
                                                   
                                                   [arrActivities removeAllObjects];
                                                   if(array1 != nil && [array1 count] > 0)
                                                   {
                                                       [arrActivities addObjectsFromArray: array1];
                                                   }
                                                   
                                                   [tbActivity reloadData];

                                               } failure:^(NSString *errorMessage) {
                                                   [SVProgressHUD dismiss];
                                                   if ([errorMessage isEqualToString:MSG_FEED_DELETED]) {
                                                       [self showProjectDeletedAlert];
                                                       return;
                                                   }
                                                   [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                               }];
}

#pragma mark - UITableView.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (int)[arrActivities count];
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

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return viHeader;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    return ivFeed.frame.size.height + lbDescription.frame.size.height + viInfo.frame.size.height +btFollowUp.frame.size.height;
    return viHeader.frame.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityTableViewCell *cell = (ActivityTableViewCell*)[tableView dequeueReusableCellWithIdentifier: NSStringFromClass([ActivityTableViewCell class]) forIndexPath:indexPath];
    [cell setPostusername:postusername setPostUserAvatar:postuserAvatar] ; // added
    
    cell.delegate = self;
    [cell setEvent:[arrActivities objectAtIndex: indexPath.row]];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *a = [arrActivities objectAtIndex: indexPath.row];
    return [ActivityTableViewCell getEventHeight:a];
}

#pragma mark - Footer.
- (void) initFooterUI
{
    viDonateBar.layer.masksToBounds = YES;
    viDonateBar.layer.borderColor = COLOR_MAIN.CGColor;
    viDonateBar.layer.borderWidth = 1.0;
    viDonateBar.layer.cornerRadius = 20.0;
    
    btFollowUp.layer.masksToBounds = YES;
    btFollowUp.layer.borderColor = COLOR_MAIN.CGColor;
    btFollowUp.layer.borderWidth = 1.0;
    btFollowUp.layer.cornerRadius = 20.0;
    
    UIFont *font = [UIFont systemFontOfSize:22];
    NSString *dollarSignText = @"$";
    CGSize size = [dollarSignText sizeWithAttributes:@{NSFontAttributeName: font}];
    UILabel *dollarSignLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ceilf(size.width) + 10, tfAmount.frame.size.height)];
    dollarSignLabel.font = font;
    dollarSignLabel.text = dollarSignText;
    dollarSignLabel.textAlignment = NSTextAlignmentRight;
    dollarSignLabel.textColor = tfAmount.textColor;
    tfAmount.leftView = dollarSignLabel;
    tfAmount.leftViewMode = UITextFieldViewModeAlways;
    
    if([AppEngine sharedInstance].currentUser != nil) {
        if([selectedFeed isCreatedByCurrentUser])
        {
            btFollowUp.hidden = NO;
        } else {
            btFollowUp.hidden = NO;
            [btFollowUp setTitle:@"POST COMMENT" forState:UIControlStateNormal];
        }
    } else {
        btFollowUp.hidden = YES;
    }
    
}

- (IBAction) actionFollowUp:(id)sender
{
    
    if (![selectedFeed isCreatedByCurrentUser] && ![selectedFeed is_gave]) {
        [self presentViewController: [AppEngine showAlertWithText: @"You need to give to this project before you can leave a comment!"] animated: YES completion: nil];
    }else{
        FollowUpViewController *followUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowUp"];
        followUpController.selectedFeed = selectedFeed;
        followUpController.modalPresentationStyle = UIModalPresentationCustom;
        followUpController.delegate = self;
        
        [self presentViewController:followUpController animated:NO completion:NULL];
    }
}

- (void) onFollowUpPostedSuccess{
    [self loadActivities];
}

#pragma mark - Feed Delegate.
- (void) selectUser: (User*) user
{
    [[AppDelegate getDelegate] gotoOtherProfile:@{@"user_id":[NSNumber numberWithInteger:user.user_id]}];
}

- (void) donateFeed:(Feed *)f
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DonateViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"DonateViewController"];
    nextView.selectedFeed = selectedFeed;
    [self.navigationController pushViewController: nextView animated: YES];
}

- (void) selectFeed: (Feed*) f
{

}

- (IBAction) actionShare:(id)sender
{
    [self shareFeed: selectedFeed image: ivFeed.image];
}

- (IBAction) actionGive:(id)sender
{
//    [tbActivity setContentOffset: CGPointMake(0, tbActivity.contentSize.height - tbActivity.frame.size.height) animated:YES];
    [tfAmount becomeFirstResponder];
}

- (IBAction) deleteFeed: (id) sender
{
    if([selectedFeed isCreatedByCurrentUser])
    {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle: nil
                                                                                 message: @"Are you sure you want to remove?"
                                                                          preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle: @"Yes"
                                                            style: UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              [SVProgressHUD showWithStatus: @"Removing..." maskType: SVProgressHUDMaskTypeClear];
                                                              [[NetworkClient sharedClient] removeFeed: selectedFeed
                                                                                               user_id: [AppEngine sharedInstance].currentUser.user_id
                                                                                               success:^{
                                                                                                   
                                                                                                   [SVProgressHUD dismiss];
                                                                                                   [[NSNotificationCenter defaultCenter] postNotificationName: NOTI_UPDATE_FUNDED_FEED_AFTER_REMOVE
                                                                                                                                                       object: selectedFeed];
                                                                                                   
                                                                                                   [self actionBack: nil];
                                                                                                   
                                                                                               } failure:^(NSString *errorMessage) {
                                                                                                   
                                                                                                   [SVProgressHUD dismiss];
                                                                                                   [self presentViewController: [AppEngine showErrorWithText: errorMessage]
                                                                                                                      animated: YES
                                                                                                                    completion: nil];
                                                                                               }];
                                                              
                                                          }];
        [alertController addAction: yesAction];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle: @"No"
                                                           style: UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
        [alertController addAction: noAction];
        [self presentViewController: alertController animated: YES completion: nil];
    }
    else
    {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle: nil
                                                                                 message: @"Would you like to report this project for offensive material?"
                                                                          preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle: @"Yes"
                                                            style: UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              //Report.
                                                              [SVProgressHUD showWithStatus: @"Reporting..." maskType: SVProgressHUDMaskTypeClear];
                                                              [[NetworkClient sharedClient] reportFeed: selectedFeed
                                                                                               success:^{
                                                                                                   
                                                                                                   [SVProgressHUD dismiss];
                                                                                                   [self presentViewController: [AppEngine showMessage: MSG_REPORT title: nil]
                                                                                                                      animated: YES
                                                                                                                    completion: nil];
                                                                                                   
                                                                                               } failure:^(NSString *errorMessage) {
                                                                                                   
                                                                                                   [SVProgressHUD dismiss];
                                                                                                   [self presentViewController: [AppEngine showErrorWithText: errorMessage]
                                                                                                                      animated: YES
                                                                                                                    completion: nil];
                                                                                               }];

                                                              
                                                          }];
        [alertController addAction: yesAction];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle: @"No"
                                                           style: UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
        [alertController addAction: noAction];
        [self presentViewController: alertController animated: YES completion: nil];
    }
}

#pragma mark - UITextField Delegate.

- (IBAction) actionInputDone:(id)sender
{
    [tfAmount resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self checkDoneButton: textField.text];
    if(textField == tfAmount)
    {
        [UIView animateWithDuration: 0.25
                         animations:^{
                             
                             constraitDonateContainerBottom.constant = 216 + toolBar.frame.size.height;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];

    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self checkDoneButton: textField.text];
    
    if(textField == tfAmount)
    {
        [UIView animateWithDuration: 0.25
                         animations:^{
                             
                             constraitDonateContainerBottom.constant = 0;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];

    }
    else
    {
        if (tbActivity.contentSize.height > tbActivity.frame.size.height)
        {
            CGPoint offset = CGPointMake(0, tbActivity.contentSize.height - tbActivity.frame.size.height);
            [tbActivity setContentOffset:offset animated:YES];
        }
        tbActivity.scrollEnabled = YES;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == tfAmount)
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
        }
        else
        {
            NSString* text = [NSString stringWithFormat: @"%@%@", textField.text, string];
            [self checkDoneButton: text];
        }
    }
    
    return YES;
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

- (void) hideKeyboard
{
    [tfAmount resignFirstResponder];
}

#pragma mark - Action Donate.

- (IBAction) actionDonate:(id)sender
{
    [self hideKeyboard];
    
    if (!selectedFeed.postUser.can_receive_gifts) {
        [self presentViewController:[AppEngine showAlertWithText:@"Project owner doesn't have stripe account linked so cant recieve funds as of now"] animated:YES completion:nil];
        return;
    }
    
    
    float amount = [tfAmount.text floatValue];
    if(amount < MIN_PRICE || amount > MAX_PRICE)
    {
        [self presentViewController: [AppEngine showAlertWithText: [NSString stringWithFormat: @"Enter any price from $%d ~ $%d", MIN_PRICE, MAX_PRICE]] animated: YES completion: nil];
        return;
    }
    
    if([AppEngine sharedInstance].currentUser != nil)
    {
        [self showPaymentOption];
    }
    else
    {
        [self showSignupPage];
    }
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
    if([AppEngine sharedInstance].currentUser != nil)
    {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showPaymentOption];
        });
    }
}


-(void)showPaymentOption{
    
    [self payWithStripe];
    /*
    
    NSString *message = @"For the moment you need Paypal account to make donation";
    NSString *btnTitle = @"Ok";
    
    id stripe_user_id = [selectedFeed stripe_user_id];
    
    //if( stripe_user_id && ![stripe_user_id isKindOfClass:[NSNull class]] && !([stripe_user_id length]<=0)) {
        message = @"Please select an option to pay";
        btnTitle = @"PayPal";
   // }
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Payment Details" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self processDonate];
        
    }];
    
    
    
    //if( stripe_user_id && ![stripe_user_id isKindOfClass:[NSNull class]] && !([stripe_user_id length]<=0)) {
         UIAlertAction *stripeAction = [UIAlertAction actionWithTitle:@"Credit/Debit Card" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self payWithStripe];
         }];
         [alert addAction:stripeAction];
        
    //}
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
        printf("test");
    }];
    */
}

- (void) payWithStripe
{
    //StripeDonateViewController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StripeDonateViewController *stripeController = [storyboard instantiateViewControllerWithIdentifier:@"StripeDonateViewController"];
    UINavigationController *stripeNavController = [[UINavigationController alloc] initWithRootViewController:stripeController];
    stripeController.delegate = self;
    stripeController.amount = [NSDecimalNumber decimalNumberWithString:tfAmount.text];
    stripeController.gift_type = selectedFeed.getFeedType;
    [self presentViewController:stripeNavController animated:YES completion:nil];
}

#pragma mark - Auth.

- (void) initAuthUI
{
    CGRect rect = CGRectMake(0, TOP_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOP_BAR_HEIGHT);
//    viSignInFB = [[AuthView alloc] initAuthView: rect isAskingPaypal: NO parentView: self delegate: self];
    viSignInFB = [[AuthView alloc] initAuthView: rect parentView: self delegate: self];    
    viSignInFB.hidden = YES;
    [self.view addSubview: viSignInFB];
}

- (void) successAuth
{
    viSignInFB.hidden = YES;
    [self processDonate];
}

- (void) failAuth
{
    viSignInFB.hidden = YES;
}

- (void) processDonate
{
    /*
    int amount = [tfAmount.text floatValue];
    if(amount <= 0)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_AMOUNT] animated: YES completion: nil];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebDonateViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"WebDonateViewController"];
    nextView.amount = amount;
    nextView.selectedFeed = self.selectedFeed;
    nextView.prevViewController = self;
    [self.navigationController pushViewController: nextView animated: YES];
    */
    
    PayPalItem *item1 = [PayPalItem itemWithName:@"DonorSee"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString: tfAmount.text]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00037"];
    NSArray *items = @[item1];
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
    
    // Optional: include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"0"];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"0"];
    
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    payment.shortDescription = @"DonorSee Giving";
    payment.items = items;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = nil;// paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Update payPalConfig re accepting credit cards.
    self.payPalConfig.acceptCreditCards = self.acceptCreditCards;
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark PayPalPaymentDelegate methods

- (void) initPaypal
{
    self.acceptCreditCards = YES;
    
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.merchantName = @"DonorSee";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    _payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
//    self.environment = PayPalEnvironmentProduction;
    self.environment = PayPalEnvironmentSandbox;

    //self.environment = PayPalEnvironmentProduction;
    if(TEST_FLAG)
    {
        self.environment = PayPalEnvironmentNoNetwork;
    }

    [PayPalMobile preconnectWithEnvironment: self.environment];
    NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:^{
        
        //Update Server.
        int amount = [tfAmount.text intValue];
        NSString* gift_type = selectedFeed.getFeedType;
        
        [SVProgressHUD showWithStatus: @"Processing..." maskType: SVProgressHUDMaskTypeClear];
        [[NetworkClient sharedClient] postDonate: [AppEngine sharedInstance].currentUser.user_id
                                         feed_id: selectedFeed.feed_id
                                          amount: amount
                                       gift_type:gift_type
                                         success:^(NSDictionary *dicDonate) {
                                             
                                             [SVProgressHUD dismiss];
                                             NSLog(@"donate result = %@", dicDonate);
                                             
                                             if(dicDonate != nil)
                                             {
                                                 int donatedAmount = [dicDonate[@"amount"] intValue];
                                                 selectedFeed.donated_amount += donatedAmount;
                                                 selectedFeed.is_gave = YES;
                                                 [AppEngine sharedInstance].currentUser.pay_amount += donatedAmount;
                                                 [[CoreHelper sharedInstance] updateUserInfo: [AppEngine sharedInstance].currentUser];
                                             }
                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName: NOTI_UPDATE_FUNDED_FEED object: selectedFeed];
                                             
                                             [self updateFeedInfo];
                                             [self loadActivities];
                                             
                                             tfAmount.text = @"";

                                         } failure:^(NSString *errorMessage) {
                                             
                                             [SVProgressHUD dismiss];
                                             [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                         }];
        
    }];
}

- (void) payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization
{
    
}

- (void) payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController userWillLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization completionBlock:(PayPalProfileSharingDelegateCompletionBlock)completionBlock
{
    
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Stripe PaymentDelegate methods
- (void)paymentViewController:(StripeDonateViewController *)controller didFinish:(NSError *)error
{
    if (error) {
        [self presentViewController: [AppEngine showErrorWithText: error.localizedDescription] animated: YES completion: nil];
    }
}

- (void) paymentViewController:(StripeDonateViewController *)controller didCompletedWithToken:(NSString *)token
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        int amount = [tfAmount.text intValue];
        
        NSLog(@"Token %@", token);
        
        [SVProgressHUD showWithStatus: @"Processing..." maskType: SVProgressHUDMaskTypeClear];
        
        NSString* gift_type = selectedFeed.getFeedType;
        
        [[NetworkClient sharedClient] createGift:
                     selectedFeed.feed_id amount:amount
                                       gift_type: gift_type
                                         success:^(NSDictionary *dicDonate) {
            [SVProgressHUD dismiss];
            
             int donatedAmount = [dicDonate[@"amount_cents"] intValue];
             selectedFeed.donated_amount += donatedAmount;
             selectedFeed.donated_count += 1;
             selectedFeed.is_gave = YES;
             [AppEngine sharedInstance].currentUser.pay_amount += donatedAmount;
                                             if([gift_type isEqualToString:FEED_TYPE_MONTHLY]){
                                                 selectedFeed.amount_given_cents = donatedAmount;
                                                 selectedFeed.is_monthly_giver = YES;
                                                 [self updateUserDonationStatus];
                                             }
            
            [[NSNotificationCenter defaultCenter] postNotificationName: NOTI_UPDATE_FUNDED_FEED object: selectedFeed];
            
            [self updateFeedInfo];
            [self loadActivities];
            
            tfAmount.text = @"";
        } failure:^(NSString *errorMessage) {
            [SVProgressHUD dismiss];
            [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
        }];
        
        /*
        
        // Testing
        NSString *sourceId = selectedFeed.stripe_user_id;
        
        [[NetworkClient sharedClient] postStripeDonate:[AppEngine sharedInstance].currentUser.user_id
                                               feed_id:selectedFeed.feed_id
                                      source_stripe_id:sourceId
                                          stripe_token:token
                                                amount:amount
                                               success:^(NSDictionary *dicDonate) {
                                                   [SVProgressHUD dismiss];
                                                   NSLog(@"donate result = %@", dicDonate);
                                                   
                                                   if(dicDonate != nil)
                                                   {
                                                       int donatedAmount = [dicDonate[@"amount"] intValue];
                                                       selectedFeed.donated_amount += donatedAmount;
                                                       selectedFeed.is_gave = YES;
                                                       [AppEngine sharedInstance].currentUser.pay_amount += donatedAmount;
                                                       [[CoreHelper sharedInstance] updateUserInfo: [AppEngine sharedInstance].currentUser];
                                                   }
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName: NOTI_UPDATE_FUNDED_FEED object: selectedFeed];
                                                   
                                                   [self updateFeedInfo];
                                                   [self loadActivities];
                                                   
                                                   tfAmount.text = @"";
                                               } failure:^(NSString *errorMessage) {
                                                   [SVProgressHUD dismiss];
                                                   [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                               }];*/
    }];
         
    
}


#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}


@end
