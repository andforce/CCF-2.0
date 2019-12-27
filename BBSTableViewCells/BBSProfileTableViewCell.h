//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BaseBBSTableViewCell.h"

@interface BBSProfileTableViewCell : BaseBBSTableViewCell
@property(weak, nonatomic) IBOutlet UIImageView *profileAvatar;
@property(weak, nonatomic) IBOutlet UILabel *profileUserName;
@property(weak, nonatomic) IBOutlet UILabel *profileRank;

@end
