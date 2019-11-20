//
//  LeftDrawerView.m
//  iOSMaps
//
//  Created by WDY on 15/12/8.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "DrawerView.h"

#define kEdge 5
#define kDefaultDrawerRatio 4/5
#define kMaxMaskAlpha 0.6f

#import "LoginUser.h"

#import <UIImageView+WebCache.h>
#import "ForumCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "ForumApiHelper.h"
#import "UIStoryboard+Forum.h"
#import "ForumTabBarController.h"
#import "SupportForums.h"
#import "LocalForumApi.h"

@interface DrawerView () <UITableViewDelegate, UITableViewDataSource> {

    UIButton *_drawerMaskView;

    UIView *_rightEageView;

    ForumCoreDataManager *coreDateManager;
    NSArray *_haveLoginForums;

    UIImage *defaultAvatar;
    UIImage *defaultAvatarImage;
    NSMutableDictionary *avatarCache;
    NSMutableArray<UserEntry *> *cacheUsers;
}

@end


@implementation DrawerView

@synthesize leftDrawerView = _leftDrawerView;
@synthesize rightDrawerView = _rightDrawerView;


- (void)showUserAvatar {

    LocalForumApi *forumApi = [[LocalForumApi alloc] init];
    id <ForumConfigDelegate> config = [ForumApiHelper forumConfig:forumApi.currentForumHost];
    LoginUser *loginUser = [forumApi getLoginUser:config.forumURL.host];

    [self showAvatar:_avatarUIImageView userId:loginUser.userID];

    self.userName.text = [forumApi userName:config.forumURL.host];

}

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)userId {

    // 不知道什么原因，userID可能是nil
    if (userId == nil) {
        [avatarImageView setImage:defaultAvatarImage];
        return;
    }
    NSString *avatarInArray = [avatarCache valueForKey:userId];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    id <ForumApiDelegate> forumApi = [ForumApiHelper forumApi:localForumApi.currentForumHost];

    if (avatarInArray == nil) {

        [forumApi getAvatarWithUserId:userId handler:^(BOOL isSuccess, NSString *avatar) {

            if (isSuccess) {
                LocalForumApi *localeForumApi = [[LocalForumApi alloc] init];
                // 存入数据库
                [coreDateManager insertOneData:^(id src) {
                    UserEntry *user = (UserEntry *) src;
                    user.userID = userId;
                    user.userAvatar = avatar;
                    user.forumHost = localeForumApi.currentForumHost;
                }];
                // 添加到Cache中
                [avatarCache setValue:avatar forKey:userId];

                // 显示头像
                if (avatar == nil) {
                    [avatarImageView setImage:defaultAvatarImage];
                } else {
                    NSURL *avatarUrl = [NSURL URLWithString:avatar];
                    [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatarImage];
                }
            } else {
                [avatarImageView setImage:defaultAvatarImage];
            }

        }];
    } else {

        id <ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

        if ([avatarInArray isEqualToString:forumConfig.avatarNo]) {
            [avatarImageView setImage:defaultAvatarImage];
        } else {

            NSURL *avatarUrl = [NSURL URLWithString:avatarInArray];

            if (/* DISABLES CODE */ (NO)) {
                NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:avatarUrl];
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                NSLog(@"cache_image_path %@", cacheImagePath);
            }

            [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatarImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    [coreDateManager deleteData:^NSPredicate * {
                        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND userID = %@", self.currentForumHost, userId];
                    }];
                }
                //NSError * e = error;
            }];
        }
    }

}

