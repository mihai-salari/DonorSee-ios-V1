//
//  WebViewController.h
//  DonorSee
//
//  Created by Yaroslav Kupyak on 9/15/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface WebViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) NSString *urlString;

@end
