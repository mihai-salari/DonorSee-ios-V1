//
//  PhotoCellView.m
//  DonorSee
//
//  Created by star on 3/24/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "PhotoCellView.h"

@implementation PhotoCellView
@synthesize ivPhoto;
@synthesize btAddPhoto;

- (id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame: frame])
    {
        PhotoCellView* xibView = [[[NSBundle mainBundle] loadNibNamed:@"PhotoCellView" owner:self options:nil] objectAtIndex:0];
        [xibView setFrame:frame];
        self = xibView;
        
        [self initUI];
    }
    
    return self;
}

- (id) initWithImage: (CGRect) frame image: (UIImage*) imgPhoto
{
    if(self = [self initWithFrame: frame])
    {
        ivPhoto.image = imgPhoto;
        [btAddPhoto setImage: nil forState: UIControlStateNormal];
        isAddPhoto = NO;
    }
    
    return self;
}

- (id) initWithAddCell: (CGRect) frame
{
    if(self = [self initWithFrame: frame])
    {
        [btAddPhoto setImage: [UIImage imageNamed: @"plus_photo.png"] forState: UIControlStateNormal];
        isAddPhoto = YES;
    }
    
    return self;
}

- (void) initUI
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0;
}

- (IBAction) actionAdd:(id)sender
{
    if(isAddPhoto)
    {
        if ([self.delegate respondsToSelector:@selector(addPhoto)])
        {
            [self.delegate addPhoto];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(updatePhoto:)])
        {
            [self.delegate updatePhoto: (int)self.tag];
        }
    }
}

@end
