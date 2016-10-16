//
//  FollowUpViewController.m
//  DonorSee
//
//  Created by Bogdan on 10/15/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "FollowUpViewController.h"
#import "PhotoCellView.h"

@import ALCameraViewController;

@interface FollowUpViewController ()
{
    NSMutableArray              *arrFollowPhotos;
    UIImagePickerController     *imagePicker;
    int                         selectedPhotoIndex;
    
    NSMutableArray              *arrUploadedPhotos;
    int                         uploadingPhotoIndex;
}
@property (weak, nonatomic) IBOutlet UIView *vBackground;
@property (weak, nonatomic) IBOutlet UIButton *btFollowUp;
@property (weak, nonatomic) IBOutlet UIView *viPost;
@property (weak, nonatomic) IBOutlet UIView *vFrame;
@property (weak, nonatomic) IBOutlet UIView *viMessage;
@property (weak, nonatomic) IBOutlet UITextField *tfMessage;
@property (weak, nonatomic) IBOutlet UIScrollView *scPostPhotos;

@end

@implementation FollowUpViewController

@synthesize vBackground;
@synthesize btFollowUp;
@synthesize selectedFeed;
@synthesize viPost;
@synthesize vFrame;
@synthesize viMessage;
@synthesize tfMessage;
@synthesize scPostPhotos;

- (void) viewDidLoad{
    [super viewDidLoad];
    arrFollowPhotos = [[NSMutableArray alloc] init];
    arrUploadedPhotos = [[NSMutableArray alloc] init];
    
    selectedPhotoIndex = -1;
    
    UITapGestureRecognizer *gestureBackgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground:)];
    gestureBackgroundTap.delegate = self;
    [vBackground addGestureRecognizer:gestureBackgroundTap];
    
    
    [self initUI];
}

- (void) onTapBackground :(UITapGestureRecognizer *)gr{
    [self finish];
}

- (IBAction)actionFollowUp:(id)sender {
    
    NSString* message = tfMessage.text;
    if(message == nil || [message length] == 0)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_MESSAGE] animated: YES completion: nil];
        return;
    }
    
    [SVProgressHUD showWithStatus: @"Posting..." maskType: SVProgressHUDMaskTypeClear];
    
    if([self isFollowUp]){
        
        if([arrFollowPhotos count] > 0) {
            [self uploadFollowUpWithMedia];
        } else {
            [self postFollowMessage];
        }
        
    }else{
        [self postCommentMessage];
    }
}

- (BOOL) isFollowUp{
    return [selectedFeed isCreatedByCurrentUser];
}

- (void) initUI
{
    btFollowUp.layer.masksToBounds = YES;
    btFollowUp.layer.borderColor = COLOR_MAIN.CGColor;
    btFollowUp.layer.borderWidth = 1.0;
    btFollowUp.layer.cornerRadius = 20.0;
    
    viMessage.layer.masksToBounds = YES;
    viMessage.layer.borderColor = COLOR_FEED_TEXT.CGColor;
    viMessage.layer.borderWidth = 1.0;
    viMessage.layer.cornerRadius = 10.0;
    
    [tfMessage becomeFirstResponder];
    
    if([self isFollowUp]) {
        [btFollowUp setTitle: @"POST" forState: UIControlStateNormal];
        scPostPhotos.hidden = NO;
        [self updateFollowPhotos];
    } else {
        scPostPhotos.hidden = YES;
        [btFollowUp setTitle:@"POST COMMENT" forState:UIControlStateNormal];
    }
}

- (void) uploadFollowUpWithMedia
{
    uploadingPhotoIndex = 0;
    [self uploadSinglePhoto];
}

- (void) uploadSinglePhoto
{
    UIImage* image = [arrFollowPhotos objectAtIndex: uploadingPhotoIndex];
    NSData* imgData = UIImageJPEGRepresentation(image, IMAGE_COMPRESSION);
    
    
    [[NetworkClient sharedClient] uploadImage:imgData success:^(NSDictionary *photoInfo) {
        
        if ([photoInfo objectForKey:@"secure_url"]) {
            NSString *secure_url = [photoInfo objectForKey:@"secure_url"];
            
            [arrUploadedPhotos addObject: secure_url];
            uploadingPhotoIndex ++;
            
            if(uploadingPhotoIndex >= [arrFollowPhotos count])
            {
                [self postFollowMessage];
            }
            else
            {
                [self uploadSinglePhoto];
            }
            
        }else
        {
            [SVProgressHUD dismiss];
            [self presentViewController: [AppEngine showErrorWithText: MSG_ERROR_UPLOADING_IMAGE] animated: YES completion: nil];
        }
        
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD dismiss];
    }];
}

