//
//  UploadViewController.m
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "UploadViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import "JAmazonS3ClientManager.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "AuthView.h"
#import "StripeSignupViewController.h"
#import "DSMappingProvider.h"
#import "FEMMapping.h"
#import "FEMDeserializer.h"
#import "SignInViewController.h"
#import "WebViewController.h"
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVAssetImageGenerator.h"
#import "MediaFile.h"


@import ALCameraViewController;

@interface UploadViewController() <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AuthViewDelegate>
{
    UIImagePickerController         *imagePicker;
    MediaFile                       *mediaFile;
}

@property (nonatomic, strong) AuthView                  *viSignInFB;
@property (weak, nonatomic) IBOutlet UIImageView        *ivCheck;
@property (weak, nonatomic) IBOutlet UIImageView        *ivPhoto;
@property (weak, nonatomic) IBOutlet UIImageView        *ivAddPhoto;
           
@property (weak, nonatomic) IBOutlet UILabel            *lbDescriptionLength;
@property (weak, nonatomic) IBOutlet UITextView         *tvDescription;
//@property (weak, nonatomic) IBOutlet UILabel            *lbDescriptionPlaceHolder;
@property (weak, nonatomic) IBOutlet UIView             *viPrice;
@property (weak, nonatomic) IBOutlet UITextField        *tfPrice;
@property (weak, nonatomic) IBOutlet UIToolbar          *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *btDone;
@property (weak, nonatomic) IBOutlet UIButton           *btPost;

@property (weak, nonatomic) IBOutlet UIScrollView       *scMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintScrollHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPhotoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContentTop;
@property (weak, nonatomic) IBOutlet UISwitch *switchRecurring;

@property (weak, nonatomic) IBOutlet UILabel *lbCountry;


@end


@implementation UploadViewController
@synthesize viSignInFB;
@synthesize ivCheck;
@synthesize ivPhoto;
@synthesize ivAddPhoto;
@synthesize lbDescriptionLength;
@synthesize tvDescription;
//@synthesize lbDescriptionPlaceHolder;
@synthesize tfPrice;
@synthesize viPrice;
@synthesize scMain;
@synthesize toolBar;
@synthesize btDone;
@synthesize btPost;
@synthesize objFeed;
@synthesize constraintScrollHeight;
@synthesize constraintPhotoHeight;
@synthesize constraintContentTop;
@synthesize isUpdateMode;

- (void) initMember
{
    [super initMember];
    
    mediaFile = [[MediaFile alloc] init];
    
    tvDescription.inputAccessoryView = toolBar;
    tfPrice.inputAccessoryView = toolBar;
    
    ivPhoto.layer.masksToBounds = YES;
    ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
    
    UIFont *font = [UIFont systemFontOfSize:22];
    NSString *dollarSignText = @"$";
    CGSize size = [dollarSignText sizeWithAttributes:@{NSFontAttributeName: font}];
    UILabel *dollarSignLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ceilf(size.width) + 10, tfPrice.frame.size.height)];
    dollarSignLabel.font = font;
    dollarSignLabel.text = dollarSignText;
    dollarSignLabel.textAlignment = NSTextAlignmentRight;
    dollarSignLabel.textColor = [UIColor colorWithRed: 71.0/255.0 green: 71.0/255.0 blue: 73.0/255.0 alpha: 1.0];
    tfPrice.leftView = dollarSignLabel;
    tfPrice.leftViewMode = UITextFieldViewModeAlways;
    
    [self initAuthUI];
    
    btPost.layer.masksToBounds = YES;
    btPost.layer.cornerRadius = 20.0;
    
    viPrice.layer.borderColor = COLOR_MAIN.CGColor;
    viPrice.layer.borderWidth = 1.0;
    viPrice.layer.cornerRadius = 20.0;
    
    ivCheck.hidden = YES;
    
    
    _BtnUpdateProject.layer.masksToBounds = YES;
    _BtnUpdateProject.layer.cornerRadius = 20.0;
    if (isUpdateMode==TRUE)
    {
        _BtnUpdateProject.hidden=false;
        btPost.hidden=TRUE;
        ivCheck.hidden=TRUE;
        ivCheck.alpha=0.0;
        [self setInformationOfProject];
    }
    else
    {
        _BtnUpdateProject.hidden=TRUE;
        _btnCancel.hidden=TRUE;
        btPost.hidden=FALSE;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.scMain.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+50);
}

