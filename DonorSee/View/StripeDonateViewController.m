//
//  StripeDonateViewController.m
//  DonorSee
//
//  Created by Keval on 11/06/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "StripeDonateViewController.h"
#import <Stripe/Stripe.h>
#import "FEMMapping.h"
#import "DSMappingProvider.h"
#import "FEMDeserializer.h"

@interface StripeDonateViewController ()<STPPaymentCardTextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *cardNewCardBtn;
@property (weak, nonatomic) IBOutlet STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) IBOutlet UILabel *donationAmountLbl;
@property (weak, nonatomic) IBOutlet UILabel *savedCardLbl;
@property (weak, nonatomic) IBOutlet UITableView *savedCardTableView;
@property (weak, nonatomic) IBOutlet UIButton *saveNewCardBtn;
@property (nonatomic, strong) NSArray *cardList;

@property (nonatomic) int selectedIndex;

@end

@implementation StripeDonateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _cardList = @[];
    _savedCardLbl.hidden = YES;
    _savedCardTableView.hidden = YES;
    _cardNewCardBtn.hidden = YES;
    _selectedIndex = -1;
    _saveNewCardBtn.hidden = YES;
    
    self.title = @"Payment";
    NSString *title = [NSString stringWithFormat:@"Pay $%@", _amount];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelView:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    
    _donationAmountLbl.text = [NSString stringWithFormat:@"$%@", _amount];
    
    self.navigationItem.leftBarButtonItem = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    //[self getUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_savedCardTableView] || [touch.view isDescendantOfView:_cardNewCardBtn] || [touch.view isDescendantOfView:_saveNewCardBtn]) {
        return NO;
    }
    
    return YES;
}

-(void)dismissKeyboard {
    if ([_paymentTextField isFirstResponder]) {
        [_paymentTextField resignFirstResponder];
    }
    
}

- (IBAction)onSaveNewCard:(id)sender {
    if (_saveNewCardBtn.isSelected) {
        _saveNewCardBtn.selected = NO;
    } else {
        _saveNewCardBtn.selected = YES;
    }
}


- (void) getUserInfo {
    [self getUserStripeSavedCards:@""];
    return;
    [[NetworkClient sharedClient] getUserInfo: [AppEngine sharedInstance].currentUser.user_id
                                      success:^(NSDictionary *dicUser) {
                                          
                                          FEMMapping *userMapping = [DSMappingProvider userMapping];
                                          User *u = [FEMDeserializer objectFromRepresentation:dicUser mapping:userMapping];
                                          [[CoreHelper sharedInstance] addUser: u];
                                          [AppEngine sharedInstance].currentUser = u;
                                          
                                          //if ([dicUser objectForKey:@"stripe_id"]) {
                                              [self getUserStripeSavedCards:@"cus_8m4EjrivGrc0o2"];
                                          //}
                                          
                                          
                                      } failure:^(NSString *errorMessage) {
                                          
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

- (void) updateSelectCard:(int)index {
    [_cardNewCardBtn setImage:[UIImage imageNamed:@"radio-button-blank"] forState:UIControlStateNormal];
    if (index == -1) {
        [_cardNewCardBtn setImage:[UIImage imageNamed:@"radio-button"] forState:UIControlStateNormal];
    }
    
    [_savedCardTableView reloadData];
}

#pragma mark -
#pragma mark Navbar Action handler
- (IBAction)onSelectNewCard:(id)sender {
    _selectedIndex = -1;
    [self updateSelectCard:_selectedIndex];
}

-(IBAction)onCancelView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(id)sender {
    if (![self.paymentTextField isValid]) {
        return;
    }
    
    
    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constants.m"
                                                    }];
        [self.delegate paymentViewController:self didFinish:error];
        return;
    }
    
    [SVProgressHUD showWithStatus: @"Processing..." maskType: SVProgressHUDMaskTypeClear];
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams
                                          completion:^(STPToken *token, NSError *error) {
                                              
                                              [SVProgressHUD dismiss];
                                              if (error) {
                                                  [self.delegate paymentViewController:self didFinish:error];
                                                  return;
                                              }
                                              
                                              [[NetworkClient sharedClient] saveUserCard:[AppEngine sharedInstance].currentUser.user_id stripe_token:token.tokenId success:^(NSDictionary *cardInfo) {
                                                  //[self getUserStripeSavedCards:@""];
                                                  [self.delegate paymentViewController:self didCompletedWithToken:token.tokenId];
                                              } failure:^(NSString *errorMessage) {
                                                  
                                              }];
                                              
                                              //[self createStipeAccount:token];
                                              //[self getUserStripeSavedCards];
                                              //[self getTokenForSavedCard];
                                              
                                              //[self.delegate paymentViewController:self didCompletedWithToken:token.tokenId];
                                          }];
}