- (id)init {
    if (self = [super init]) {

        [self setDrawerType:DrawerViewTypeLeft];

        [self initLeftDrawerView];
        [self setUpLeftDrawer];

        [self initMaskView];

        defaultAvatar = [UIImage imageNamed:@"defaultAvatar.gif"];

        UIScreenEdgePanGestureRecognizer *leftEdgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgePan:)];
        leftEdgePanRecognizer.edges = UIRectEdgeLeft;

        [self addGestureRecognizer:leftEdgePanRecognizer];

        [self setLeftDrawerEnadbled:YES];

        avatarCache = [NSMutableDictionary dictionary];


        coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
        if (cacheUsers == nil) {
            LocalForumApi *localeForumApi = [[LocalForumApi alloc] init];
            cacheUsers = (NSMutableArray<UserEntry *> *) [[coreDateManager selectData:^NSPredicate * {
                return [NSPredicate predicateWithFormat:@"forumHost = %@ AND userID > %d", localeForumApi.currentForumHost, 0];
            }] copy];
        }

        for (UserEntry *user in cacheUsers) {
            [avatarCache setValue:user.userAvatar forKey:user.userID];
        }

        [self showUserAvatar];

    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _haveLoginForums.count;
}


#pragma mark - 代理方法

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HaveLoginForum" owner:self options:nil];

    UITableViewCell *cell = nib.lastObject;

    Forums *forums = _haveLoginForums[(NSUInteger) indexPath.row];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    if ([forums.host isEqualToString:[localForumApi currentForumHost]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = forums.name;
    cell.detailTextLabel.text = forums.host;

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [cell setSeparatorInset:edgeInsets];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];


    Forums *forums = _haveLoginForums[(NSUInteger) indexPath.row];

    NSURL *url = [NSURL URLWithString:forums.url];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    [localForumApi saveCurrentForumURL:forums.url];

    LocalForumApi *forumApi = [[LocalForumApi alloc] init];

    [self closeLeftDrawer:^{
        [self showUserAvatar];
        if ([forumApi isHaveLogin:url.host]) {
            ForumTabBarController *rootViewController = (ForumTabBarController *) [[UIStoryboard mainStoryboard] finControllerById:@"ForumTabBarControllerId"];

            if ([url.host isEqualToString:@"bbs.smartisan.com"] || [localForumApi.currentForumHost containsString:@"chiphell.com"]) {
                [rootViewController changeMessageUITabController:vBulletin];
            } else {
                [rootViewController changeMessageUITabController:Discuz];
            }
            rootViewController.selectedIndex = 2;
            UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
            [storyboard changeRootViewControllerToController:rootViewController withAnim:UIViewAnimationOptionTransitionFlipFromRight];
        }
    }];


}


