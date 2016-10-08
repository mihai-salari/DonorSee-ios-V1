//
//  HomeViewController.m
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "FeedTableViewCell.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
//#import "JAmazonS3ClientManager.h"
#import "DonateViewController.h"

#import "SquareCashStyleBar.h"
#import "FacebookStyleBarBehaviorDefiner.h"
#import "BLKDelegateSplitter.h"
#import "AppDelegate.h"
#import "PlayerViewController.h"

@interface HomeViewController() <UITableViewDataSource, UITableViewDelegate, FeedTableViewCellDelegate, SquareCashStyleBarDelegate>
{
    int                         offsetGlobal;
    BOOL                        isEndedGlobal;
    float                       scrollOffsetGlobal;
    
    int                         offsetPersonal;
    BOOL                        isEndedPersonal;
    float                       scrollOffsetPersonal;
    
    NSMutableArray              *arrGlobal;
    NSMutableArray              *arrPersonal;
    
    int                         type;
}

@property (strong, nonatomic) UIRefreshControl                  *refreshControl;
@property (strong, nonatomic) UIView                            *refreshView;
@property (strong, nonatomic) UIImageView                       *refreshIcon;
@property (nonatomic) BOOL                                      isRefreshAnimating;

@property (weak, nonatomic) IBOutlet UIView                     *viFooter;
@property (strong, nonatomic) SquareCashStyleBar                  *topBar;
@property (nonatomic) BLKDelegateSplitter *delegateSplitter;
@property (nonatomic, weak) IBOutlet UILabel                    *lbEmpty;

@property (nonatomic, strong) NSArray                           *followedUserIds;
@end


@implementation HomeViewController
@synthesize viFooter;
@synthesize topBar;
@synthesize lbEmpty;

