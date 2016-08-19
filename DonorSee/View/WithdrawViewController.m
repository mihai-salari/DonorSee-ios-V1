//
//  WithdrawViewController.m
//  DonorSee
//
//  Created by star on 3/15/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "WithdrawViewController.h"
#import <MessageUI/MessageUI.h>
#import "FEMMapping.h"
#import "DSMappingProvider.h"
#import "FEMDeserializer.h"

@interface WithdrawViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UILabel            *lbTotalAmount;
@property (nonatomic, weak) IBOutlet UITextField        *tfEmail;
@property (nonatomic, weak) IBOutlet UITextField        *tfAmount;

@property (weak, nonatomic) IBOutlet UIToolbar          *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *btDone;

@end

@implementation WithdrawViewController
@synthesize lbTotalAmount;
@synthesize tfEmail;
@synthesize tfAmount;
@synthesize toolBar;
@synthesize btDone;

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
    
    tfAmount.inputAccessoryView = toolBar;
    
    [SVProgressHUD showWithStatus: @"" maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] getUserInfo: [AppEngine sharedInstance].currentUser.user_id
                                      success:^(NSDictionary *dicUser) {
                                         
                                          [SVProgressHUD dismiss];
                                          FEMMapping *userMapping = [DSMappingProvider userMapping];
                                          User *u = [FEMDeserializer objectFromRepresentation:dicUser mapping:userMapping];
                                          [AppEngine sharedInstance].currentUser = u;
                                          
                                          lbTotalAmount.text = [NSString stringWithFormat: @"$%d", (int)u.received_amount];
                                          
                                      } failure:^(NSString *errorMessage) {
                                          [SVProgressHUD dismiss];
                                      }];
}

#pragma mark - UITextField.
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
    if(textField == tfEmail)
    {
        [tfAmount becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == tfAmount)
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
        
        NSString *editedString = [tfAmount.text stringByReplacingCharactersInRange:range withString:string];
        NSInteger editedStringValue = editedString.integerValue;
        BOOL result = editedStringValue <= [AppEngine sharedInstance].currentUser.received_amount;
        
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
    [tfAmount resignFirstResponder];
}

- (void) hideKeyboard
{
    [tfAmount resignFirstResponder];
    [tfEmail resignFirstResponder];
}

- (IBAction) actionWithdraw:(id)sender
{
    [self hideKeyboard];
    
    NSString* email = tfEmail.text;
    NSString* amount = tfAmount.text;
    
    if(email == nil || ![AppEngine emailValidate: email])
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_EMAIL] animated: YES completion: nil];
        return;
    }
    
    if(amount <= 0)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_AMOUNT] animated: YES completion: nil];
        return;
    }
    
    NSString* messageBody = [NSString stringWithFormat: @"%@ is asking withdraw.\r\nPaypal email address: %@\r\nWithdraw Amount: $%@", [AppEngine sharedInstance].currentUser.name, email, amount];
    
    [SVProgressHUD showWithStatus: @"Withdrawing..." maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] withdrawMoney: email
                                        message: messageBody
                                         amount: amount
                                        user_id: [AppEngine sharedInstance].currentUser.user_id
                                        success:^(NSDictionary *dicWithdraw) {
                                            
                                            [SVProgressHUD dismiss];
                                            
                                            [AppEngine sharedInstance].currentUser.received_amount -= [amount floatValue];
                                            [self presentViewController: [AppEngine showAlertWithText: MSG_WITHDRAW_SUCCESS] animated: YES completion:^{
                                                
                                                lbTotalAmount.text = [NSString stringWithFormat: @"$%f", [AppEngine sharedInstance].currentUser.received_amount];
                                                tfAmount.text = @"";
                                                tfEmail.text = @"";
                                                
                                            }];
                                            
                                        } failure:^(NSString *errorMessage) {
                                            
                                            [SVProgressHUD dismiss];
                                        }];
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
            [self withdrawMoney];
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

- (void) withdrawMoney
{
    
}

@end
