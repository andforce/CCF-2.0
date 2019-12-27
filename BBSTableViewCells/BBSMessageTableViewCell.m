//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSMessageTableViewCell.h"

@implementation BBSMessageTableViewCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {

        UIEdgeInsets edgeInset = self.separatorInset;
        edgeInset.left = 40 + 8 + 8;
        [self setSeparatorInset:edgeInset];

    }
    return self;
}

- (void)setData:(BBSPrivateMessage *)data {


    [self.privateMessageTitle setText:data.pmTitle];
    if (!data.isReaded) {
        self.privateMessageTitle.font = [UIFont boldSystemFontOfSize:17.0];
        self.privateMessageTitle.textColor = [UIColor blackColor];
    } else {
        self.privateMessageTitle.font = [UIFont fontWithName:@"Helvetica Neue" size:17.0];
        self.privateMessageTitle.textColor = [UIColor grayColor];
    }


    [self.privateMessageAuthor setText:data.pmAuthor];
    [self.privateMessageTime setText:data.pmTime];
    [self showAvatar:self.privateMessageAuthorAvatar userId:data.pmAuthorId];

}

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    self.selectIndexPath = indexPath;
    [self setData:data];
}

- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:self.selectIndexPath];
}
@end
