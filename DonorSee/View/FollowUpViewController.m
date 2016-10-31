//
//  FollowUpViewController.m
//  DonorSee
//
//  Created by Bogdan on 10/15/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "FollowUpViewController.h"
#import "PhotoCellView.h"
#import "MediaFile.h"
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVAssetImageGenerator.h"
#import "VideoValidation.h"


@import ALCameraViewController;

@interface FollowUpViewController ()
{
    NSMutableArray              *arrFollowPhotos;
    UIImagePickerController     *imagePicker;
    int                         selectedPhotoIndex;
    
    NSMutableArray              *arrUploadedPhotos;
    int                         uploadingPhotoIndex;
    
    enum MediaType              mediaType;
}
@property (weak, nonatomic) IBOutlet UIView *vBackground;
@property (weak, nonatomic) IBOutlet UIButton *btFollowUp;
@property (weak, nonatomic) IBOutlet UIView *vFrame;
@property (weak, nonatomic) IBOutlet UIView *viMessage;
@property (weak, nonatomic) IBOutlet UITextView *tfMessage;

@property (weak, nonatomic) IBOutlet UIScrollView *scPostPhotos;

@end

@implementation FollowUpViewController

@synthesize vBackground;
@synthesize btFollowUp;
@synthesize selectedFeed;
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
    
    self.tfMessage.delegate = self;
    
    self.scPostPhotos.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(messageDoneButtonPress)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.tfMessage.inputAccessoryView = keyboardToolbar;

    
    [self initUI];
}

