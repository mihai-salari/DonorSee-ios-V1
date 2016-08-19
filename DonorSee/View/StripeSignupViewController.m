//
//  StripeSignupViewController.m
//  DonorSee
//
//  Created by Keval on 18/08/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "StripeSignupViewController.h"

@interface StripeSignupViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;


@end

@implementation StripeSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.didDismiss)
        self.didDismiss(@"Stripe Login Complete");
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus: @"Loading..." maskType: SVProgressHUDMaskTypeClear];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Load Complete...");
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"ERROR %@", error.localizedDescription);
    [SVProgressHUD dismiss];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