- (void) updateFollowPhotos
{
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    for(UIView* view in scPostPhotos.subviews)
    {
        [view removeFromSuperview];
    }
    
    float fx = 20;
    float fy = 20;
    float fw = 84;
    float fh = 84;
    float offset = 20;
    
    int index = 0;
    for(UIImage* imgPhoto in arrFollowPhotos)
    {
        PhotoCellView* cell = [[PhotoCellView alloc] initWithImage: CGRectMake(fx, fy, fw, fh) image: imgPhoto];
        cell.delegate = self;
        cell.tag = index;
        [scPostPhotos addSubview: cell];
        
        fx += offset + fw;
        index ++;
    }
    
    PhotoCellView* cell = [[PhotoCellView alloc] initWithAddCell: CGRectMake(fx, fy, fw, fh)];
    cell.delegate = self;
    [scPostPhotos addSubview: cell];
    fx += fw + offset;
    
    [scPostPhotos setContentSize: CGSizeMake(fx, scPostPhotos.contentSize.height)];
}

- (void) addPhoto
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
    
    CameraViewController* cameraController = [[CameraViewController alloc] initWithCroppingEnabled: YES
                                                                               allowsLibraryAccess: YES
                                                                                        completion:^(UIImage * image, PHAsset * asset) {
                                                                                            
                                                                                            if(image != nil)
                                                                                            {
                                                                                                [arrFollowPhotos addObject: image];
                                                                                                [self updateFollowPhotos];
                                                                                            }
                                                                                            
                                                                                            [self dismissViewControllerAnimated: YES completion: nil];
                                                                                        }];
    
    [self presentViewController: cameraController animated: YES completion: nil];
}

- (void) updatePhoto:(int)index
{
    if(TEST_FLAG)
    {
        selectedPhotoIndex = index;
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
        return;
    }
    
    CameraViewController* cameraController = [[CameraViewController alloc] initWithCroppingEnabled: YES
                                                                               allowsLibraryAccess: YES
                                                                                        completion:^(UIImage * image, PHAsset * asset) {
                                                                                            
                                                                                            if(image != nil)
                                                                                            {
                                                                                                [arrFollowPhotos replaceObjectAtIndex: index withObject: image];
                                                                                                [self updateFollowPhotos];
                                                                                            }
                                                                                            
                                                                                            [self dismissViewControllerAnimated: YES completion: nil];
                                                                                        }];
    [self presentViewController: cameraController animated: YES completion: nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    selectedPhotoIndex = -1;
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if(selectedPhotoIndex >= 0)
    {
        [arrFollowPhotos replaceObjectAtIndex: selectedPhotoIndex withObject: image];
        selectedPhotoIndex = -1;
    }
    else
    {
        [arrFollowPhotos addObject: image];
    }
    
    [self updateFollowPhotos];
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) postFollowMessage
{
    [self hideKeyboard];
    
    NSString* message = tfMessage.text;
    [[NetworkClient sharedClient] postFollowMessage: message
                                             photos: arrUploadedPhotos
                                               feed: selectedFeed
                                            success:^{
                                                
                                                [SVProgressHUD dismiss];
                                                [_delegate onFollowUpPostedSuccess];
                                                [self finish];
                                            } failure:^(NSString *errorMessage) {
                                                [SVProgressHUD dismiss];
                                                [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                            }];
}

- (void) postCommentMessage {
    [self hideKeyboard];
    
    NSString* message = tfMessage.text;
    [[NetworkClient sharedClient] postProjectComment:message feed:selectedFeed success:^{
        [SVProgressHUD dismiss];
        [_delegate onFollowUpPostedSuccess];
        [self finish];
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD dismiss];
        [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
    }];
    
}

-(void) finish{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) clearPostView
{
    tfMessage.text = @"";
    [arrUploadedPhotos removeAllObjects];
    [arrFollowPhotos removeAllObjects];
    
    [self updateFollowPhotos];
}

- (void) hideKeyboard
{
    [tfMessage resignFirstResponder];
}

@end