- (void) initMember
{
    [super initMember];
    
    type = HOME_GLOBAL;
    
    arrGlobal = [[NSMutableArray alloc] init];
    arrPersonal = [[NSMutableArray alloc] init];
    _followedUserIds = @[];
    
    [self.tbMain.infiniteScrollingView setCustomView: viFooter forState:SVInfiniteScrollingStateStopped];
    __weak HomeViewController *weakSelf = self;
    [self.tbMain addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadFeedsFromServer: NO];
    }];

    [self initHeaderView];
    
    [self.tbMain registerNib: [UINib nibWithNibName: @"FeedTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FeedTableViewCell class])];
    self.tbMain.contentInset = UIEdgeInsetsMake(110, 0.0, viFooter.frame.size.height, 0.0);

    [self initRefreshControl];
    
    isEndedGlobal = NO;
    offsetGlobal = 0;
    scrollOffsetGlobal = 0;
    
    isEndedPersonal = NO;
    offsetPersonal = 0;
    scrollOffsetPersonal = 0;
    
    [self loadFeedsFromServer: YES];
    [self getUserFollowStatus];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (arrGlobal.count > 0) {
        [self.tbMain reloadData];
    }
}

- (void) initHeaderView
{
    //Top Bar.
    topBar = [[SquareCashStyleBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 132.0)];
    topBar.backgroundColor = COLOR_MAIN;
    topBar.delegate = self;
    [self.view addSubview: topBar];
    
    FacebookStyleBarBehaviorDefiner *behaviorDefiner = [[FacebookStyleBarBehaviorDefiner alloc] init];
    [behaviorDefiner addSnappingPositionProgress:0.0 forProgressRangeStart:0.0 end:58.0/(105.0-20.0)];
    [behaviorDefiner addSnappingPositionProgress:1.0 forProgressRangeStart:58.0/(105.0-20.0) end:1.0];
    behaviorDefiner.snappingEnabled = YES;
    behaviorDefiner.thresholdNegativeDirection = 140.0;
    ((UIScrollView *)self.tbMain).delegate = behaviorDefiner;
    topBar.behaviorDefiner = behaviorDefiner;
    
    // Configure a separate UITableViewDelegate and UIScrollViewDelegate (optional)
    self.delegateSplitter = [[BLKDelegateSplitter alloc] initWithFirstDelegate:behaviorDefiner secondDelegate:self];
    self.tbMain.delegate = (id<UITableViewDelegate>)self.delegateSplitter;
}

- (void) getUserFollowStatus {
    [[NetworkClient sharedClient] getUserFollowingStatus:[AppEngine sharedInstance].currentUser.user_id user_id:[AppEngine sharedInstance].currentUser.user_id success:^(NSArray *followStatus) {
        
        _followedUserIds = @[];
        
        if (followStatus.count > 0) {
            
            _followedUserIds = [followStatus valueForKey:@"id"];
            
            NSLog(@"_followedUserIds %@", _followedUserIds);
            
        }
        
        [self.tbMain reloadData];
        
    } failure:^(NSString *errorMessage) {
        
    }];
}

- (void) finishedFollowForFeed: (NSNotification*) notification
{
    
    [self getUserFollowStatus];
    
    return;
    
    if([notification.object isKindOfClass: [User class]])
    {
        User* user = notification.object;
        for(Feed* item in arrGlobal)
        {
            if(item.post_user_id == user.user_id)
            {
                item.postUser = user;
            }
        }
        
        for(Feed* item in arrPersonal)
        {
            if(item.post_user_id == user.user_id)
            {
                item.postUser = user;
            }
        }
        
        [self.tbMain reloadData];
        
        offsetPersonal = 0;
        isEndedPersonal = NO;
        [self loadPersonalFeeds: YES];
    }
}

- (void) selectedType: (int) t
{
    //Save Scroll Offset for Prev Type.
    if(type == HOME_GLOBAL)
    {
        scrollOffsetGlobal = self.tbMain.contentOffset.y;
    }
    else
    {
        scrollOffsetPersonal = self.tbMain.contentOffset.y;
    }
    
    //Set New Type
    type = t;
    [self.tbMain reloadData];
    
    if(type == HOME_GLOBAL)
    {
        self.tbMain.showsInfiniteScrolling = !isEndedGlobal;
        [self.tbMain setContentOffset: CGPointMake(0, scrollOffsetGlobal) animated: NO];
        
        if([arrGlobal count] == 0)
        {
            [self loadGlobalFeeds: YES];
        }
    }
    else
    {
        self.tbMain.showsInfiniteScrolling = !isEndedPersonal;
        [self.tbMain setContentOffset: CGPointMake(0, scrollOffsetPersonal) animated: NO];
        
        if([arrPersonal count] == 0)
        {
            [self loadPersonalFeeds: YES];
        }
    }
    
    [self checkEmptyText];
}

- (void) initRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshView.backgroundColor = [UIColor clearColor];
    self.refreshIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spin_icon"]];
    CGRect frame = self.refreshIcon.frame;
    frame.size = CGSizeMake(35.0, 35.0);
    self.refreshIcon.frame = frame;
    [self.refreshView addSubview:self.refreshIcon];
    self.refreshView.clipsToBounds = NO;
    self.refreshControl.tintColor = [UIColor clearColor];
    [self.refreshControl addSubview:self.refreshView];
    self.isRefreshAnimating = NO;
    [self.refreshControl addTarget:self action:@selector(loadFeedsFromServer:) forControlEvents:UIControlEventValueChanged];
    
    [self.tbMain addSubview:self.refreshControl];
}

- (void) animateRefresh
{
    self.isRefreshAnimating = YES;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.refreshIcon setTransform:CGAffineTransformRotate(self.refreshIcon.transform, M_PI_2)];
                     } completion:^(BOOL finished) {
                         if (self.refreshControl.isRefreshing || self.isRefreshAnimating) {
                             [self animateRefresh];
                             //                         }else {
                             //                             [self resetAnimation];
                         }
                     }];
}

- (void) resetAnimation
{
    self.isRefreshAnimating = NO;
    self.refreshIcon.transform = CGAffineTransformIdentity;
}

- (void) endRefresh
{
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    [self resetAnimation];
}


- (void) updateAllCells: (NSNotification*) notification
{
    //return;
    if([notification.object isKindOfClass: [Feed class]])
    {
        Feed* f = notification.object;
        int index = 0;
        for(Feed* item in arrGlobal)
        {
            if([item.feed_id isEqual: f.feed_id])
            {
                [arrGlobal replaceObjectAtIndex: index withObject: f];
                break;
            }
            
            index ++;
        }
        
        index = 0;
        for(Feed* item in arrPersonal)
        {
            if([item.feed_id isEqual: f.feed_id])
            {
                [arrPersonal replaceObjectAtIndex: index withObject: f];
                break;
            }
            
            index ++;
        }
        
        [self.tbMain reloadData];
    }
}

