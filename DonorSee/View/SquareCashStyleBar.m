//
//  SquareCashStyleBar.m
//  BLKFlexibleHeightBar Demo
//
//  Created by Bryan Keller on 2/19/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import "SquareCashStyleBar.h"

@implementation SquareCashStyleBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self configureBar];
    }
    
    return self;
}

- (void)configureBar
{
    // Configure bar appearence
    const CGFloat whiteViewHeight = 54.0;
    const CGFloat statusBarheight = 20.0;
    const CGFloat navigationBarHeight = 58.0;
    
    self.maximumBarHeight = statusBarheight + navigationBarHeight + whiteViewHeight;
    
    self.minimumBarHeight = statusBarheight + whiteViewHeight;
    self.backgroundColor = COLOR_MAIN;
    self.clipsToBounds = YES;
    
    
    // Add blue bar view
    UIView *blueBarView = [[UIView alloc] init];
    blueBarView.backgroundColor = self.backgroundColor;
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialBlueBarLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialBlueBarLayoutAttributes.frame = CGRectMake(0.0, 0, self.frame.size.width, navigationBarHeight + statusBarheight);
    [blueBarView addLayoutAttributes:initialBlueBarLayoutAttributes forProgress:0.0];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalBlueBarLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialBlueBarLayoutAttributes];
    finalBlueBarLayoutAttributes.transform = CGAffineTransformMakeTranslation(0.0, -navigationBarHeight);
    [blueBarView addLayoutAttributes:finalBlueBarLayoutAttributes forProgress:1.0];
    
    [self addSubview:blueBarView];
    
    
    UIImageView *profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_logo.png"]];
    profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    profileImageView.clipsToBounds = YES;
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialProfileImageViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialProfileImageViewLayoutAttributes.size = CGSizeMake(137, 37);
    initialProfileImageViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, navigationBarHeight + statusBarheight-30.0);
    initialProfileImageViewLayoutAttributes.zIndex = 1024;
    [profileImageView addLayoutAttributes:initialProfileImageViewLayoutAttributes forProgress:0.0];
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalProfileImageViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialProfileImageViewLayoutAttributes];
    finalProfileImageViewLayoutAttributes.center = CGPointMake(finalProfileImageViewLayoutAttributes.center.x, finalProfileImageViewLayoutAttributes.center.y - navigationBarHeight * 0.25);
    finalProfileImageViewLayoutAttributes.transform = CGAffineTransformMakeScale(0.5, 0.5);
    finalProfileImageViewLayoutAttributes.alpha = 0.0;
    finalProfileImageViewLayoutAttributes.zIndex = 1024;
    
    [profileImageView addLayoutAttributes:finalProfileImageViewLayoutAttributes forProgress:0.5];
    
    [self addSubview:profileImageView];
    
    // Add white bar view
    UIView *whiteBarView = [[UIView alloc] init];
    whiteBarView.backgroundColor = [UIColor whiteColor];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialWhiteBarLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialWhiteBarLayoutAttributes.frame = CGRectMake(0.0, navigationBarHeight + statusBarheight, self.frame.size.width, whiteViewHeight);
    [whiteBarView addLayoutAttributes:initialWhiteBarLayoutAttributes forProgress:0.0];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalWhiteBarLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialWhiteBarLayoutAttributes];
    finalWhiteBarLayoutAttributes.frame = CGRectMake(0.0, statusBarheight, self.frame.size.width, whiteViewHeight);
    [whiteBarView addLayoutAttributes:finalWhiteBarLayoutAttributes forProgress:1.0];
    
    [self addSubview:whiteBarView];
    whiteBarView.userInteractionEnabled = YES;
    
    // Configure white bar view subviews
    UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, initialWhiteBarLayoutAttributes.size.height-0.5, initialWhiteBarLayoutAttributes.size.width, 0.5)];
    bottomBorderView.backgroundColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1];
    [whiteBarView addSubview:bottomBorderView];
    
    UIView *leftVerticalDividerView = [[UIView alloc] initWithFrame:CGRectMake(initialWhiteBarLayoutAttributes.size.width/2.0, 0, 0.5, initialWhiteBarLayoutAttributes.size.height)];
    leftVerticalDividerView.backgroundColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1];
    [whiteBarView addSubview:leftVerticalDividerView];
    
    //Global.
    UIImageView* ivGlobal = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"global_icon.png"]];
    ivGlobal.frame = CGRectMake(47, 15, 23, 28);
    [whiteBarView addSubview: ivGlobal];
    
    lbGlobal = [[UILabel alloc] initWithFrame: CGRectMake(80, 15, 80, 28)];
    lbGlobal.textAlignment = NSTextAlignmentLeft;
    lbGlobal.text = @"GLOBAL";
    [whiteBarView addSubview: lbGlobal];
    
    UIButton* btGlobal = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width/2.0, 58)];
    [btGlobal addTarget: self action: @selector(onTapCategory:) forControlEvents: UIControlEventTouchUpInside];
    btGlobal.tag = 0;
    [whiteBarView addSubview: btGlobal];
    
    //Personal.
    UIImageView* ivPersonal = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"personal_icon.png"]];
    ivPersonal.frame = CGRectMake(40 + initialWhiteBarLayoutAttributes.size.width/2.0, 17, 29, 23);
    [whiteBarView addSubview: ivPersonal];
    
    lbPersonal = [[UILabel alloc] initWithFrame: CGRectMake(80 + initialWhiteBarLayoutAttributes.size.width/2.0, 15, 90, 28)];
    lbPersonal.textAlignment = NSTextAlignmentLeft;
    lbPersonal.text = @"PERSONAL";
    [whiteBarView addSubview: lbPersonal];
    
    UIButton* btPersonal = [[UIButton alloc] initWithFrame: CGRectMake(self.frame.size.width/2.0, 0, self.frame.size.width/2.0, 58)];
    [btPersonal addTarget: self action: @selector(onTapCategory:) forControlEvents: UIControlEventTouchUpInside];
    btPersonal.tag = 1;
    [whiteBarView addSubview: btPersonal];
    
    if(IS_IPHONE_5)
    {
        ivGlobal.frame = CGRectMake(27, 15, 23, 28);
        lbGlobal.frame = CGRectMake(60, 15, 80, 28);
        
        ivPersonal.frame = CGRectMake(20 + initialWhiteBarLayoutAttributes.size.width/2.0, 17, 29, 23);
        lbPersonal.frame = CGRectMake(60 + initialWhiteBarLayoutAttributes.size.width/2.0, 15, 90, 28);
    }
    else if(IS_IPHONE_4_OR_LESS)
    {
        ivGlobal.frame = CGRectMake(22, 15, 23, 28);
        lbGlobal.frame = CGRectMake(55, 15, 80, 28);
        
        ivPersonal.frame = CGRectMake(15 + initialWhiteBarLayoutAttributes.size.width/2.0, 17, 29, 23);
        lbPersonal.frame = CGRectMake(55 + initialWhiteBarLayoutAttributes.size.width/2.0, 15, 90, 28);
    }

    
    selectedIndex = 0;
    [self updateButtons];
}

