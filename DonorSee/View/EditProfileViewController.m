//
//  EditProfileViewController.m
//  DonorSee
//
//  Created by star on 4/12/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController                 *imagePicker;
    BOOL                                    isChangedAvatar;
    BOOL                                    isFBUser;
}

@property (nonatomic, weak) IBOutlet UIScrollView               *scMain;
@property (nonatomic, weak) IBOutlet UIImageView                *ivAvatar;
@property (nonatomic, weak) IBOutlet UITextField                *tfFirstName;
@property (nonatomic, weak) IBOutlet UITextField                *tfLastName;
@property (nonatomic, weak) IBOutlet UIView                     *viOldPassword;
@property (nonatomic, weak) IBOutlet UITextField                *tfOldPassword;
@property (nonatomic, weak) IBOutlet UIView                     *viNewPassword;
@property (nonatomic, weak) IBOutlet UITextField                *tfNewPassword;
@property (nonatomic, weak) IBOutlet UIImageView                *ivPasswordIcon;

@end

@implementation EditProfileViewController
@synthesize scMain;
@synthesize ivAvatar;
@synthesize tfFirstName;
@synthesize tfLastName;
@synthesize viOldPassword;
@synthesize tfNewPassword;
@synthesize viNewPassword;
@synthesize tfOldPassword;
@synthesize ivPasswordIcon;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    isChangedAvatar = NO;
    
    ivAvatar.layer.masksToBounds = YES;
    ivAvatar.layer.cornerRadius = ivAvatar.frame.size.width / 2.0;
    
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    [scMain addGestureRecognizer:tapScroll];
    
    //Fill Out Currrent Info.
    [ivAvatar sd_setImageWithURL: [NSURL URLWithString: [AppEngine sharedInstance].currentUser.avatar] placeholderImage: [UIImage imageNamed: DEFAULT_USER_IMAGE]];
    
    NSString* name = [AppEngine sharedInstance].currentUser.name;
    NSString* firstName = [AppEngine getFirstName: name];
    NSString* lastName = [AppEngine getLastName: name];
    
    tfFirstName.text = firstName;
    tfLastName.text = lastName;
    
    NSString* fb_id = [AppEngine sharedInstance].currentUser.fb_id;
    if(fb_id != nil && [fb_id length] > 0)
    {
        isFBUser = YES;
        
        viNewPassword.hidden = YES;
        viOldPassword.hidden = YES;
        ivPasswordIcon.hidden = YES;
        
        tfLastName.returnKeyType = UIReturnKeyDone;
    }
}

- (void) tapped
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    isChangedAvatar = YES;
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    ivAvatar.image = image;
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) hideKeyboard
{
    [tfFirstName resignFirstResponder];
    [tfLastName resignFirstResponder];
    [tfNewPassword resignFirstResponder];
    [tfOldPassword resignFirstResponder];
}

- (IBAction) actionSaveChanges:(id)sender
{
    [self hideKeyboard];
    
    NSString* firstName = tfFirstName.text;
    NSString* lastName = tfLastName.text;
    NSString* oldPassword = tfOldPassword.text;
    NSString* newPassword = tfNewPassword.text;
    
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
    
    if(!isFBUser)
    {
        if(oldPassword == nil || [oldPassword length] == 0)
        {
            [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_PASSWORD] animated: YES completion: nil];
            return;
        }
        
        if(newPassword == nil || [newPassword length] <= PASSWORD_MAX_LENGTH)
        {
            [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_PASSWORD] animated: YES completion: nil];
            return;
        }
    }
    
    if(isChangedAvatar)
    {
        UIImage* imgAvatar = ivAvatar.image;
        [SVProgressHUD showWithMaskType: SVProgressHUDMaskTypeClear];
        NSData* imgData = UIImageJPEGRepresentation(imgAvatar, IMAGE_COMPRESSION);
        [[JAmazonS3ClientManager defaultManager] uploadPostPhotoData: imgData
                                                             fileKey: [AppEngine getImageName]
                                                    withProcessBlock:^(float progress) {
                                                        
                                                    } completeBlock:^(NSString *imageURL) {
                                                        
                                                        NSLog(@"imageURL = %@", imageURL);
                                                        if(imageURL != nil)
                                                        {
                                                            [self updateProfile: [[JAmazonS3ClientManager defaultManager] getPathForPhoto: imageURL]];
                                                        }
                                                        else
                                                        {
                                                            [SVProgressHUD dismiss];
                                                        }
                                                    }];

    }
    else
    {
        [self updateProfile: nil];
    }
}

- (void) updateProfile: (NSString*) avatar
{
    NSString* firstName = tfFirstName.text;
    NSString* lastName = tfLastName.text;
    NSString* oldPassword = tfOldPassword.text;
    NSString* newPassword = tfNewPassword.text;
    
    if(avatar == nil)
    {
        [SVProgressHUD showWithStatus: @"Saving..." maskType: SVProgressHUDMaskTypeClear];
    }

    [[NetworkClient sharedClient] updateProfile: firstName
                                       lastName: lastName
                                    oldPassword: oldPassword
                                    newPassword: newPassword
                                         avatar: avatar
                                       isFBUser: isFBUser
                                        success:^(NSDictionary *dicUser) {
                                            
                                            [SVProgressHUD dismiss];
                                            
                                            User* u = [[User alloc] initUserWithDictionary: dicUser];
                                            
                                            [[CoreHelper sharedInstance] addUser: u];
                                            [[CoreHelper sharedInstance] setCurrentUserId: u.user_id];
                                            [AppEngine sharedInstance].currentUser = u;
                                            
                                            [self actionBack: nil];
                                            
                                        } failure:^(NSString *errorMessage) {
                                            
                                            [SVProgressHUD dismiss];
                                            [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                        }];
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
    else if(textField == tfOldPassword)
    {
        [scMain setContentOffset: CGPointMake(0, 120 + offset) animated: YES];
    }
    else if(textField == tfNewPassword)
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
        if(isFBUser)
        {
            [textField resignFirstResponder];
        }
        else
        {
            [tfOldPassword becomeFirstResponder];
        }
    }
    else if(textField == tfOldPassword)
    {
        [tfNewPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}


@end
