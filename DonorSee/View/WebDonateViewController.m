//
//  WebDonateViewController.m
//  DonorSee
//
//  Created by star on 3/28/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "WebDonateViewController.h"
#import "DetailFeedViewController.h"

@interface WebDonateViewController () <UIWebViewDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UIWebView          *webView;
@end

@implementation WebDonateViewController
@synthesize webView;

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
    
    NSString* urlPath = [NSString stringWithFormat: @"%@/donate_api/web_donate.php", kAPIBaseURLString];
    NSURL *url= [NSURL URLWithString: urlPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    
    
    NSString *postString = [NSString stringWithFormat: @"feed_id=%d&amount=%d&receiver_email=%@&user_id=%@", [self.selectedFeed.feed_id intValue], self.amount, self.selectedFeed.postUser.paypal, [AppEngine sharedInstance].currentUser.fb_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [webView loadRequest: request];
}

- (IBAction) actionBack:(id)sender
{
    [(DetailFeedViewController*)self.prevViewController loadActivities];
    [super actionBack: sender];
}

@end
