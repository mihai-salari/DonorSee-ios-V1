//
//  NotificationViewController.m
//  DonorSee
//
//  Created by star on 3/22/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
#import "DetailFeedViewController.h"
#import "OtherUserViewController.h"
#import "AppDelegate.h"
#import "SignInViewController.h"
#import "AuthView.h"

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate, NotificationTableViewCellDelegate>
{
    NSMutableArray          *arrNotifications;
    int                         offsetGlobal;
}


@property (nonatomic, strong) AuthView *viSignInFB;

@property (nonatomic, weak) IBOutlet UITableView        *tbMain;
@property (nonatomic, weak) IBOutlet UILabel            *lbEmpty;
@end

@implementation NotificationViewController
@synthesize viSignInFB;

@synthesize tbMain;
@synthesize lbEmpty;

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

    arrNotifications = [[NSMutableArray alloc] init];
    [tbMain registerNib: [UINib nibWithNibName: @"NotificationTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([NotificationTableViewCell class])];
    
    [self initAuthUI];
}

- (void) viewWillAppear:(BOOL)animated
{
    tbMain.estimatedRowHeight = 75.0; // for example. Set your average height
    
    [self  checkAuthView];
}

- (void) checkAuthView{
    if([AppEngine sharedInstance].currentUser){
        [self loadActivities];
        viSignInFB.hidden = YES;
    }
    else{
        viSignInFB.hidden = NO;
    }
    
}

- (void) loadActivities
{
    self.tbMain.tableHeaderView = nil;
    
    if([arrNotifications count] == 0)
    {
        [SVProgressHUD show];
    }
    [[NetworkClient sharedClient] getMyActivities:FETCH_LIMIT
                                           offset:offsetGlobal
                                          success:^(NSArray *array1) {
                                                   [SVProgressHUD dismiss];
                                              
                                              
                                              if(offsetGlobal == 0)
                                              {
                                                  [arrNotifications removeAllObjects];
                                              }
                                              
                                              if(array1 != nil && [array1 count] > 0)
                                              {
                                                  [arrNotifications addObjectsFromArray: array1];
                                                  offsetGlobal += (int)[array1 count];
                                              }
                                              
                                              [tbMain reloadData];
                                    
                                                    if([arrNotifications count] == 0)
                                                    {
                                                        [self showNoDataHeader];
                                                    }
                [self checkUnReadItems];
                                               } failure:^(NSString *errorMessage) {
                                                   [SVProgressHUD dismiss];
                                                   [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                               }];
}

- (void) showNoDataHeader {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    lbl.backgroundColor = [UIColor whiteColor];
    lbl.textColor = [UIColor colorWithRed:0.5548 green:0.5385 blue:0.5171 alpha:1.0];
    lbl.text = @"No notification available";
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont systemFontOfSize:13];
    
    self.tbMain.tableHeaderView = lbl;
}

- (void) checkUnReadItems {
    if (arrNotifications.count > 0) {
        [self markNotificationsRead];
    }
}

- (void) markNotificationsRead {
    for (Event *notification in arrNotifications) {
        if(notification.is_read){
            continue;
        }
        [[NetworkClient sharedClient] readActivity:notification.event_id success:^(NSDictionary *dicDonate) {
            [[AppDelegate getDelegate].mainTabBar updateNotificationBadge];
            notification.is_read = true;
            [tbMain reloadData];
        } failure:^(NSString *errorMessage) {
        }];
    }
}

- (void) loadNotifications
{
    [[NetworkClient sharedClient] getNotifications:^(NSArray *notifications) {
        
        NSLog(@"notifications %@", notifications);
        
        if (notifications.count > 0) {
            [arrNotifications addObjectsFromArray: notifications];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"register_date" ascending:NO];
        NSArray *orderedArray = [arrNotifications sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        arrNotifications = [NSMutableArray arrayWithArray:orderedArray];
        
        if([arrNotifications count] == 0)
        {
            lbEmpty.hidden = NO;
        }
        else {
            lbEmpty.hidden = YES;
        }
        
        [tbMain reloadData];
        
        
    } failure:^(NSString *errorMessage) {
        
    }];
    
    [self checkUnreadMessages];
}

- (void) checkUnreadMessages {
    
    [[AppDelegate getDelegate].mainTabBar updateNotificationBadge];
}

#pragma mark - UITableView.

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (int)[arrNotifications count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        [self loadActivities];
    }
    
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
    NotificationTableViewCell *cell = (NotificationTableViewCell*)[tableView dequeueReusableCellWithIdentifier: NSStringFromClass([NotificationTableViewCell class]) forIndexPath:indexPath];
    
    
    id object = [arrNotifications objectAtIndex:indexPath.row];
    [cell setEventNotification:object];
    cell.delegate = self;
    
    return cell;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event* a = [arrNotifications objectAtIndex: indexPath.row];
    return [NotificationTableViewCell getHeight: a];
}*/
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void) selectedNotification: (Event *) a cell:(NotificationTableViewCell*) cell
{
    if ([a.type isEqualToString:@"follow"]) {
        [[AppDelegate getDelegate] gotoOtherProfile:@{@"user_id":[NSNumber numberWithInteger:a.creator.user_id]}];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailFeedViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"DetailFeedViewController"];
        nextView.isVisibleFromNotification = YES;
        nextView.selectedFeed = a.feed;
        [self.navigationController pushViewController: nextView animated: YES];
    }
    
    //Read Activity.
    a.is_read = YES;
    [cell setEventNotification: a];
}

//- (void)selectedNotificationNew:(Notification *)a cell:(id)cell
//{
//    if (a.type == 0) {
//        [[AppDelegate getDelegate] gotoOtherProfile:@{@"user_id":[NSNumber numberWithInteger:a.user_id]}];
//    } else {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        DetailFeedViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"DetailFeedViewController"];
//        nextView.selectedFeed = a.feed;
//        [self.navigationController pushViewController: nextView animated: YES];
//    }
//    
//    //Read Activity.
//    a.is_read = YES;
//    [cell setNotificationNew:a];
//    [[NetworkClient sharedClient] readNotification: a.notification_id];
//}

#pragma mark - Auth.

- (void) initAuthUI
{
    CGRect rect = CGRectMake(0, TOP_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOP_BAR_HEIGHT - TAB_BAR_HEIGHT);
    //    viSignInFB = [[AuthView alloc] initAuthView: rect isAskingPaypal: NO parentView: self delegate: self];
    viSignInFB = [[AuthView alloc] initAuthView: rect parentView: self delegate: self];
    viSignInFB.hidden = YES;
    [self.view addSubview: viSignInFB];
    
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

@end
