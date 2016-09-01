//
//  FollowersViewController.m
//  DonorSee
//
//  Created by Keval on 25/08/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "FollowersViewController.h"
#import "Event.h"

@interface FollowersViewController ()

@property (weak, nonatomic) IBOutlet UITableView *followersTableView;

@property (nonatomic, strong) NSArray *followers;

@property (nonatomic, strong) NSArray *transactions;

@property (nonatomic, strong) NSArray *receivedGiftstransactions;

@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@end

@implementation FollowersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _followers = @[];
    _transactions = @[];
    _receivedGiftstransactions = @[];
    
    
    if ([_viewType isEqualToString:@"thistory"]) {
        [self getTransactionHistory];
        self.headerTitle.text = @"Transaction History";
    } else {
        [self getUserFollowStatus];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onDismissView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) getTransactionHistory {
    [[NetworkClient sharedClient] getTransactionHistory: [AppEngine sharedInstance].currentUser.user_id
                                                success:^(NSArray *transactions) {
                                                    
                                                    FEMMapping *mapping = [DSMappingProvider eventMappingForTransactionHistory];
                                                    _transactions = [FEMDeserializer collectionFromRepresentation:transactions mapping:mapping];
                                                    [_followersTableView reloadData];
                                                    [self getReceivedGiftsTransactionHistory];
                                                } failure:^(NSString *errorMessage) {
                                                    [self getReceivedGiftsTransactionHistory];
                                                }];
}

- (void) getReceivedGiftsTransactionHistory {
    
    [[NetworkClient sharedClient] getReceivedGiftsTransactionHistory:[AppEngine sharedInstance].currentUser.user_id success:^(NSArray *transactions) {
        
        FEMMapping *mapping = [DSMappingProvider eventMappingForTransactionHistory];
        _receivedGiftstransactions = [FEMDeserializer collectionFromRepresentation:transactions mapping:mapping];
        [_followersTableView reloadData];
        
    } failure:^(NSString *errorMessage) {
        
    }];
    
}

- (void) getUserFollowStatus {
    [SVProgressHUD show];
    
    if (_selectedUser.user_id == [AppEngine sharedInstance].currentUser.user_id) {
        
        [[NetworkClient sharedClient] getUserFollowingStatus:_selectedUser.user_id user_id:_selectedUser.user_id success:^(NSArray *followStatus) {
            [SVProgressHUD dismiss];
            if (followStatus.count > 0) {
                _followers = [NSArray arrayWithArray:followStatus];
                [_followersTableView reloadData];
                
            }
        } failure:^(NSString *errorMessage) {
            [SVProgressHUD dismiss];
        }];
        
        return;
    }
    
    
    [[NetworkClient sharedClient] getUserFollowStatus:_selectedUser.user_id user_id:[AppEngine sharedInstance].currentUser.user_id success:^(NSArray *followStatus) {
        [SVProgressHUD dismiss];
        if (followStatus.count > 0) {
            _followers = [NSArray arrayWithArray:followStatus];
            [_followersTableView reloadData];
        }
        
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD dismiss];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([_viewType isEqualToString:@"thistory"]) return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_viewType isEqualToString:@"thistory"]) {
        if (section == 0) {
            return _transactions.count;
        }
        return _receivedGiftstransactions.count;
    }
    return _followers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_viewType isEqualToString:@"thistory"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TransactionHistoryCell"];
        
        UILabel *descLbl = (UILabel *)[cell.contentView viewWithTag:11];
        UILabel *amountLbl = (UILabel *)[cell.contentView viewWithTag:12];
        
        if (indexPath.section == 0) {
            Event *transcation = [_transactions objectAtIndex:indexPath.row];
            amountLbl.text = [NSString stringWithFormat:@"$%i", transcation.gift_amount_cents/100];
            descLbl.text = [NSString stringWithFormat:@"Gave to %@ project", transcation.recipient.name];
        } else {
            Event *transcation = [_receivedGiftstransactions objectAtIndex:indexPath.row];
            amountLbl.text = [NSString stringWithFormat:@"$%i", transcation.gift_amount_cents/100];
            descLbl.text = [NSString stringWithFormat:@"Received gift from %@ project", transcation.creator.name];
        }
        

        return cell;
        
    }
    
    static NSString *cellIdentifier = @"FollowersCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIImageView *profilePic = (UIImageView *)[cell.contentView viewWithTag:11];
    UILabel *nameLbl = (UILabel *)[cell.contentView viewWithTag:12];
    
    NSDictionary *user = [_followers objectAtIndex:indexPath.row];
    nameLbl.text = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"first_name"], [user objectForKey:@"last_name"]];
    [profilePic sd_setImageWithURL:[NSURL URLWithString: [user objectForKey:@"photo_url"]] placeholderImage:[UIImage imageNamed: @"default-profile-pic.png"]];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_viewType isEqualToString:@"thistory"])  return;
    
    NSDictionary *user = [_followers objectAtIndex:indexPath.row];
    FEMMapping *mapping = [DSMappingProvider userMapping];
    User *_user = [FEMDeserializer objectFromRepresentation:user mapping:mapping];
    [self selectUser:_user];
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([_viewType isEqualToString:@"thistory"]) {
        return 48;
    }
    return 72;
}

@end