- (void) createStipeAccount:(STPToken *)token {
    [[NetworkClient sharedClient] createStipeAccountForUser:[AppEngine sharedInstance].currentUser.user_id email:[AppEngine sharedInstance].currentUser.email stripe_token:token.tokenId success:^(NSDictionary *dicDonate) {
        
    } failure:^(NSString *errorMessage) {
        
    }];
}

- (void) getUserStripeSavedCards:(NSString *)customerId {
    //
    
    [[NetworkClient sharedClient] getUserSavedCards:[AppEngine sharedInstance].currentUser.user_id success:^(NSArray *cards) {
        
        //NSLog(@"cards %@", cards);
        
        if (cards.count > 0) {
            _cardList = [NSArray arrayWithArray:cards];
            _savedCardLbl.hidden = NO;
            _savedCardTableView.hidden = NO;
            _cardNewCardBtn.hidden = NO;
            [self updateSelectCard:_selectedIndex];
            [_savedCardTableView reloadData];
        }
        
    } failure:^(NSString *errorMessage) {
        
    }];
    
    /*
    [[NetworkClient sharedClient] getUserSavedCardsFromStripe:customerId success:^(NSDictionary *dicDonate) {
        //id = "card_18UW5YDAyu7GKAGHiDgrN7so";
        //NSLog(@"dicDonate %@", dicDonate);
        
        if ([dicDonate objectForKey:@"data"]) {
            _cardList = [NSArray arrayWithArray:[dicDonate objectForKey:@"data"]];
            if (_cardList.count > 0) {
                
                _savedCardLbl.hidden = NO;
                _savedCardTableView.hidden = NO;
                _cardNewCardBtn.hidden = NO;
                [self updateSelectCard:_selectedIndex];
                [_savedCardTableView reloadData];
                
            }
        }
        
    } failure:^(NSString *errorMessage) {
        
    }];*/
}

- (void) getTokenForSavedCard {
    [[NetworkClient sharedClient] getStripeTokenForSavedCard:@"card_18UW5YDAyu7GKAGHiDgrN7so" success:^(NSDictionary *dicDonate) {
        
    } failure:^(NSString *errorMessage) {
        
    }];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cardList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SavedCardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel *cardNo = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *cardType = (UILabel *)[cell.contentView viewWithTag:12];
    
    UIImageView *selectedRow = (UIImageView *)[cell.contentView viewWithTag:13];
    [selectedRow setImage:[UIImage imageNamed:@"radio-button-blank"]];
    if (indexPath.row == _selectedIndex) {
        [selectedRow setImage:[UIImage imageNamed:@"radio-button"]];
    }
    //selectedRow.hidden = YES;
    
    NSDictionary *cardInfo = [_cardList objectAtIndex:indexPath.row];
    
    cardNo.text = [NSString stringWithFormat:@"XXXX XXXX XXXX %@", [cardInfo objectForKey:@"last4"]];
    cardType.text = [cardInfo objectForKey:@"brand"];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    [self updateSelectCard:_selectedIndex];
}


@end