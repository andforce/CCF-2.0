//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSString+Extensions.h"
#import "UIImageView+AFNetworking.h"
#import "BBSCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "BBSApiHelper.h"
#import "BaseBBSTableViewCell.h"

@interface BBSMessageTableViewCell : BaseBBSTableViewCell

@property(weak, nonatomic) IBOutlet UILabel *privateMessageTitle;
@property(weak, nonatomic) IBOutlet UILabel *privateMessageAuthor;
@property(weak, nonatomic) IBOutlet UILabel *privateMessageTime;
@property(weak, nonatomic) IBOutlet UIImageView *privateMessageAuthorAvatar;

- (IBAction)showUserProfile:(UIButton *)sender;

@end
