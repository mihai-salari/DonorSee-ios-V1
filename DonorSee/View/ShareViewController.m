//
//  ShareViewController.m
//  DonorSee
//
//  Created by star on 3/9/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "ShareViewController.h"
#import <Social/Social.h>
#import "Branch.h"
//#import "JAmazonS3ClientManager.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>

@interface ShareViewController () <FBSDKSharingDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) shareFeed:(Feed *)f image: (UIImage*) imgShare
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Share" message: @"" preferredStyle: UIAlertControllerStyleActionSheet];
    
    //Facebook.
    UIAlertAction* fbAction = [UIAlertAction actionWithTitle: @"Facebook" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareFeedInFacebook: f image: imgShare];
        
        
    }];
    [alert addAction: fbAction];
    
    //Twitter.
    UIAlertAction* twitterAction = [UIAlertAction actionWithTitle: @"Twitter" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        [self shareFeedInTwitter: f image: imgShare];
                                    }];
    [alert addAction: twitterAction];
    
    
    //Email.
    UIAlertAction *emailAction = [UIAlertAction actionWithTitle: @"Email" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareFeedInEmail: f image: imgShare];
        
    }];
    [alert addAction: emailAction];
    
    //Get Profile Link
    UIAlertAction* getProfileAction = [UIAlertAction actionWithTitle: @"Copy Project Link"
                                                               style: UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                                 [self getProjectLink: f];
                                                             }];
    [alert addAction: getProfileAction];

    
    //Cancel.
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction: cancelAction];
    [self presentViewController: alert animated: YES completion: nil];
}

- (void) getProjectLink: (Feed*) f
{
    //Amit
    NSString *strURL =[NSString stringWithFormat:@"https://donorsee.com/project/%@",f.feed_id];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = strURL;

    
    /*
    NSData *plainData = [[NSString stringWithFormat:@"%@", f.feed_id] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    
    NSString *url = [NSString stringWithFormat:@"https://donorsee.com/feed-details/%@", base64String];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = url;
    */
}

- (void) shareFeedInFacebook: (Feed*) f image: (UIImage*) imgShare
{
    NSString *strURL =[NSString stringWithFormat:@"https://donorsee.com/project/%@",f.feed_id];
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.imageURL = [NSURL URLWithString: f.photo];
    content.contentDescription = f.feed_description;
    content.contentURL = [NSURL URLWithString: strURL];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.mode = FBSDKShareDialogModeFeedWeb;
    dialog.shareContent = content;
    dialog.delegate = self;
    dialog.fromViewController = self;
    [dialog show];
    /*
    [SVProgressHUD show];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:f.feed_id, @"feed_id", nil];
    [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
         content.imageURL = [NSURL URLWithString: f.photo];
         content.contentDescription = f.feed_description;
         content.contentURL = [NSURL URLWithString: url];

         FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
         dialog.mode = FBSDKShareDialogModeFeedWeb;
         dialog.shareContent = content;
         dialog.delegate = self;
         dialog.fromViewController = self;
         [dialog show];
     }];*/
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"result = %@", results);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"fb share error = %@", error.description);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"fb share cancelled");
}

- (void) shareFeedInTwitter:(Feed *)f image:(UIImage *)imgShare
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        
        
        
        //Amit ------------------
        NSString *strURL =[NSString stringWithFormat:@"https://donorsee.com/project/%@",f.feed_id];
        NSString* postText = f.feed_description;
        if([f.feed_description length] > TWITTER_MAX_LENGTH)
        {
            postText = [NSString stringWithFormat: @"%@...", [f.feed_description substringToIndex: TWITTER_MAX_LENGTH]];
        }
        
        [tweetSheet setInitialText: postText];
        [tweetSheet addURL: [NSURL URLWithString: strURL]];
        
        if(imgShare == nil)
        {
            UIImage* image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: f.photo]]];
            [tweetSheet addImage: image];
        }
        else
        {
            [tweetSheet addImage: imgShare];
        }
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled)
            {
                NSLog(@"delete");
            } else
            {
                NSLog(@"post twitter");
            }
        };
        
        tweetSheet.completionHandler = myBlock;
        [self presentViewController:tweetSheet animated:YES completion:nil];
        /*
         NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:f.feed_id, @"feed_id", nil];
         
        [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
         {
             [SVProgressHUD dismiss];
             
             NSString* postText = f.feed_description;
             if([f.feed_description length] > TWITTER_MAX_LENGTH)
             {
                 postText = [NSString stringWithFormat: @"%@...", [f.feed_description substringToIndex: TWITTER_MAX_LENGTH]];
             }
             
             [tweetSheet setInitialText: postText];
             [tweetSheet addURL: [NSURL URLWithString: url]];
             
             if(imgShare == nil)
             {
                 UIImage* image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: f.photo]]];
                 [tweetSheet addImage: image];
             }
             else
             {
                 [tweetSheet addImage: imgShare];
             }
             
             SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                 if (result == SLComposeViewControllerResultCancelled)
                 {
                     NSLog(@"delete");
                 } else
                 {
                     NSLog(@"post twitter");
                 }
             };
             
             tweetSheet.completionHandler = myBlock;
             [self presentViewController:tweetSheet animated:YES completion:nil];
         }];*/
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"No Twitter Accounts"
                                                                       message: @"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok"
                                                           style: UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
        [alert addAction: okAction];
        [self presentViewController: alert animated: YES completion: nil];
    }
}

- (void) shareFeedInEmail:(Feed *)f image:(UIImage *)imgShare
{
    if([MFMailComposeViewController canSendMail])
    {
        //Amit
        NSString *strURL =[NSString stringWithFormat:@"https://donorsee.com/project/%@",f.feed_id];
        NSString *messageBody = [NSString stringWithFormat: @"%@\n%@", f.feed_description, strURL];
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setMessageBody:messageBody isHTML:NO];
        
        NSData* imageData;
        if(imgShare)
        {
            imageData = UIImageJPEGRepresentation(imgShare, 1.0);
            [mc addAttachmentData: imageData mimeType: @"image/png" fileName: @"donate"];
        }
        else
        {
            imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: f.photo]];
            [mc addAttachmentData: imageData mimeType: @"image/png" fileName: @"donate"];
        }
        
        [self presentViewController:mc animated:YES completion:NULL];
        /*
        [SVProgressHUD show];
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:f.feed_id, @"feed_id", nil];
        [[Branch getInstance] getShortURLWithParams:params andCallback:^(NSString *url, NSError *error)
         {
             [SVProgressHUD dismiss];
             
             NSString *messageBody = [NSString stringWithFormat: @"%@\n%@", f.feed_description, url];
             MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
             mc.mailComposeDelegate = self;
             [mc setMessageBody:messageBody isHTML:NO];
             
             NSData* imageData;
             if(imgShare)
             {
                 imageData = UIImageJPEGRepresentation(imgShare, 1.0);
                 [mc addAttachmentData: imageData mimeType: @"image/png" fileName: @"donate"];
             }
             else
             {
                 imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: f.photo]];
                 [mc addAttachmentData: imageData mimeType: @"image/png" fileName: @"donate"];
             }
             
             [self presentViewController:mc animated:YES completion:NULL];

         }];*/
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Failure" message: @"Your device doesn't support email." preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction: okAction];
        [self presentViewController: alert animated: YES completion: nil];
    }
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

@end