- (void) updateButtons
{
    lbGlobal.textColor = [UIColor colorWithRed: 186.0/255.0 green: 186.0/255.0 blue: 186.0/255.0 alpha: 1.0];
    lbPersonal.textColor = [UIColor colorWithRed: 186.0/255.0 green: 186.0/255.0 blue: 186.0/255.0 alpha: 1.0];
    lbGlobal.font = [UIFont fontWithName: FONT_LIGHT size: 15.0];
    lbPersonal.font = [UIFont fontWithName: FONT_LIGHT size: 15.0];
    
    if(selectedIndex == 0)
    {
        lbGlobal.textColor = [UIColor colorWithRed: 234.0/255.0 green: 157.0/255.0 blue: 13.0/255.0 alpha: 1.0];
        lbGlobal.font = [UIFont fontWithName: FONT_MEDIUM size: 15.0];
    }
    else
    {
        lbPersonal.textColor = [UIColor colorWithRed: 234.0/255.0 green: 157.0/255.0 blue: 13.0/255.0 alpha: 1.0];
        lbPersonal.font = [UIFont fontWithName: FONT_MEDIUM size: 15.0];
    }
}

- (void) onTapCategory: (UIButton*) btn
{
    selectedIndex = (int)btn.tag;
    [self updateButtons];
    
    if ([self.delegate respondsToSelector:@selector(selectedType:)])
    {
        [self.delegate selectedType: selectedIndex];
    }
}

@end
