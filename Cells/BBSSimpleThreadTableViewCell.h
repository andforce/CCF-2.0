//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBBSTableViewCell.h"

@interface BBSSimpleThreadTableViewCell : BaseBBSTableViewCell

@property(weak, nonatomic) IBOutlet UILabel *threadAuthorName;
@property(weak, nonatomic) IBOutlet UILabel *lastPostTime;
@property(weak, nonatomic) IBOutlet UILabel *threadTitle;
@property(weak, nonatomic) IBOutlet UIImageView *ThreadAuthorAvatar;
@property(weak, nonatomic) IBOutlet UILabel *threadCategory;

- (IBAction)showUserProfile:(UIButton *)sender;

@end
