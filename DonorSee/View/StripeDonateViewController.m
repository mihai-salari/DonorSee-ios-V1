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

@property (weak, nonatomic) IBOutlet UIView *addCardView;
@property (weak, nonatomic) IBOutlet UIButton *removeCardBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addCardHeightConstraint;


@end

@implementation StripeDonateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _cardList = @[];
    _savedCardLbl.hidden = YES;
    _savedCardTableView.hidden = YES;
    _cardNewCardBtn.hidden = YES;
    _selectedIndex = 0;
    _saveNewCardBtn.hidden = YES;
    
    
    _addCardView.hidden = YES;
    _removeCardBtn.hidden = YES;
    
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
    
    [self getUserStripeSavedCards:@""];
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
- (IBAction)onRemoveSavedCard:(id)sender {
    
    if (_cardList.count > 0) {
        
        NSDictionary *card = [_cardList lastObject];
        
        [SVProgressHUD showWithStatus: @"Processing..." maskType: SVProgressHUDMaskTypeClear];
        [[NetworkClient sharedClient] removeUserCard:[AppEngine sharedInstance].currentUser.user_id card_id:[card objectForKey:@"id"] success:^(NSDictionary *cardInfo) {
            [SVProgressHUD dismiss];
            [self getUserStripeSavedCards:@""];
        } failure:^(NSString *errorMessage) {
            [SVProgressHUD dismiss];
        }];
    }
    
}

- (IBAction)onSaveNewCard:(id)sender {
    if (_saveNewCardBtn.isSelected) {
        _saveNewCardBtn.selected = NO;
    } else {
        _saveNewCardBtn.selected = YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark -
#pragma mark Navbar Action handler


-(IBAction)onCancelView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(id)sender {
    if (_selectedIndex == 1) {
        
        [self.delegate paymentViewController:self didCompletedWithToken:@"0"];
        return;
    }
    
    if (![self.paymentTextField isValid]) {
        return;
    }
    
    [self.paymentTextField resignFirstResponder];
    
    
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
                                          }];
}


- (void) getUserStripeSavedCards:(NSString *)customerId {
    //
    [SVProgressHUD showWithStatus: @"Processing..." maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] getUserSavedCards:[AppEngine sharedInstance].currentUser.user_id success:^(NSArray *cards) {
        
        //NSLog(@"cards %@", cards);
        [SVProgressHUD dismiss];
        
        if (cards.count > 0) {
            _cardList = [NSArray arrayWithArray:cards];
            _addCardView.hidden = YES;
            _addCardHeightConstraint.constant = 0;
            _removeCardBtn.hidden = NO;
            _selectedIndex = 1;
        } else {
            _addCardView.hidden = NO;
            _addCardHeightConstraint.constant = 96;
            _removeCardBtn.hidden = YES;
            _selectedIndex = 0;
        }
        
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD dismiss];
    }];
}



@end