- (NSString *)currentForumHost {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *urlStr = [localForumApi currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (id)initWithDrawerType:(DrawerViewType)drawerType andXib:(NSString *)name {
    if (self = [super init]) {

        // 和 xib 绑定
        [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];

        [self setDrawerType:drawerType];


        switch (_drawerType) {
            case DrawerViewTypeLeft: {

                //_leftDrawerView = nibViews.firstObject;

                [self setUpLeftDrawer];

                [self setLeftDrawerEnadbled:YES];
                break;
            }
            case DrawerViewTypeRight: {

                //_rightDrawerView = nibViews.firstObject;
                [self setUpRightDrawer];
                [self setRightDrawerEnadbled:YES];
                break;
            }
            case DrawerViewTypeLeftAndRight: {

                //_leftDrawerView = nibViews.firstObject;
                [self setUpLeftDrawer];


                //_rightDrawerView = nibViews.lastObject;
                [self setUpRightDrawer];


                [self setLeftDrawerEnadbled:YES];
                [self setRightDrawerEnadbled:YES];
                break;
            }
        }

        [self initMaskView];

        [self showUserAvatar];

    }

    return self;
}

- (id)initWithDrawerType:(DrawerViewType)drawerType {

    if (self = [super init]) {

        [self setDrawerType:drawerType];

        switch (_drawerType) {
            case DrawerViewTypeLeft: {
                [self initLeftDrawerView];
                [self setUpLeftDrawer];

                [self setLeftDrawerEnadbled:YES];
                break;
            }
            case DrawerViewTypeRight: {

                [self initRightDrawerView];
                [self setUpRightDrawer];
                [self setRightDrawerEnadbled:YES];
                break;
            }
            case DrawerViewTypeLeftAndRight: {
                [self initLeftDrawerView];
                [self setUpLeftDrawer];


                [self initRightDrawerView];
                [self setUpRightDrawer];


                [self setLeftDrawerEnadbled:YES];
                [self setRightDrawerEnadbled:YES];
                break;
            }

            default: {

                [self initLeftDrawerView];
                [self setUpLeftDrawer];

                [self setLeftDrawerEnadbled:YES];
                break;
            }
        }

        [self initMaskView];
    }


    return self;
}

- (UIView *)findDrawerWithDrawerIndex:(DrawerIndex)type {
    return type == DrawerViewTypeLeft ? _leftDrawerView : _rightDrawerView;
}

- (void)didMoveToSuperview {

    UIView *rootView = [self superview];

    self.frame = CGRectMake(0, 0, kEdge, rootView.frame.size.height);

    //NSLog(@"didMoveToSuperview %f", rootView.frame.size.width);


    _drawerMaskView.frame = CGRectMake(0, 0, rootView.frame.size.width, rootView.frame.size.height);

    [rootView addSubview:_drawerMaskView];


    if (_drawerType != DrawerViewTypeLeft) {
        _rightEageView = [[UIView alloc] init];
        _rightEageView.frame = CGRectMake(rootView.frame.size.width - kEdge, 0, kEdge, rootView.frame.size.height);
        // _rightEageView.backgroundColor = [UIColor redColor];

        [rootView addSubview:_rightEageView];

        UIScreenEdgePanGestureRecognizer *rightedgePab = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgePan:)];
        rightedgePab.edges = UIRectEdgeRight;

        [_rightEageView addGestureRecognizer:rightedgePab];
    }


    CGFloat with = rootView.frame.size.width * kDefaultDrawerRatio;


    if (_drawerType != DrawerViewTypeRight) {
        // init Left Drawer
        _leftDrawerView.frame = CGRectMake(-with, 0, with, rootView.frame.size.height);
        [rootView addSubview:_leftDrawerView];

        if ([_delegate respondsToSelector:@selector(didDrawerMoveToSuperview:)]) {
            [_delegate didDrawerMoveToSuperview:DrawerIndexLeft];
        }


        UIScreenEdgePanGestureRecognizer *leftEdgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgePan:)];
        leftEdgePanRecognizer.edges = UIRectEdgeLeft;

        [self addGestureRecognizer:leftEdgePanRecognizer];

        NSArray *subViews = _leftDrawerView.subviews;

        int width = (int) self.frame.size.width;

        for (UIView *view in subViews) {
            if ([view isKindOfClass:[LeftDrawerItem class]]) {
                CGRect childFrame = view.frame;
                childFrame.size.width = width;
                view.frame = childFrame;

            }
        }
        //NSLog(@"左侧     %@", subViews);
    }

    if (_drawerType != DrawerViewTypeLeft) {
        // init right Drawer
        _rightDrawerView.frame = CGRectMake(rootView.frame.size.width, 0, with, rootView.frame.size.height);
        [rootView addSubview:_rightDrawerView];

        if ([_delegate respondsToSelector:@selector(didDrawerMoveToSuperview:)]) {
            [_delegate didDrawerMoveToSuperview:DrawerIndexRight];
        }
    }

    [rootView bringSubviewToFront:self];


    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    _haveLoginForums = localForumApi.loginedSupportForums;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollsToTop = NO;


}


- (void)openLeftDrawer:(Done)done {
    if (_leftDrawerView != nil && _leftDrawerEnadbled && !_leftDrawerOpened) {
        [self showLeftDrawerWithAdim:_leftDrawerView done:done];
    }
}

- (void)closeLeftDrawer:(Done)done {
    if (_leftDrawerView != nil && _leftDrawerEnadbled && _leftDrawerOpened) {
        [self hideLeftDrawerWithAnim:_leftDrawerView done:done];
    }
}

- (void)openRightDrawer:(Done)done {
    if (_rightDrawerView != nil && _rightDrawerEnadbled && !_rightDrawerOpened) {
        [self showRightDrawerWithAdim:_rightDrawerView done:done];
    }
}

