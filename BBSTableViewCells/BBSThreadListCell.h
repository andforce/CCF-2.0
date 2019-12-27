//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBBSTableViewCell.h"


@interface BBSThreadListCell : BaseBBSTableViewCell


@property(weak, nonatomic) IBOutlet UILabel *threadAuthor;
@property(weak, nonatomic) IBOutlet UILabel *threadTitle;
@property(weak, nonatomic) IBOutlet UILabel *threadPostCount;
@property(weak, nonatomic) IBOutlet UILabel *threadOpenCount;
@property(weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property(weak, nonatomic) IBOutlet UILabel *threadCreateTime;
@property(weak, nonatomic) IBOutlet UILabel *threadType;
@property(weak, nonatomic) IBOutlet UILabel *threadTopFlag;
@property(weak, nonatomic) IBOutlet UIImageView *threadContainsImage;


- (IBAction)showUserProfile:(UIButton *)sender;

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath;
@end
