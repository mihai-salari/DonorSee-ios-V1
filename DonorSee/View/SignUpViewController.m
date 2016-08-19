//
//  SignUpViewController.m
//  DonorSee
//
//  Created by star on 4/8/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "SignUpViewController.h"
#import "FEMMapping.h"
#import "DSMappingProvider.h"
#import "FEMDeserializer.h"

@interface SignUpViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController             *imagePicker;
}

@property (nonatomic, weak) IBOutlet UIScrollView       *scMain;
@property (nonatomic, weak) IBOutlet UITextField        *tfFirstName;
@property (nonatomic, weak) IBOutlet UITextField        *tfLastName;
@property (nonatomic, weak) IBOutlet UITextField        *tfEmail;
@property (nonatomic, weak) IBOutlet UITextField        *tfPassword;
@property (nonatomic, weak) IBOutlet UIButton           *btSignUp;
@property (nonatomic, weak) IBOutlet UIView             *viUploadAvatar;
@property (nonatomic, weak) IBOutlet UIView             *viAvatarContainer;
@property (nonatomic, weak) IBOutlet UIButton           *btAvatar;
@property (nonatomic, weak) IBOutlet UIImageView        *ivProfilePic;
@property (nonatomic, weak) IBOutlet UIView             *viSkip;
@property (nonatomic, weak) IBOutlet UIView             *viContinue;
@property (nonatomic, weak) IBOutlet UIImageView        *ivAvatar;
@end

@implementation SignUpViewController
@synthesize scMain;
@synthesize tfFirstName;
@synthesize tfLastName;
@synthesize tfEmail;
@synthesize tfPassword;
@synthesize btSignUp;
@synthesize viUploadAvatar;
@synthesize viAvatarContainer;
@synthesize btAvatar;
@synthesize ivProfilePic;
@synthesize viSkip;
@synthesize viContinue;
@synthesize ivAvatar;

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
    
    btSignUp.layer.masksToBounds = YES;
    btSignUp.layer.cornerRadius = 20.0;
    btSignUp.layer.borderColor = [UIColor whiteColor].CGColor;
    btSignUp.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    [scMain addGestureRecognizer:tapScroll];
    
    [self initUploadAvatarUI];
}

- (void) tapped
{
    [self.view endEditing:YES];
}

- (IBAction) actionFBSignIn:(id)sender
{
    [self signInFB:^{
        [self gotoHomeView: YES];
    }];
}

- (IBAction) actionSignUp:(id)sender
{
    [self hideKeyboard];
    
    NSString* firstName = tfFirstName.text;
    NSString* lastName = tfLastName.text;
    NSString* email = tfEmail.text;
    NSString* password = tfPassword.text;
    
    if(firstName == nil || [firstName length] == 0)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_FIRST_NAME] animated: YES completion: nil];
        return;
    }
    
    if(lastName == nil || [lastName length] == 0)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_LAST_NAME] animated: YES completion: nil];
        return;
    }

    if(email == nil || [email length] == 0 || ![AppEngine emailValidate: email])
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_EMAIL] animated: YES completion: nil];
        return;
    }

    if(password == nil || [password length] <= PASSWORD_MAX_LENGTH)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_PASSWORD] animated: YES completion: nil];
        return;
    }
    
    viUploadAvatar.hidden = NO;
}

- (IBAction) actionBackAvatar:(id)sender
{
    if(viContinue.hidden)
    {
        viUploadAvatar.hidden = YES;
    }
    else
    {
        viContinue.hidden = YES;
        viSkip.hidden = NO;
        ivAvatar.image = [UIImage imageNamed: @""];
        ivProfilePic.hidden = NO;
    }
}

- (IBAction) actionSkip:(id)sender
{
    [self signUp: @""];
}

- (IBAction) actionContinue:(id)sender
{
    viUploadAvatar.hidden = YES;
    UIImage* imgAvatar = ivAvatar.image;
    
    if(imgAvatar != nil)
    {
        [SVProgressHUD showWithStatus: @"Sign up..." maskType: SVProgressHUDMaskTypeClear];
        NSData* imgData = UIImageJPEGRepresentation(imgAvatar, IMAGE_COMPRESSION);
        [[JAmazonS3ClientManager defaultManager] uploadPostPhotoData: imgData
                                                             fileKey: [AppEngine getImageName]
                                                    withProcessBlock:^(float progress) {
                                                        
                                                    } completeBlock:^(NSString *imageURL) {
                                                        
                                                        NSLog(@"imageURL = %@", imageURL);
                                                        if(imageURL != nil)
                                                        {
                                                            [self signUp: [[JAmazonS3ClientManager defaultManager] getPathForPhoto: imageURL]];
                                                        }
                                                        else
                                                        {
                                                            [SVProgressHUD dismiss];
                                                        }
                                                    }];
    }
    else
    {
        [self signUp: @""];
    }
}