- (void)closeRightDrawer:(Done)done {
    if (_rightDrawerView != nil && _rightDrawerEnadbled && _rightDrawerOpened) {
        [self hideRightDrawerWithAnim:_rightDrawerView done:done];
    }
}

- (void)openLeftDrawer {
    if (_leftDrawerView != nil && _leftDrawerEnadbled && !_leftDrawerOpened) {
        [self showLeftDrawerWithAdim:_leftDrawerView];
    }
}

- (void)closeLeftDrawer {
    if (_leftDrawerView != nil && _leftDrawerEnadbled && _leftDrawerOpened) {
        [self hideLeftDrawerWithAnim:_leftDrawerView];
    }
}

- (void)openRightDrawer {
    if (_rightDrawerView != nil && _rightDrawerEnadbled && !_rightDrawerOpened) {
        [self showRightDrawerWithAdim:_rightDrawerView];
    }
}

- (void)closeRightDrawer {
    if (_rightDrawerView != nil && _rightDrawerEnadbled && _rightDrawerOpened) {
        [self hideRightDrawerWithAnim:_rightDrawerView];
    }
}
- (IBAction)showPayController:(id)sender {
    [self closeLeftDrawer];

    ForumTabBarController *root = (ForumTabBarController *) self.window.rootViewController;

    UIViewController *controller = [[UIStoryboard mainStoryboard] finControllerById:@"ShowPayPage"];

    [root presentViewController:controller animated:YES completion:^{

    }];
}

- (IBAction)showAddForumController:(id)sender {
    [self closeLeftDrawer];

    ForumTabBarController *root = (ForumTabBarController *) self.window.rootViewController;


    UIViewController *controller = [[UIStoryboard mainStoryboard] finControllerById:@"ShowSetting"];


    [root presentViewController:controller animated:YES completion:^{

    }];
}

- (IBAction)showMyProfile:(id)sender {
    [self closeLeftDrawer];

    ForumTabBarController *root = (ForumTabBarController *) self.window.rootViewController;
    root.selectedIndex = 4;
}

- (void)bringDrawerToFront {
    [self.superview bringSubviewToFront:self];

    if (_drawerType == DrawerIndexLeft && _leftDrawerView) {
        [self.superview bringSubviewToFront:_leftDrawerView];
    }

    if (_drawerType == DrawerIndexRight && _rightDrawerView) {
        [self.superview bringSubviewToFront:_rightDrawerView];
    }

    if (_drawerType == DrawerViewTypeLeftAndRight && _leftDrawerView && _rightDrawerView) {
        [self.superview bringSubviewToFront:_leftDrawerView];
        [self.superview bringSubviewToFront:_rightDrawerView];
    }
}


- (void)showRightDrawerWithAdim:(UIView *)view done:(Done)done {
    [UIView animateWithDuration:0.2f animations:^{
        CGRect currentRect = view.frame;
        currentRect.origin.x = [view superview].frame.size.width - view.frame.size.width;

        view.frame = currentRect;
        _drawerMaskView.alpha = kMaxMaskAlpha;

        view.layer.shadowOpacity = 0.5f;
    }                completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(rightDrawerDidOpened)]) {
            [_delegate rightDrawerDidOpened];
        }
        [self setRightDrawerOpened:YES];

        if (done != nil) {done();}
    }];
}

- (void)showRightDrawerWithAdim:(UIView *)view {

    [self showRightDrawerWithAdim:view done:nil];

}

- (void)hideRightDrawerWithAnim:(UIView *)view done:(Done)done {
    [UIView animateWithDuration:0.2f animations:^{
        CGRect currentRect = view.frame;
        currentRect.origin.x = view.superview.frame.size.width;
        view.frame = currentRect;

        view.layer.shadowOpacity = 0.f;

        _drawerMaskView.alpha = 0.0f;
    }                completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(rightDrawerDidClosed)]) {
            [_delegate rightDrawerDidClosed];
        }
        [self setRightDrawerOpened:NO];
        if (done != nil) {done();}
    }];
}

