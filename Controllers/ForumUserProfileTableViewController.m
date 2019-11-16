//
//  ForumUserProfileTableViewController.m
//
//  Created by 迪远 王 on 16/3/20.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumUserProfileTableViewController.h"
#import "ForumProfileTableViewCell.h"
#import "ForumUserThreadTableViewController.h"

#import <UIImageView+WebCache.h>
#import "UIStoryboard+Forum.h"
#import "LocalForumApi.h"

@interface ForumUserProfileTableViewController () <TransBundleDelegate> {

    UserProfile *userProfile;
    int userId;
    UIImage *defaultAvatarImage;
    ForumCoreDataManager *coreDateManager;
    id <ForumApiDelegate> _forumApi;
    NSMutableDictionary *avatarCache;
    NSMutableArray<UserEntry *> *cacheUsers;

}

@end

@implementation ForumUserProfileTableViewController

- (void)transBundle:(TransBundle *)bundle {
    userId = [bundle getIntValue:@"UserId"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    defaultAvatarImage = [UIImage imageNamed:@"defaultAvatar.gif"];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    _forumApi = [ForumApiHelper forumApi:localForumApi.currentForumHost];

    coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    avatarCache = [NSMutableDictionary dictionary];

    if (cacheUsers == nil) {
        cacheUsers = [[coreDateManager selectData:^NSPredicate * {

            LocalForumApi *localeForumApi = [[LocalForumApi alloc] init];
            return [NSPredicate predicateWithFormat:@"forumHost = %@ AND userID > %d", localeForumApi.currentForumHost, 0];
        }] copy];
    }

    for (UserEntry *user in cacheUsers) {
        [avatarCache setValue:user.userAvatar forKey:user.userID];
    }

}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (void)onPullRefresh {
    NSString *userIdString = [NSString stringWithFormat:@"%d", userId];
    [self.forumApi showProfileWithUserId:userIdString handler:^(BOOL isSuccess, UserProfile *message) {
        userProfile = message;

        [self.tableView.mj_header endRefreshing];


        [self showAvatar:self.userAvatar userId:userProfile.profileUserId];
        self.userName.text = userProfile.profileName;
        self.userRankName.text = userProfile.profileRank;
        self.userSignDate.text = userProfile.profileRegisterDate;
        self.userCurrentLoginDate.text = userProfile.profileRecentLoginDate;
        self.userPostCount.text = userProfile.profileTotalPostCount;

        [self.tableView reloadData];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

//
//#pragma mark - Table view data source
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return userProfile == nil ? 0 : 1;
    } else if (section == 1) {
        return 2;
    } else {
        return 3;
    }
}

#pragma mark 跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        ForumUserThreadTableViewController *controller = segue.destinationViewController;

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:userProfile forKey:@"UserProfile"];
        [self transBundle:bundle forController:controller];

    }

}

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)profileUserId {


    NSString *avatarInArray = [avatarCache valueForKey:profileUserId];

    if (avatarInArray == nil) {

        [_forumApi getAvatarWithUserId:profileUserId handler:^(BOOL isSuccess, NSString *avatar) {
            LocalForumApi *localeForumApi = [[LocalForumApi alloc] init];
            // 存入数据库
            [coreDateManager insertOneData:^(id src) {
                UserEntry *user = (UserEntry *) src;
                user.userID = profileUserId;
                user.userAvatar = avatar;
                user.forumHost = localeForumApi.currentForumHost;
            }];
            // 添加到Cache中
            [avatarCache setValue:avatar forKey:profileUserId];

            // 显示头像
            if (avatar == nil) {
                [avatarImageView setImage:defaultAvatarImage];
            } else {
                [avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:defaultAvatarImage];
            }
        }];
    } else {

        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
        id <ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

        if ([avatarInArray isEqualToString:forumConfig.avatarNo]) {
            [avatarImageView setImage:defaultAvatarImage];
        } else {
            NSURL *url = [NSURL URLWithString:avatarInArray];
            [avatarImageView sd_setImageWithURL:url placeholderImage:defaultAvatarImage];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.section == 1 && indexPath.row == 1) {
        UINavigationController *controller = (id) [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"CreatePM"];
        TransBundle *bundle = [[TransBundle alloc] init];
        User *user = [[User alloc] init];
        user.userID = userProfile.profileUserId;
        user.userName = userProfile.profileName;

        [bundle putObjectValue:user forKey:@"PROFILE_NAME"];

        [self presentViewController:(id) controller withBundle:bundle forRootController:YES animated:YES completion:^{

        }];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