- (void) signUp: (NSString*) avatar
{
    NSString* firstName = tfFirstName.text;
    NSString* lastName = tfLastName.text;
    NSString* email = tfEmail.text;
    NSString* password = tfPassword.text;
    
    if(avatar == nil || [avatar length] == 0)
    {
        [SVProgressHUD showWithStatus: @"Sign up..." maskType: SVProgressHUDMaskTypeClear];
    }

    [[NetworkClient sharedClient] signUp: firstName
                               last_name: lastName
                                   email: email
                                password: password
                                  avatar: avatar
                                 success:^(NSDictionary *dicUser) {
                                     
                                     [SVProgressHUD dismiss];
                                     
                                     FEMMapping *mapping = [DSMappingProvider userMapping];
                                     User *u = [FEMDeserializer objectFromRepresentation:dicUser mapping:mapping];
                                     
                                     [[CoreHelper sharedInstance] addUser: u];
                                     [[CoreHelper sharedInstance] setCurrentUserId: u.user_id];
                                     [AppEngine sharedInstance].currentUser = u;
                                     
                                     [self gotoHomeView: YES];
                                     
                                 } failure:^(NSString *errorMessage) {
                                     [SVProgressHUD dismiss];
                                     [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                 }];
}

- (void) hideKeyboard
{
    [tfFirstName resignFirstResponder];
    [tfLastName resignFirstResponder];
    [tfEmail resignFirstResponder];
    [tfPassword resignFirstResponder];
}

#pragma mark - UITextField Delegate.

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    float offset = 0;
    if(IS_IPHONE_5)
    {
        offset = 70;
    }
    else if(IS_IPHONE_4_OR_LESS)
    {
        offset = 150;
    }
    
    if(textField == tfFirstName)
    {
        [scMain setContentOffset: CGPointMake(0, 40 + offset) animated: YES];
    }
    else if(textField == tfLastName)
    {
        [scMain setContentOffset: CGPointMake(0, 80 + offset) animated: YES];
    }
    else if(textField == tfEmail)
    {
        [scMain setContentOffset: CGPointMake(0, 120 + offset) animated: YES];
    }
    else if(textField == tfPassword)
    {
        [scMain setContentOffset: CGPointMake(0, 160 + offset) animated: YES];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [scMain setContentOffset: CGPointZero animated: YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == tfFirstName)
    {
        [tfLastName becomeFirstResponder];
    }
    else if(textField == tfLastName)
    {
        [tfEmail becomeFirstResponder];
    }
    else if(textField == tfEmail)
    {
        [tfPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Upload Avatar.

- (void) initUploadAvatarUI
{
    ivAvatar.layer.masksToBounds = YES;
    ivAvatar.layer.cornerRadius = ivAvatar.frame.size.width / 2.0;
    
    btAvatar.layer.masksToBounds = YES;
    btAvatar.layer.cornerRadius = btAvatar.frame.size.width / 2.0;
    
    viAvatarContainer.layer.masksToBounds = YES;
    viAvatarContainer.layer.cornerRadius = 15.0;
    
    viUploadAvatar.frame = self.view.bounds;
    [self.view addSubview: viUploadAvatar];
    
    viUploadAvatar.hidden = YES;
}

- (IBAction) actionAvatar:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil message: nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction* takePhoto = [UIAlertAction actionWithTitle: @"Take Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                {
                                    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
                                    {
                                        imagePicker = [[UIImagePickerController alloc] init];
                                        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                        imagePicker.allowsEditing = YES;
                                        imagePicker.delegate = self;
                                        [self presentViewController:imagePicker animated:YES completion:nil];
                                    }
                                }];
    
    UIAlertAction* loadFromGallery = [UIAlertAction actionWithTitle: @"Load from Gallery" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                      {
                                          if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
                                          {
                                              imagePicker = [[UIImagePickerController alloc] init];
                                              imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                              imagePicker.allowsEditing = YES;
                                              imagePicker.delegate = self;
                                              [self presentViewController:imagePicker animated:YES completion:nil];
                                          }
                                      }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction: takePhoto];
    [alert addAction: loadFromGallery];
    [alert addAction: cancel];
    
    [self presentViewController: alert animated: YES completion: nil];

}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    ivProfilePic.hidden = YES;
    ivAvatar.image = image;
    viSkip.hidden = YES;
    viContinue.hidden = NO;
    
    [self dismissViewControllerAnimated: YES completion: nil];
}


@end