- (void)hideRightDrawerWithAnim:(UIView *)view {

    [self hideRightDrawerWithAnim:view done:nil];
}


- (void)showLeftDrawerWithAdim:(UIView *)view done:(Done)done {
    [UIView animateWithDuration:0.2f animations:^{
        CGRect currentRect = view.frame;
        currentRect.origin.x = 0;
        view.frame = currentRect;

        _drawerMaskView.alpha = kMaxMaskAlpha;

        view.layer.shadowOpacity = 0.5f;
    }                completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(leftDrawerDidOpened)]) {
            [_delegate leftDrawerDidOpened];
        }

        [self setLeftDrawerOpened:YES];
    }];

    if (done != nil) {done();}
}

- (void)showLeftDrawerWithAdim:(UIView *)view {

    [self showLeftDrawerWithAdim:view done:nil];

}

- (void)hideLeftDrawerWithAnim:(UIView *)view done:(Done)done {
    [UIView animateWithDuration:0.2f animations:^{
        CGRect currentRect = view.frame;
        currentRect.origin.x = -view.frame.size.width;
        view.frame = currentRect;

        view.layer.shadowOpacity = 0.f;

        _drawerMaskView.alpha = 0.0f;
    }                completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(leftDrawerDidOpened)]) {
            [_delegate leftDrawerDidClosed];
        }
        [self setLeftDrawerOpened:NO];

        if (done != nil) {done();}
    }];
}

- (void)hideLeftDrawerWithAnim:(UIView *)view {

    [self hideLeftDrawerWithAnim:view done:nil];
}

- (void)initRightDrawerView {
    _rightDrawerView = [[UIView alloc] init];
}

- (void)setUpRightDrawer {

    _rightDrawerView.backgroundColor = [UIColor whiteColor];

    _rightDrawerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    // 阴影的透明度
    _rightDrawerView.layer.shadowOpacity = 0.f;
    //设置View Shadow的偏移量
    _rightDrawerView.layer.shadowOffset = CGSizeMake(-5.f, 0);

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(handleRightPan:)];
    [_rightDrawerView addGestureRecognizer:panGestureRecognizer];
}


- (void)initLeftDrawerView {

    _leftDrawerView = [[UIView alloc] init];
}

- (void)setUpLeftDrawer {


    _leftDrawerView.backgroundColor = [UIColor whiteColor];

    _leftDrawerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    // 阴影的透明度
    _leftDrawerView.layer.shadowOpacity = 0.f;
    //设置View Shadow的偏移量
    _leftDrawerView.layer.shadowOffset = CGSizeMake(5.f, 0);

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(handleLeftPan:)];
    [_leftDrawerView addGestureRecognizer:panGestureRecognizer];

}

- (void)initMaskView {
    _drawerMaskView = [[UIButton alloc] init];
    _drawerMaskView.backgroundColor = [UIColor blackColor];
    _drawerMaskView.alpha = 0.0f;

    [_drawerMaskView addTarget:self action:@selector(handleMaskClick) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *maskPan = [[UIPanGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(handleMaskPan:)];
    [_drawerMaskView addGestureRecognizer:maskPan];

}

- (void)handleMaskClick {
    if (_leftDrawerView != nil && _leftDrawerOpened && _leftDrawerEnadbled) {
        [self hideLeftDrawerWithAnim:_leftDrawerView];
    }

    if (_rightDrawerView != nil && _rightDrawerOpened && _rightDrawerEnadbled) {
        [self hideRightDrawerWithAnim:_rightDrawerView];
    }
}

- (void)handleLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    if (![self leftDrawerEnadbled]) {
        return;
    }

    if ([self rightDrawerOpened]) {
        [self hideRightDrawerWithAnim:_rightDrawerView];
    }


    [self handleLeftPan:recognizer];
}

- (void)handleRightEdgePan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    if (![self rightDrawerEnadbled]) {
        return;
    }

    if ([self leftDrawerOpened]) {
        [self hideLeftDrawerWithAnim:_leftDrawerView];
    }

    [self handleRightPan:recognizer];
}