-(IBAction)BackButtonPress:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}
//--------Amit
-(void)setInformationOfProject
{
    [ivPhoto sd_setImageWithURL: [NSURL URLWithString: objFeed.getProjectImage]];
    tvDescription.text=objFeed.feed_description;
    tfPrice.text=[NSString stringWithFormat:@"%d",objFeed.pre_amount/100];
    if(objFeed.gift_type != nil && [objFeed.gift_type isEqualToString:FEED_TYPE_MONTHLY] ){
        _switchRecurring.on = YES;
    }else{
        _switchRecurring.on = NO;
    }
    
    if(objFeed.donated_user_count>0){
        _switchRecurring.enabled = NO;
    }else{
        _switchRecurring.enabled = YES;
    }
}
- (IBAction)UpdateButtonPress:(UIButton *)sender
{
    [self hideKeyboard];
    
    NSString* feedDescription = tvDescription.text;
    int amount = [tfPrice.text intValue];
    
    //Check Max count today.
    NSDate *date = [NSDate date];
    int count = [[CoreHelper sharedInstance] getHistoryCountPerDay: date];
    if(count > MAX_POST_COUNT_DAY)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_MAX_POST_PROJECT] animated: YES completion: nil];
        return;
    }

    if(feedDescription == nil || [feedDescription length] == 0)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_DESCRIPTION] animated: YES completion: nil];
        return;
    }
    
    if(amount < MIN_PRICE || amount > MAX_PRICE)
    {
        [self presentViewController: [AppEngine showAlertWithText: [NSString stringWithFormat: @"Enter any price from $%d ~ $%d", MIN_PRICE, MAX_PRICE]] animated: YES completion: nil];
        return;
    }
    
//    if([AppEngine sharedInstance].currentUser == nil)
//    {
//        [self showSignupPage];
//        return;
//    }
    
    /*
    if ([self isUserConfiguredStripeAccount]) {
        //[self postFeed: imgPhoto description: feedDescription amount: amount];
        
    }*/
    [self UpdateMypostedFeed:feedDescription amount:amount];
}

- (IBAction)CancelButtonPress:(UIButton *)sender{
    //[self dismissViewControllerAnimated:TRUE completion:nil];
    [self.navigationController popViewControllerAnimated:TRUE];
}
//--------------------------------------
//--------------------------------------
- (void) clearContent
{
    ivCheck.hidden = YES;
    ivPhoto.image = nil;
    tvDescription.text = @"";
    tfPrice.text = @"";
    ivAddPhoto.hidden = NO;
    
//    constraintScrollHeight.constant = 525.0;
//    constraintPhotoHeight.constant = 185.0;
 //   constraintContentTop.constant = 185.0;
//    [self.view layoutIfNeeded];
}

- (void) captureImage: (UIImage*) image
{
    [self clearContent];
    ivPhoto.image = image;
}

- (IBAction) actionInfo:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil message: MSG_INFO_AMOUNT preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction: okAction];
    
    UIAlertAction* learnMoreAction = [UIAlertAction actionWithTitle: @"Learn More" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"ShowFAQ" sender:self];
    }];
    [alert addAction: learnMoreAction];
    
    
    [self presentViewController: alert animated: YES completion: nil];
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
    if([AppEngine sharedInstance].currentUser != nil)
    {
        [self successAuth];
    }
}

- (IBAction)actionPost:(id)sender
{
    [self hideKeyboard];

    UIImage* imgPhoto = ivPhoto.image;
    NSString* feedDescription = tvDescription.text;
    int amount = [tfPrice.text intValue];
    
    //Check Max count today.
    NSDate *date = [NSDate date];
    int count = [[CoreHelper sharedInstance] getHistoryCountPerDay: date];
    if(count > MAX_POST_COUNT_DAY)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_MAX_POST_PROJECT] animated: YES completion: nil];
        return;
    }
    
    
    if(imgPhoto == nil)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_PHOTO] animated: YES completion: nil];
        return;
    }
    
    if(feedDescription == nil || [feedDescription length] == 0)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_DESCRIPTION] animated: YES completion: nil];
        return;
    }
    
    if(amount < MIN_PRICE || amount > MAX_PRICE)
    {
        [self presentViewController: [AppEngine showAlertWithText: [NSString stringWithFormat: @"Enter any price from $%d ~ $%d", MIN_PRICE, MAX_PRICE]] animated: YES completion: nil];
        return;
    }
    
    if([AppEngine sharedInstance].currentUser == nil)
    {
        [self showSignupPage];
        return;
    }
    
    if ([self isUserConfiguredStripeAccount]) {
        [self postFeed: feedDescription amount: amount];
    }
    
}

