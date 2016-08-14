//
//  ViewController.m
//  DonorSee
//
//  Created by star on 2/28/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
{
    
}

@property (nonatomic, weak) IBOutlet UIButton       *btGetStarted;
@end

@implementation ViewController
@synthesize btGetStarted;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initMember
{
    [super initMember];
    
    btGetStarted.layer.masksToBounds = YES;
    btGetStarted.layer.cornerRadius = 20.0;
    btGetStarted.layer.borderColor = [UIColor whiteColor].CGColor;
    btGetStarted.layer.borderWidth = 1.0;
    
    [AppDelegate getDelegate].navigator = self.navigationController;
    NSManagedObject* global = [[CoreHelper sharedInstance] getGlobalInfo];
    if(global != nil)
    {
        int current_user_id = [[global valueForKey: @"current_user_id"] intValue];
        if(current_user_id > 0)
        {
            NSManagedObject* objUser = [[CoreHelper sharedInstance] getUser: current_user_id];
            if(objUser)
            {
                [AppEngine sharedInstance].currentUser = [[User alloc] initUserWithManagedObject: objUser];
                [self gotoHomeView: NO];
            }
        }
    }
}


@end