- (void)handleLeftPan:(UIPanGestureRecognizer *)recognizer {

    if (![self leftDrawerEnadbled]) {
        return;
    }

    [self dragLeftDrawer:recognizer :^CGFloat(CGFloat x, CGFloat maxX) {
        return x > maxX ? maxX : x;
    }];
}

- (void)handleRightPan:(UIPanGestureRecognizer *)recognizer {

    if (![self rightDrawerEnadbled]) {
        return;
    }

    [self dragRightDrawer:recognizer :^CGFloat(CGFloat x, CGFloat maxX) {
        return x < maxX ? maxX : x;
    }];
}

- (void)handleMaskPan:(UIPanGestureRecognizer *)recognizer {

    if (_leftDrawerOpened) {

        [self dragLeftDrawer:recognizer :^CGFloat(CGFloat x, CGFloat maxX) {
            return x < maxX ? x : maxX;
        }];
    }

    if (_rightDrawerOpened) {
        [self dragRightDrawer:recognizer :^CGFloat(CGFloat x, CGFloat maxX) {
            return x < maxX ? maxX : x;
        }];
    }


}

- (void)showOrHideLeftAfterPan:(UIPanGestureRecognizer *)recognizer :(UIView *)view {

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];

        //NSLog(@"Touch ===   %f", velocity.x);

        if (velocity.x > 0) {
            [self showLeftDrawerWithAdim:view];
        } else {
            [self hideLeftDrawerWithAnim:view];
        }
    }
}

- (void)showOrHideRightAfterPan:(UIPanGestureRecognizer *)recognizer :(UIView *)view {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];

        //NSLog(@"Touch ===   %f", velocity.x);

        if (velocity.x > 0) {
            [self hideRightDrawerWithAnim:view];
        } else {
            [self showRightDrawerWithAdim:view];
        }
    }
}

- (void)dragRightDrawer:(UIPanGestureRecognizer *)recognizer :(TouchX)block {
    UIView *panView = [recognizer.view superview];

    CGPoint translation = [recognizer translationInView:panView];

    CGPoint currentCenter = _rightDrawerView.center;


    CGFloat x = currentCenter.x + translation.x;

    CGFloat maxX = panView.frame.size.width - _rightDrawerView.frame.size.width / 2;


    currentCenter.x = block(x, maxX);

    NSLog(@"dragRightDrawer %f             %f ", currentCenter.x, translation.x);

    _rightDrawerView.center = currentCenter;


    if (translation.x < 0) {
        _rightDrawerView.layer.shadowOpacity = 0.5f;
    }

    _drawerMaskView.alpha = (panView.frame.size.width - _rightDrawerView.center.x) / (_rightDrawerView.frame.size.width / 2) * kMaxMaskAlpha;

    [recognizer setTranslation:CGPointMake(0, 0) inView:panView];

    [self showOrHideRightAfterPan:recognizer :_rightDrawerView];
}

- (void)dragLeftDrawer:(UIPanGestureRecognizer *)recognizer :(TouchX)block {

    UIView *panView = [recognizer.view superview];

    CGPoint translation = [recognizer translationInView:panView];


    CGPoint currentCenter = _leftDrawerView.center;


    //NSLog(@"dragLeftDrawer %f             %f " , currentCenter.x, translation.x);


    CGFloat x = currentCenter.x + translation.x;

    CGFloat maxX = _leftDrawerView.frame.size.width / 2;

    //currentCenter.x = x < maxX ? x : maxX;
    currentCenter.x = block(x, maxX);

    _leftDrawerView.center = currentCenter;

    if (translation.x > 0) {
        _leftDrawerView.layer.shadowOpacity = 0.5f;
    }

    _drawerMaskView.alpha = (_leftDrawerView.center.x + maxX) / (maxX * 2) * kMaxMaskAlpha;

    [recognizer setTranslation:CGPointZero inView:panView];

    [self showOrHideLeftAfterPan:recognizer :_leftDrawerView];

}

@end
