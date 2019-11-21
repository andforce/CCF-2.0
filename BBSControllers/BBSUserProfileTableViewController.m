//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSUserProfileTableViewController.h"
#import "BBSProfileTableViewCell.h"
#import "BBSUserThreadTableViewController.h"

#import <UIImageView+WebCache.h>
#import "UIStoryboard+Forum.h"
#import "BBSLocalApi.h"

@interface BBSUserProfileTableViewController () <TranslateDataDelegate> {

    UserProfile *userProfile;
    int userId;
    UIImage *defaultAvatarImage;
    BBSCoreDataManager *coreDateManager;
    id <BBSApiDelegate> _forumApi;
    NSMutableDictionary *avatarCache;
    NSMutableArray<UserEntry *> *cacheUsers;

}

@end

@implementation BBSUserProfileTableViewController

- (void)transBundle:(TranslateData *)bundle {
    userId = [bundle getIntValue:@"UserId"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    defaultAvatarImage = [UIImage imageNamed:@"defaultAvatar.gif"];

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    _forumApi = [BBSApiHelper forumApi:localForumApi.currentForumHost];

    coreDateManager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    avatarCache = [NSMutableDictionary dictionary];

    if (cacheUsers == nil) {
        cacheUsers = [[coreDateManager selectData:^NSPredicate * {

            BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
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
        BBSUserThreadTableViewController *controller = segue.destinationViewController;

        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putObjectValue:userProfile forKey:@"UserProfile"];
        [self transBundle:bundle forController:controller];

    }

}

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)profileUserId {


    NSString *avatarInArray = [avatarCache valueForKey:profileUserId];

    if (avatarInArray == nil) {

        [_forumApi getAvatarWithUserId:profileUserId handler:^(BOOL isSuccess, NSString *avatar) {
            BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
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

        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
        id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

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
        TranslateData *bundle = [[TranslateData alloc] init];
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
