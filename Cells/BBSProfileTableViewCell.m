//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSProfileTableViewCell.h"

@implementation BBSProfileTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setData:(UserProfile *)data {
    self.profileRank.text = data.profileRank;
    self.profileUserName.text = data.profileName;
    [self showAvatar:self.profileAvatar userId:data.profileUserId];
}

@end
