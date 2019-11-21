//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSSimpleThreadTableViewCell.h"

@implementation BBSSimpleThreadTableViewCell {
    NSIndexPath *selectIndexPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(Thread *)data {
    self.threadTitle.text = data.threadTitle;
    self.threadAuthorName.text = data.threadAuthorName;
    self.lastPostTime.text = data.lastPostTime;

    [self showAvatar:self.ThreadAuthorAvatar userId:data.threadAuthorID];
}

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    selectIndexPath = indexPath;
    [self setData:data];
}

- (void)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:selectIndexPath];
}

@end
