//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSDataManager.h"
#import "Forum.h"

typedef NS_ENUM(NSInteger, EntryType) {
    EntryTypeForm = 0,
    EntryTypePost,
    EntryTypeUser

};


#pragma mark Form 相关
#define kFormEntry @"ForumEntry"
#define kFormXcda @"bbs_db"
#define kFormDBName @"bbs_db.sqlite"

#define kUserEntry @"UserEntry"

@interface BBSCoreDataManager : BBSDataManager

- (instancetype)initWithEntryType:(EntryType)enrty;

- (NSArray<Forum *> *)selectFavForums:(NSArray *)ids;

- (NSArray<Forum *> *)selectChildForumsById:(int)forumId;

- (NSArray<Forum *> *)selectAllForums;

@end