- (void) refreshFeeds
{
    [self clearAllFeeds];
    [self loadFeedsFromServer: YES];
}

- (void) loadFeedsFromServer: (BOOL) isFirstLoading
{
    if(type == HOME_GLOBAL)
    {
        [self loadGlobalFeeds: isFirstLoading];
    }
    else
    {
        [self loadPersonalFeeds: isFirstLoading];
    }
    
    [[AppDelegate getDelegate].mainTabBar updateNotificationBadge];
}

- (void) loadGlobalFeeds: (BOOL) isFirstLoading
{
    if(offsetGlobal == 0 && isFirstLoading)
    {
        [SVProgressHUD show];
    }
    [[NetworkClient sharedClient] getHomeFeeds: FETCH_LIMIT
                                        offset: offsetGlobal
                                       success:^(NSArray *arrResult) {
                                           
                                           [SVProgressHUD dismiss];
                                           
                                           if(offsetGlobal == 0)
                                           {
                                               [arrGlobal removeAllObjects];
                                           }
                                           
                                           if(arrResult != nil && ![arrResult isKindOfClass: [NSNull class]])
                                           {
                                               [arrGlobal addObjectsFromArray:arrResult];
                                               
                                               offsetGlobal += (int)[arrResult count];
                                               if([arrResult count] > 0)
                                               {
                                                   isEndedGlobal = NO;
                                               }
                                               else
                                               {
                                                   isEndedGlobal = YES;
                                               }
                                           }
                                           else
                                           {
                                               isEndedGlobal = YES;
                                           }
                                           
                                           [self.tbMain.infiniteScrollingView stopAnimating];
                                           self.tbMain.showsInfiniteScrolling = !isEndedGlobal;
                                           [self.tbMain reloadData];
                                           [self endRefresh];
                                           
                                       } failure:^(NSString *errorMessage) {
                                           [SVProgressHUD dismiss];
                                           [self.tbMain.infiniteScrollingView stopAnimating];
                                           [self endRefresh];
                                       }];
}

- (void) loadPersonalFeeds: (BOOL) isFirstLoading
{
    if([AppEngine sharedInstance].currentUser == nil) return;
    
    if(offsetPersonal == 0 && isFirstLoading)
    {
        [SVProgressHUD show];
    }
    [[NetworkClient sharedClient] getPersonalFeeds: FETCH_LIMIT
                                            offset: offsetPersonal
                                       success:^(NSArray *arrResult) {
                                           
                                           [SVProgressHUD dismiss];
                                           
                                           if(offsetPersonal == 0)
                                           {
                                               [arrPersonal removeAllObjects];
                                           }
                                           
                                           if(arrResult != nil && ![arrResult isKindOfClass: [NSNull class]])
                                           {
                                               /*
                                               for(NSDictionary* dicItem in arrResult)
                                               {
                                                   Feed* f = [[Feed alloc] initWithHomeFeed: dicItem];
                                                   [[CoreHelper sharedInstance] addFeed: f];
                                                   
                                                   [arrPersonal addObject: f];
                                               }*/
                                               [arrPersonal addObjectsFromArray:arrResult];
                                               
                                               offsetPersonal += (int)[arrResult count];
                                               if([arrResult count] > 0)
                                               {
                                                   isEndedPersonal = NO;
                                               }
                                               else
                                               {
                                                   isEndedPersonal = YES;
                                               }
                                           }
                                           else
                                           {
                                               isEndedPersonal = YES;
                                           }
                                           
                                           [self checkEmptyText];
                                           
                                           [self.tbMain.infiniteScrollingView stopAnimating];
                                           self.tbMain.showsInfiniteScrolling = !isEndedPersonal;
                                           [self.tbMain reloadData];
                                           [self endRefresh];
                                           
                                       } failure:^(NSString *errorMessage) {
                                           [SVProgressHUD dismiss];
                                           [self.tbMain.infiniteScrollingView stopAnimating];
                                           [self endRefresh];
                                       }];
}

- (void) clearAllFeeds
{
    offsetGlobal = 0;
    isEndedGlobal = NO;
    
    offsetPersonal = 0;
    isEndedPersonal = NO;
}