-(void)messageDoneButtonPress
{
    [self.tfMessage resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) onTapBackground :(UITapGestureRecognizer *)gr{
    if(![SVProgressHUD isVisible]){
        [self finish];
    }
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
    [self uploadNextMediaFile];
}

- (void) uploadNextMediaFile
{
    MediaFile* mediaFile = [arrFollowPhotos objectAtIndex: uploadingPhotoIndex];
    if(mediaFile.mediaType == PICTURE){
        UIImage* image = mediaFile.uiImage;
        NSData* imgData = UIImageJPEGRepresentation(image, IMAGE_COMPRESSION);
        
        [[NetworkClient sharedClient] uploadImage:imgData success:^(NSDictionary *mediaInfo) {
            [self mediaFileUploaded:mediaInfo mediaFile:mediaFile];
        } failure:^(NSString *errorMessage) {
            [SVProgressHUD dismiss];
        }];
    } else {
        NSURL * mediaURL = [NSURL URLWithString:[mediaFile.mediaURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData *videoData = [NSData dataWithContentsOfFile:[mediaURL path]];
        [[NetworkClient sharedClient] uploadVideo: videoData success:^(NSDictionary *mediaInfo) {
            [self mediaFileUploaded:mediaInfo mediaFile:mediaFile];
        } failure:^(NSString *errorMessage) {
            [SVProgressHUD dismiss];
        }];
    }
}

- (void) mediaFileUploaded:(NSDictionary*) mediaInfo mediaFile:(MediaFile*) mediaFile{
    if ([mediaInfo objectForKey:@"secure_url"]) {
        NSString *secure_url = [mediaInfo objectForKey:@"secure_url"];
        
        mediaFile.mediaURL = secure_url;
        [arrUploadedPhotos addObject: mediaFile];
        uploadingPhotoIndex ++;
        
        if(uploadingPhotoIndex >= [arrFollowPhotos count])
        {
            [self postFollowMessage];
        }
        else
        {
            [self uploadNextMediaFile];
        }
    }else
    {
        [SVProgressHUD dismiss];
        [self presentViewController: [AppEngine showErrorWithText: MSG_ERROR_UPLOADING_IMAGE] animated: YES completion: nil];
    }
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
    for(MediaFile* mediaFile in arrFollowPhotos)
    {
        UIImage* imgPhoto = mediaFile.uiImage;
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
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

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
    
    
     [self showMediaPickerDialog];
}


- (void) showMediaPickerDialog{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil
                                                                   message: nil
                                                            preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction* actionCamera = [UIAlertAction actionWithTitle: @"Camera"
                                                           style: UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self takePicture];
                                                         }];
    [alert addAction: actionCamera];
    
    UIAlertAction* actionUploadFromGallery = [UIAlertAction actionWithTitle: @"Upload photo from gallery"
                                                                      style: UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                                        [self choosePhotoFileFromGallery];
                                                                    }];
    [alert addAction: actionUploadFromGallery];
    
    UIAlertAction* actionUploadVideoFromGallery = [UIAlertAction actionWithTitle:@"Upload video from gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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

- (void) takePicture
{
    mediaType = PICTURE;
    CameraViewController* cameraController = [[CameraViewController alloc] initWithCroppingEnabled: YES
                                                                               allowsLibraryAccess: YES
                                                                                        completion:^(UIImage * image, PHAsset * asset) {
                                                                                            
                                                                                            if(image != nil)
                                                                                            {
                                                                                                [self completeMediaPick:[self createImageMediaFile:image]];
                                                                                            }
                                                                                            
                                                                                            [self dismissViewControllerAnimated: YES completion: nil];
                                                                                        }];
    
    [self presentViewController: cameraController animated: YES completion: nil];
   
}

- (void) choosePhotoFileFromGallery{
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        mediaType = PICTURE;
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void) chooseVideoFile{
    mediaType = VIDEO;
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    videoPicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:videoPicker animated:YES completion:nil];
}


- (void) completeMediaPick:(MediaFile*)mediaFile{
    if(selectedPhotoIndex >= 0)
    {
        [arrFollowPhotos replaceObjectAtIndex: selectedPhotoIndex withObject: mediaFile];
    }
    else
    {
        [arrFollowPhotos addObject: mediaFile];
    }

    selectedPhotoIndex = -1;
    
    [self updateFollowPhotos];
}

- (MediaFile*) createImageMediaFile:(UIImage*)image{
    MediaFile *mediaFile = [[MediaFile alloc] init];
    mediaFile.mediaType = PICTURE;
    mediaFile.uiImage = image;
    return mediaFile;
}

- (MediaFile*) createVideoMediaFile:(NSURL*) videoURL {
    MediaFile *mediaFile = [[MediaFile alloc] init];
    mediaFile.mediaType = VIDEO;
    mediaFile.mediaURL = videoURL.absoluteString;
    mediaFile.uiImage = [self getThumbnailFromVideo:videoURL];
    return mediaFile;
}

- (void) updatePhoto:(int)index
{
    selectedPhotoIndex = index;
    
    [self showMediaPickerDialog];
   
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    selectedPhotoIndex = -1;
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(mediaType == VIDEO){
        NSURL* mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        
        VideoValidation *videoValidation = [[VideoValidation alloc] init];
        if([videoValidation videoIsValid:mediaUrl]){
            [self completeMediaPick:[self createVideoMediaFile:mediaUrl]];
        } else {
            selectedPhotoIndex = -1;
            [self showVideoInvalid];
        }
    }else{
        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        [self completeMediaPick:[self createImageMediaFile:image]];
    }
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

-(void) showVideoInvalid{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video"
                                                    message:@"This video is too big. Maximum supported size is 30 seconds"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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

- (NSArray*) getUploadedMediaByType:(enum MediaType)mediaType{
    NSMutableArray* mediaFiles = [[NSMutableArray alloc] init];
    for(MediaFile* mediaFile in arrFollowPhotos){
        if(mediaFile.mediaType == mediaType){
            [mediaFiles addObject:mediaFile.mediaURL];
        }
    }
    return mediaFiles;
}

- (void) postFollowMessage
{
    [self hideKeyboard];
    
    NSArray* uploadedPhotos = [self getUploadedMediaByType:PICTURE];
    NSArray* uploadedVideos = [self getUploadedMediaByType:VIDEO];
    
    NSString* message = tfMessage.text;
    [[NetworkClient sharedClient] postFollowMessage: message
                                             photos: uploadedPhotos
                                             videos:uploadedVideos
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
