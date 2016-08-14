//
//  SignInViewController.m
//  DonorSee
//
//  Created by star on 3/17/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()
{
    
}

@property (nonatomic, weak) IBOutlet UIButton           *btSkip;
@property (nonatomic, weak) IBOutlet UIButton           *btLogin;
@property (nonatomic, weak) IBOutlet UIButton           *btSignUp;

@end

@implementation SignInViewController
@synthesize btSkip;
@synthesize btLogin;
@synthesize btSignUp;

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
    
    btSkip.layer.masksToBounds = YES;
    btSkip.layer.cornerRadius = 20.0;
    btSkip.layer.borderColor = [UIColor whiteColor].CGColor;
    btSkip.layer.borderWidth = 1.0;
    
    btLogin.layer.masksToBounds = YES;
    btLogin.layer.cornerRadius = 20.0;
    btLogin.layer.borderColor = [UIColor whiteColor].CGColor;
    btLogin.layer.borderWidth = 1.0;

    btSignUp.layer.masksToBounds = YES;
    btSignUp.layer.cornerRadius = 20.0;
    btSignUp.layer.borderColor = [UIColor whiteColor].CGColor;
    btSignUp.layer.borderWidth = 1.0;
}


- (IBAction) actionSkip:(id)sender
{
    [self gotoHomeView: YES];
}

@end