- (void) checkEmptyText
{
    if(type == HOME_PERSONAL)
    {
        //Check Empty.
        if([arrPersonal count] == 0)
        {
            lbEmpty.hidden = NO;
        }
        else
        {
            lbEmpty.hidden = YES;
        }
    }
    else
    {
        lbEmpty.hidden = YES;
    }
}

- (void) updateContentAfterRemove: (NSNotification*) notification
{
    if([notification.object isKindOfClass: [Feed class]])
    {
        Feed* f = notification.object;
        for(Feed* item in arrGlobal)
        {
            if([item.feed_id isEqual: f.feed_id])
            {
                [arrGlobal removeObject: item];
                [self.tbMain reloadData];
                break;
            }
        }
        
        for(Feed* item in arrPersonal)
        {
            if([item.feed_id isEqual: f.feed_id])
            {
                [arrPersonal removeObject: item];
                [self.tbMain reloadData];
                break;
            }
        }
    }
}


#pragma mark - UITableView.

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(type == HOME_GLOBAL)
    {
        return arrGlobal.count;
    }
    else
    {
        return arrPersonal.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedTableViewCell *cell = (FeedTableViewCell*)[tableView dequeueReusableCellWithIdentifier: NSStringFromClass([FeedTableViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    
    Feed* f;
    if(type == HOME_GLOBAL)
    {
        f = [arrGlobal objectAtIndex: indexPath.row];
    }
    else
    {
        f = [arrPersonal objectAtIndex: indexPath.row];
    }
    
    [cell setDonateFeed: f isDetail: NO];
    
    [cell updateFollowStatus:NO];
    int feedId = f.postUser.user_id;
    if ([_followedUserIds containsObject:[NSNumber numberWithInt:feedId]]) {
        [cell updateFollowStatus:YES];
    }
    
    return cell;
}

-(void)openPlayer: (NSString*) videoURL;
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlayerViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"PlayerViewController"];
    //nextView.videoURL = @"https://res.cloudinary.com/donorsee/video/upload/v1475263379/development/cnds2bb57ff7yqf4h6wm.mp4";
    nextView.videoURL = videoURL;
    [self.navigationController pushViewController: nextView animated: YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FeedTableViewCell getHeight];
}

#define REFRESH_POINT 50.0f
#define REFRESH_ICON_Y 5.0f
#define REFRESH_ICON_VISIBLE 15.0f

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollOffset = scrollView.contentOffset.y;
    if (scrollOffset < 0)
    {
        // PULL TO REFRESH
        CGRect refreshBounds = self.refreshControl.bounds;
        CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
        CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), REFRESH_POINT) / REFRESH_POINT;
        CGFloat midX = self.view.frame.size.width / 2.0;
        CGFloat quHeight = 35.0 * pullRatio;
        CGFloat quWidth = 35.0 * pullRatio;
        CGFloat quHalfWidth = quWidth / 2.0;
        
        CGFloat x = midX - quHalfWidth;
        CGFloat y = REFRESH_ICON_Y;
        
        CGRect frame = self.refreshIcon.frame;
        frame.size = CGSizeMake(quWidth, quHeight);
        frame.origin.x = x;
        frame.origin.y = y;
        self.refreshIcon.frame = frame;
        self.refreshIcon.hidden = !(pullDistance >= REFRESH_ICON_VISIBLE);
        
        refreshBounds.size.height = pullDistance;
        self.refreshView.frame = refreshBounds;
        
        if (pullRatio >= 1.0) {
            if (!self.isRefreshAnimating) {
                [self animateRefresh];
            }
        }else {
            [self resetAnimation];
        }
    }
}

//====================================================================================================
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //[_refreshHeaderView showRotateLoading];
}


//====================================================================================================
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), REFRESH_POINT) / REFRESH_POINT;
    if (pullRatio >= 1.0) {
        if (!self.refreshControl.isRefreshing)
        {
            [self.refreshControl beginRefreshing];
            self.isRefreshAnimating = NO;
            
            [self clearAllFeeds];
            [self loadFeedsFromServer: NO];
        }
    }
}


#pragma mark - Feed Delegate.

- (void) donateFeed:(Feed *)f
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DonateViewController *nextView = [storyboard instantiateViewControllerWithIdentifier: @"DonateViewController"];
    nextView.selectedFeed = f;
    [self.navigationController pushViewController: nextView animated: YES];
}

@end
