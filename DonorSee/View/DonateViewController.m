//
//  DonateViewController.m
//  DonorSee
//
//  Created by star on 3/6/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "DonateViewController.h"
#import "PayPalMobile.h"
@import CircleProgressView;

@interface DonateViewController () <UITextFieldDelegate, PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UILabel            *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel            *lbPreAmount;
@property (weak, nonatomic) IBOutlet UITextField        *tfAmount;
@property (weak, nonatomic) IBOutlet CircleProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel            *lbProgress;
@property (weak, nonatomic) IBOutlet UIToolbar          *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *btDone;

//Sign In.
@property (weak, nonatomic) IBOutlet UIView             *viSignIn;
@property (weak, nonatomic) IBOutlet UIView             *viResult;
@property (weak, nonatomic) IBOutlet UILabel            *lbResultMessage;

@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@end

@implementation DonateViewController
@synthesize lbTitle;
@synthesize lbPreAmount;
@synthesize tfAmount;
@synthesize progressView;
@synthesize toolBar;
@synthesize lbProgress;
@synthesize btDone;
@synthesize viSignIn;
@synthesize viResult;
@synthesize lbResultMessage;

@synthesize selectedFeed;

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
    
    [self initSignInView];
    
    lbTitle.text = [NSString stringWithFormat: @"Thank you for giving to %@'s project!", self.selectedFeed.postUser.name];
    lbResultMessage.text = [NSString stringWithFormat: @"Thank you for your donation! You will be notified when %@ posts updates.", selectedFeed.postUser.name];
    
    lbPreAmount.text = [NSString stringWithFormat: @"$ %d", selectedFeed.pre_amount];
    tfAmount.inputAccessoryView = toolBar;
    
    [self initPaypal];
    
    progressView.trackFillColor = [UIColor orangeColor];
    float progress = (float)selectedFeed.donated_amount / (float)selectedFeed.pre_amount;
    [self updateProgress: progress animate: NO];
}

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
    [PayPalMobile preconnectWithEnvironment: self.environment];
    NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
}

- (void) updateProgress: (float) progress animate: (BOOL) animate
{
    lbProgress.text = [NSString stringWithFormat: @"%d%@", (int)(progress * 100), @"%"];
    
    if(progress > 1) progress = 1;
    if(progress < 0) progress = 0;
    progressView.progress = progress;
}

- (IBAction) actionInputDone:(id)sender
{
    [tfAmount resignFirstResponder];
    int amount = [tfAmount.text intValue];
    float progress = (float)(amount + selectedFeed.donated_amount) / (float)selectedFeed.pre_amount;
    [self updateProgress: progress animate: YES];
}

- (IBAction)actionGive:(id)sender
{
    NSString* amountString = tfAmount.text;
    if(amountString == nil || [amountString length] == 0)
    {
        [self presentViewController: [AppEngine showErrorWithText: MSG_INVALID_AMOUNT] animated: YES completion: nil];
        return;
    }
    
    if([AppEngine sharedInstance].currentUser != nil)
    {
        [self processDonate];
    }
    else
    {
        [self showSignInPage];
    }
}

- (void) processDonate
{
    NSString* amountString = tfAmount.text;
    PayPalItem *item1 = [PayPalItem itemWithName:@"DonorSee"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString: amountString]
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

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:^{
        
        //Update Server.
        int amount = [tfAmount.text intValue];
        
        [SVProgressHUD showWithStatus: @"Processing..." maskType: SVProgressHUDMaskTypeClear];
        [[NetworkClient sharedClient] postDonate: [AppEngine sharedInstance].currentUser.user_id
                                         feed_id: selectedFeed.feed_id
                                          amount: amount
                                         success:^(NSDictionary *dicDonate) {
                                            
                                             [SVProgressHUD dismiss];
                                             NSLog(@"donate result = %@", dicDonate);
                                             
                                             if(dicDonate != nil)
                                             {
                                                 int donatedAmount = [dicDonate[@"amount"] intValue];
                                                 selectedFeed.donated_amount += donatedAmount;
                                             }
                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName: NOTI_UPDATE_FUNDED_FEED object:nil];
                                             
                                             if(viSignIn.hidden)
                                             {
                                                 [self.navigationController popViewControllerAnimated: YES];
                                             }
                                             else
                                             {
                                                 [self showResultPage];
                                             }
                                             
                                             
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

- (void) payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization
{
    
}

- (void) payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController
{
    
}

- (void)userDidCancelPayPalProfileSharingViewController:(nonnull PayPalProfileSharingViewController *)profileSharingViewController
{
    
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}


#pragma mark - UITextField.

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self checkDoneButton: textField.text];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
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
    
    [self checkDoneButton: [NSString stringWithFormat: @"%@%@", textField.text, string]];
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

#pragma mark - Sign In.

- (void) initSignInView
{
    CGRect rect = CGRectMake(0, 60.0, self.view.frame.size.width, self.view.frame.size.height - 60.0);
    viSignIn.frame = rect;
    viResult.frame = rect;
    
    [self.view addSubview: viSignIn];
    [self.view addSubview: viResult];
    
    viSignIn.hidden = YES;
    viResult.hidden = YES;
}

- (void) showSignInPage
{
    viSignIn.hidden = NO;
}

- (void) showResultPage
{
    viSignIn.hidden = YES;
    viResult.hidden = NO;
}

- (IBAction) actionFB:(id)sender
{
    [self signInFB:^{
        
        [self processDonate];
    }];
}

- (IBAction) actionAuthBack:(id)sender
{
    viSignIn.hidden = YES;
}

- (IBAction) actionAuthDone:(id)sender
{
    [self actionBack: nil];
}


@end