- (void) postFeed: (NSString*) description amount: (int) amount
{
    [SVProgressHUD showWithStatus: @"Uploading..." maskType: SVProgressHUDMaskTypeClear];
    
    if(mediaFile.mediaType == VIDEO){
        NSURL * mediaURL = [NSURL URLWithString:[mediaFile.mediaURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData *videoData = [NSData dataWithContentsOfFile:[mediaURL path]];
        [[NetworkClient sharedClient] uploadVideo: videoData success:^(NSDictionary *photoInfo) {
            [SVProgressHUD dismiss];
            if ([photoInfo objectForKey:@"secure_url"]) {
                NSString *gift_type = [self getFeedType];
                NSString *secureUrl = [photoInfo objectForKey:@"secure_url"];
                
                [self makePostFeedRequest : description
                                   amount : amount
                                secureURL : secureUrl
                                gift_type : gift_type];
                
            }
            
        } failure:^(NSString *errorMessage) {
            [SVProgressHUD dismiss];
        }];
    }else{
        
         NSData* imgData = UIImageJPEGRepresentation(ivPhoto.image, IMAGE_COMPRESSION);
        
        [[NetworkClient sharedClient] uploadImage:imgData success:^(NSDictionary *photoInfo) {
            [SVProgressHUD dismiss];
            if ([photoInfo objectForKey:@"secure_url"]) {
                NSString *gift_type = [self getFeedType];
                NSString *secureUrl = [photoInfo objectForKey:@"secure_url"];
                
                [self makePostFeedRequest : description
                                   amount : amount
                                secureURL : secureUrl
                                gift_type : gift_type];
                
            }
            
        } failure:^(NSString *errorMessage) {
            [SVProgressHUD dismiss];
        }];

    }
}

- (void) makePostFeedRequest:
                 (NSString*) description
                      amount: (int) amount
                   secureURL: (NSString*) secureUrl
                   gift_type: (NSString*) gift_type {
    
    mediaFile.mediaURL = secureUrl;
    
    [[NetworkClient sharedClient] postFeed: mediaFile
                               description: description
                                    amount: amount
                                   user_id: [AppEngine sharedInstance].currentUser.user_id
                                 feed_type: gift_type
                                   success:^(NSDictionary *dicFeed, NSDictionary* dicUser) {
                                       
                                       [SVProgressHUD dismiss];
                                       
                                       //Refresh Feeds.
                                       HomeViewController* homeView = [self.tabBarController.viewControllers firstObject];
                                       [homeView refreshFeeds];
                                       self.tabBarController.selectedIndex = 0;
                                       
                                       //Refresh Profile's Upload.
                                       ProfileViewController* profileView = [self.tabBarController.viewControllers objectAtIndex: 3];
                                       [profileView loadMyFeeds];
                                       
                                       //Add Post history.
                                       [[CoreHelper sharedInstance] addPostHistory: [AppEngine sharedInstance].currentUser.user_id
                                                                         post_date: [NSDate date]];
                                       [self clearContent];
                                       
                                   } failure:^(NSString *errorMessage) {
                                       
                                       [SVProgressHUD dismiss];
                                       [self presentViewController: [AppEngine showErrorWithText: errorMessage]
                                                          animated: YES
                                                        completion: nil];
                                   }];

}

- (NSString*) getFeedType
{
    if(_switchRecurring.isOn){
        return FEED_TYPE_MONTHLY;
    }else{
        return FEED_TYPE_DEFAULT;
    }
}

- (void) UpdateMypostedFeed: (NSString*) text amount: (int) amount
{
    [SVProgressHUD showWithStatus: @"Updating..." maskType: SVProgressHUDMaskTypeClear];
    
    NSString* newFeedType = [self getFeedType];
    NSString* oldFeedType = objFeed.getFeedType;
    
    if([newFeedType isEqualToString:oldFeedType]){
        newFeedType = nil;
    }

    if(mediaFile.mediaURL != nil){
        if(mediaFile.mediaType == VIDEO){
            NSURL * mediaURL = [NSURL URLWithString:[mediaFile.mediaURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSData *videoData = [NSData dataWithContentsOfFile:[mediaURL path]];
            [[NetworkClient sharedClient] uploadVideo: videoData success:^(NSDictionary *photoInfo) {
                [SVProgressHUD dismiss];
                if ([photoInfo objectForKey:@"secure_url"]) {
                    mediaFile.mediaURL = [photoInfo objectForKey:@"secure_url"];
                    [self makeUpdateFeedRequest:text amount:amount gift_type:newFeedType];
                }
                
            } failure:^(NSString *errorMessage) {
                [SVProgressHUD dismiss];
            }];

        } else {
            NSData* imgData = UIImageJPEGRepresentation(ivPhoto.image, IMAGE_COMPRESSION);
            [[NetworkClient sharedClient] uploadImage:imgData success:^(NSDictionary *photoInfo) {
                [SVProgressHUD dismiss];
                if ([photoInfo objectForKey:@"secure_url"]) {
                    mediaFile.mediaURL = [photoInfo objectForKey:@"secure_url"];
                    [self makeUpdateFeedRequest:text amount:amount gift_type:newFeedType];
                }
                
            } failure:^(NSString *errorMessage) {
                [SVProgressHUD dismiss];
            }];
        }
    } else {
        [self makeUpdateFeedRequest:text amount:amount gift_type:newFeedType];
    }
    
}

- (void) makeUpdateFeedRequest: (NSString*) description
                        amount: (int) amount
                   gift_type: (NSString*) gift_type {
    [[NetworkClient sharedClient] UpdatepostFeed:mediaFile
                                     description:description amount:amount
                                         user_id:[AppEngine sharedInstance].currentUser.user_id
                                       gift_type: gift_type
                                         success:^(NSDictionary *dicFeed, NSDictionary *dicUser) {
                                             [SVProgressHUD dismiss];
                                             
                                             [self CancelButtonPress:nil];
                                         } failure:^(NSString *errorMessage) {
                                             [SVProgressHUD dismiss];
                                             [self presentViewController: [AppEngine showErrorWithText: errorMessage]
                                                                animated: YES
                                                              completion: nil];
                                         }];
}

- (void) hideKeyboard
{
    [tfPrice resignFirstResponder];
    [tvDescription resignFirstResponder];
}

- (IBAction) actionInputDone:(id)sender
{
    [self hideKeyboard];
}

- (BOOL) isUserConfiguredStripeAccount {
    
    User *u = [AppEngine sharedInstance].currentUser;
    if (!u.can_receive_gifts) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Stripe" message: @"To publish new post in DonorSee you need to sign in for a Stripe account initially. The donations will be received under your stripe account." preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString *path = [NSString stringWithFormat:@"%@stripe-connect/auth?id=%i",kAPIBaseURLString, [AppEngine sharedInstance].currentUser.user_id];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            StripeSignupViewController *stripeWebView = [storyboard instantiateViewControllerWithIdentifier: @"stripeSignup"];
            stripeWebView.webUrl = path;
            
            stripeWebView.didDismiss = ^(NSString *data) {
                [self successAuth];
            };
            
            [self presentViewController:stripeWebView animated:YES completion:nil];
            
        }];
        
        [alert addAction: okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - Auth.

- (void) initAuthUI
{
    CGRect rect = CGRectMake(0, TOP_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOP_BAR_HEIGHT - TAB_BAR_HEIGHT);
//    viSignInFB = [[AuthView alloc] initAuthView: rect isAskingPaypal: YES parentView: self delegate: self];
    viSignInFB = [[AuthView alloc] initAuthView: rect parentView: self delegate: self];    
    viSignInFB.hidden = YES;
    [self.view addSubview: viSignInFB];
    
    if([AppEngine sharedInstance].currentUser) return;
    
    [[NetworkClient sharedClient] getUserInfo: [AppEngine sharedInstance].currentUser.user_id
                                      success:^(NSDictionary *dicUser) {
                                          FEMMapping *userMapping = [DSMappingProvider userMapping];
                                          User *u = [FEMDeserializer objectFromRepresentation:dicUser mapping:userMapping];
                                          [[CoreHelper sharedInstance] addUser: u];
                                          [AppEngine sharedInstance].currentUser = u;
                                          
                                      } failure:^(NSString *errorMessage) {
                                          
                                      }];
}

- (void) successAuth
{
    
    [[NetworkClient sharedClient] getUserInfo: [AppEngine sharedInstance].currentUser.user_id
                                      success:^(NSDictionary *dicUser) {
                                          FEMMapping *userMapping = [DSMappingProvider userMapping];
                                          User *u = [FEMDeserializer objectFromRepresentation:dicUser mapping:userMapping];
                                          [[CoreHelper sharedInstance] addUser: u];
                                          [AppEngine sharedInstance].currentUser = u;
                                          
                                          if (u.can_receive_gifts) {
                                              viSignInFB.hidden = YES;
                                              UIImage* imgPhoto = ivPhoto.image;
                                              NSString* feedDescription = tvDescription.text;
                                              int amount = [tfPrice.text intValue];
                                              
                                              [self postFeed: feedDescription amount: amount];
                                          } else {
                                              [self presentViewController: [AppEngine showAlertWithText: @"Stripe account is not connected. Try again."] animated: YES completion: nil];
                                          }
                                          
                                          
                                      } failure:^(NSString *errorMessage) {
                                          
                                      }];
                                          
                                          
    
}

- (void) failAuth
{
    viSignInFB.hidden = YES;
}

#pragma mark -
#pragma mark UITextField Delegate.

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [self checkDoneButton: textView.text];
    [self updateDescriptionPlaceHolder];
    
    if(IS_IPHONE_4_OR_LESS)
    {
        [scMain setContentOffset: CGPointMake(0, 235) animated: YES];
    }
    else
    {
        [scMain setContentOffset: CGPointMake(0, 205) animated: YES];
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    [self checkDoneButton: textView.text];
    [self updateDescriptionPlaceHolder];
    [scMain setContentOffset: CGPointZero animated: YES];
}

- (void) textViewDidChange:(UITextView *)textView
{
    [self checkDoneButton: textView.text];
    int count = MAX_DESCRIPTION_LENGTH - (int)[tvDescription.text length];
    if(count < 0)
    {
        count = 0;
    }
    
    lbDescriptionLength.text = [NSString stringWithFormat: @"%d/%d", count, MAX_DESCRIPTION_LENGTH];
    [self updateDescriptionPlaceHolder];
}

- (void) updateDescriptionPlaceHolder
{
//    if([tvDescription.text length] > 0)
//    {
//        lbDescriptionPlaceHolder.hidden = YES;
//    }
//    else
//    {
//        lbDescriptionPlaceHolder.hidden = NO;
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        //[textView resignFirstResponder];
        return NO;
    }
    
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= MAX_DESCRIPTION_LENGTH)
    {
        return YES;
    } else {
        NSUInteger emptySpace = MAX_DESCRIPTION_LENGTH - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
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
    
    [self checkValid];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self checkDoneButton: textField.text];
    [scMain setContentOffset: CGPointMake(0, 300) animated: YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self checkDoneButton: textField.text];
    [scMain setContentOffset: CGPointZero animated: YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == tfPrice)
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
        
        NSString *editedString = [tfPrice.text stringByReplacingCharactersInRange:range withString:string];
        NSInteger editedStringValue = editedString.integerValue;
        BOOL result = editedStringValue <= MAX_PRICE;
        
        [self checkDoneButton: [NSString stringWithFormat: @"%@%@", textField.text, string]];
        return result;
    }
    
    return YES;
}

- (void) checkValid
{
    BOOL isValid = YES;
    
    if(ivPhoto.image == nil)
    {
        isValid = NO;        
    }
    else
    {
//        constraintContentTop.constant = self.view.frame.size.width;
//       // constraintPhotoHeight.constant = self.view.frame.size.width;
//        constraintScrollHeight.constant = 700;
//        [self.view layoutIfNeeded];
    }
    
    if(tfPrice.text == nil || [tfPrice.text length] == 0) isValid = NO;
    if(tvDescription.text == nil || [tvDescription.text length] == 0) isValid = NO;
    
    ivCheck.hidden = !isValid;
}

#pragma mark - Image.

- (IBAction) actionAddPhoto:(id)sender
{
    [self hideKeyboard];
    
    if(TEST_FLAG)
    {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
        return;
    }
   
    [self showMediaPickerDialog];
}

- (void) showMediaPickerDialog{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil
                                                                   message: nil
                                                            preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction* actionCamera = [UIAlertAction actionWithTitle: @"Camera"
                                                           style: UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             mediaFile.mediaType = PICTURE;
                                                             [self takePicture];
                                                         }];
    [alert addAction: actionCamera];
    
    UIAlertAction* actionUploadFromGallery = [UIAlertAction actionWithTitle: @"Upload photo from gallery"
                                                                      style: UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                                        mediaFile.mediaType = PICTURE;
                                                                        [self choosePhotoFileFromGallery];
                                                                    }];
    [alert addAction: actionUploadFromGallery];
    
    UIAlertAction* actionUploadVideoFromGallery = [UIAlertAction actionWithTitle:@"Upload video from gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        mediaFile.mediaType = VIDEO;
        [self chooseVideoFile];
    }];
    
    [alert addAction:actionUploadVideoFromGallery];
    
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle: @"Cancel"
                                                           style: UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    [alert addAction: actionCancel];
    [self presentViewController: alert animated: YES completion: nil];
}

