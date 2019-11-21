//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSThreadListCell.h"
#import "BBSLocalApi.h"

@implementation BBSThreadListCell {

    ForumCoreDataManager *_coreDateManager;
    id <BBSApiDelegate> _forumApi;
    NSIndexPath *selectIndexPath;
}

@synthesize threadAuthor = _threadAuthor;
@synthesize threadPostCount = _threadPostCount;
@synthesize threadTitle = _threadTitle;
@synthesize threadCreateTime = _threadCreateTime;
@synthesize threadType = _threadType;
@synthesize avatarImage = _avatarImage;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {

        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
        _forumApi = [BBSApiHelper forumApi:localForumApi.currentForumHost];
        _coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];

        [self.avatarImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
        self.avatarImage.contentMode = UIViewContentModeScaleAspectFit;
        self.avatarImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.avatarImage.clipsToBounds = YES;

    }
    return self;
}

- (void)setData:(Thread *)data {
    self.threadAuthor.text = data.threadAuthorName;

    self.threadPostCount.text = data.postCount;
    self.threadOpenCount.text = data.openCount;
    self.threadCreateTime.text = data.lastPostTime;

    self.threadTopFlag.hidden = !data.isTopThread;


    self.threadContainsImage.hidden = !data.isContainsImage;

    if (data.isGoodNess) {
        NSString *goodNessTitle = [@"[精]" stringByAppendingString:data.threadTitle];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:goodNessTitle];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 3)];

        self.threadTitle.attributedText = attrStr;
    } else {
        self.threadTitle.text = data.threadTitle;
    }
    [self showAvatar:self.avatarImage userId:data.threadAuthorID];
}

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    selectIndexPath = indexPath;
    [self setData:data];
}

- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:selectIndexPath];
}
@end
