//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSMyProfileTableViewController.h"
#import <UIImageView+WebCache.h>
#import "BBSCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "UIStoryboard+Forum.h"
#import "BBSTabBarController.h"
#import "BBSLocalApi.h"

#import "AssertReader.h"


@interface BBSMyProfileTableViewController () {
    CountProfile *userProfile;

    UIImage *defaultAvatarImage;

    BBSCoreDataManager *coreDateManager;

    NSMutableDictionary *avatarCache;

    NSMutableArray<UserEntry *> *cacheUsers;
}

@end

@implementation BBSMyProfileTableViewController

- (instancetype)init {
    if (self = [super init]) {
        [self initProfileData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initProfileData];
    }
    return self;
}

- (void)initProfileData {

    defaultAvatarImage = [AssertReader no_avatar];

    avatarCache = [NSMutableDictionary dictionary];


    coreDateManager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    if (cacheUsers == nil) {
        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
        cacheUsers = [[coreDateManager selectData:^NSPredicate * {
            return [NSPredicate predicateWithFormat:@"forumHost = %@ AND userID > %d", localForumApi.currentForumHost, 0];
        }] copy];
    }

    for (UserEntry *user in cacheUsers) {
        [avatarCache setValue:user.userAvatar forKey:user.userID];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [self.tableView setSeparatorInset:edgeInsets];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

- (BOOL)isNeedHideLeftMenu {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return NO;

}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}


- (void)onPullRefresh {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> config = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
    NSString *currentUserId = [[[BBSLocalApi alloc] init] getLoginUser:config.forumURL.host].userID;

    [self.forumApi showProfileWithUserId:currentUserId handler:^(BOOL isSuccess, CountProfile *message) {

        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            userProfile = message;

            [self showAvatar:_profileAvatar userId:userProfile.profileUserId];
            _profileName.text = userProfile.profileName;
            _profileRank.text = userProfile.profileRank;

            _registerDate.text = userProfile.profileRegisterDate;
            _lastLoginTime.text = userProfile.profileRecentLoginDate;
            _postCount.text = userProfile.profileTotalPostCount;
        }
    }];
}

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)userId {

    // 不知道什么原因，userID可能是nil
    if (userId == nil) {
        [avatarImageView setImage:defaultAvatarImage];
        return;
    }
    NSString *avatarInArray = [avatarCache valueForKey:userId];

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
    
    if (avatarInArray == nil || [avatarInArray isEqualToString:forumConfig.avatarNo]) {

        [self.forumApi getAvatarWithUserId:userId handler:^(BOOL isSuccess, NSString *avatar) {

            if (isSuccess) {
                BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 3 && indexPath.row == 0) {

        BBSLocalApi *forumApi = [[BBSLocalApi alloc] init];
        [forumApi logout];

        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
        id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
        NSString *id = forumConfig.loginControllerId;
        [[UIStoryboard mainStoryboard] changeRootViewControllerTo:id];

    } else if(indexPath.section == 4 && indexPath.row == 0){
        UIViewController *controller = [[UIStoryboard mainStoryboard] finControllerById:@"ShowPayPage"];

        [self presentViewController:controller animated:YES completion:^{

        }];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

- (IBAction)showLeftDrawer:(id)sender {
    BBSTabBarController *controller = (BBSTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}

@end
