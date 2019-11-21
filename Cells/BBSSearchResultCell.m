//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSSearchResultCell.h"


@implementation BBSSearchResultCell {
    NSIndexPath *selectIndexPath;
}


- (void)setData:(Thread *)data {


    self.postTitle.text = data.threadTitle;
    self.postAuthor.text = data.threadAuthorName;
    self.postTime.text = data.lastPostTime;
    self.postBelongForm.text = data.fromFormName;

    [self showAvatar:self.postAuthorAvatar userId:data.threadAuthorID];
}


- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    selectIndexPath = indexPath;
    [self setData:data];
}

- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:selectIndexPath];
}

@end
