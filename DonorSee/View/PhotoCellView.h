//
//  PhotoCellView.h
//  DonorSee
//
//  Created by star on 3/24/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoCellViewDelegate
@optional
- (void) addPhoto;
- (void) updatePhoto: (int) index;
@end


@interface PhotoCellView : UIView
{
    BOOL        isAddPhoto;
}

@property (nonatomic, weak) IBOutlet UIImageView        *ivPhoto;
@property (nonatomic, weak) IBOutlet UIButton           *btAddPhoto;
@property (nonatomic, retain) id                        delegate;

- (id) initWithImage: (CGRect) frame image: (UIImage*) imgPhoto;
- (id) initWithAddCell: (CGRect) frame;

@end