- (void) takePicture{
    CameraViewController* cameraController = [[CameraViewController alloc] initWithCroppingEnabled: YES
                                                                               allowsLibraryAccess: YES
                                                                                        completion:^(UIImage * image, PHAsset * asset) {
                                                                                            
                                                                                            if(image != nil)
                                                                                            {
                                                                                                NSURL* url = [[NSURL alloc] initWithString:@""];
                                                                                                    [self onMediaPicked : url uiImage:image];
                                                                                            }
                                                                                            
                                                                                            [self dismissViewControllerAnimated: YES completion: nil];
                                                                                        }];
    [self presentViewController: cameraController animated: YES completion: nil];
}

- (void) choosePhotoFileFromGallery{
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void) chooseVideoFile{
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    videoPicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:videoPicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
     NSURL* mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
     [self onMediaPicked : mediaUrl uiImage:info[UIImagePickerControllerOriginalImage]];
    
     [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) onMediaPicked: (NSURL *) mediaUrl uiImage:(UIImage*) image {
    ivAddPhoto.hidden = YES;
    
    if(mediaFile.mediaType == VIDEO){
        mediaFile.mediaURL = mediaUrl.absoluteString;
        UIImage *videoThumbnail = [self getThumbnailFromVideo: mediaUrl];
        ivPhoto.image = videoThumbnail;
    }else{
        mediaFile.mediaURL = @"";
        UIImage *chosenImage = image;
        ivPhoto.image = chosenImage;
    }
    

    [self checkValid];

}

- (UIImage*) getThumbnailFromVideo: (NSURL *) mediaUrl{
    AVAsset *asset = [AVAsset assetWithURL: mediaUrl];
    
    // Calculate a time for the snapshot - I'm using the half way mark.
    CMTime duration = [asset duration];
    CMTime snapshot = CMTimeMake(duration.value / 2, duration.timescale);
    
    // Create a generator and copy image at the time.
    // I'm not capturing the actual time or an error.
    AVAssetImageGenerator *generator =
    [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CGImageRef imageRef = [generator copyCGImageAtTime:snapshot
                                            actualTime:nil
                                                 error:nil];
    
   // CGImageRelease(imageRef);
    
    return [UIImage imageWithCGImage:imageRef];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowFAQ"]){
        if ([segue.destinationViewController isKindOfClass:[WebViewController class]]){
            WebViewController *controller = segue.destinationViewController;
            controller.urlString = @"https://donorsee.com/faq";
        }
    }
}

-(NSMutableArray *) getSortedCountryArray {
    
    NSLocale *locale = [NSLocale currentLocale];
    NSArray *countryArray = [NSLocale ISOCountryCodes];
    
    NSMutableArray *sortedCountryArray = [[NSMutableArray alloc] init];
    
    for (NSString *countryCode in countryArray) {
        
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        [sortedCountryArray addObject:displayNameString];
        
    }
    
    [sortedCountryArray sortUsingSelector:@selector(localizedCompare:)];
    
    return sortedCountryArray;
    
}

@end
