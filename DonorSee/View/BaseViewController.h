//
//  BaseViewController.h
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSMappingProvider.h"
#import "FEMDeserializer.h"

@interface BaseViewController : UIViewController
{
    
}

- (void) initMember;
- (void) gotoHomeView: (BOOL) animate;
- (IBAction) actionBack:(id)sender;
- (void) signInFB: (void (^)(void)) completed;
- (BOOL)isModal;
@end
