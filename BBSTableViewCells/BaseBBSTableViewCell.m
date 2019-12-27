//
//  BaseFourmTableViewCell.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BaseBBSTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "BBSLocalApi.h"

#import "AssertReader.h"

@implementation BaseBBSTableViewCell {
    UIImage *defaultAvatarImage;

    BBSCoreDataManager *coreDateManager;
    id <BBSApiDelegate> _forumApi;

    NSMutableDictionary *avatarCache;

    NSMutableArray<UserEntry *> *cacheUsers;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

- (void)initData {

    defaultAvatarImage = [AssertReader no_avatar];

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    _forumApi = [BBSApiHelper forumApi:localForumApi.currentForumHost];

    avatarCache = [NSMutableDictionary dictionary];


    coreDateManager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    if (cacheUsers == nil) {
        cacheUsers = [[coreDateManager selectData:^NSPredicate * {
            return [NSPredicate predicateWithFormat:@"forumHost = %@ AND userID > %d", self.currentForumHost, 0];
        }] copy];
    }

    for (UserEntry *user in cacheUsers) {
        [avatarCache setValue:user.userAvatar forKey:user.userID];
    }
}


- (void)setData:(id)data {

}

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {

}

- (NSString *)currentForumHost {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *urlStr = [localForumApi currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)userId {

    // 不知道什么原因，userID可能是nil
    if (userId == nil) {
        [avatarImageView setImage:defaultAvatarImage];
        return;
    }
    NSString *avatarInArray = [avatarCache valueForKey:userId];

    if (avatarInArray == nil) {

        [_forumApi getAvatarWithUserId:userId handler:^(BOOL isSuccess, NSString *avatar) {

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

        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
        id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

        if ([avatarInArray isEqualToString:forumConfig.avatarNo]) {
            [avatarImageView setImage:defaultAvatarImage];
        } else {

            NSURL *avatarUrl = [NSURL URLWithString:avatarInArray];

            if (/* DISABLES CODE */ (NO)) {
                NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:avatarUrl];
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                NSLog(@"cache_image_path %@", cacheImagePath);
            }

            [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatarImage];
        }
    }

}
@end
