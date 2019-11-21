//
//  BaseFourmTableViewCell.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "BBSApiHelper.h"
#import "TranslateDataTableViewCell.h"


@interface BaseBBSTableViewCell : TranslateDataTableViewCell

- (void)setData:(id)data;

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath;

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)userId;

@property(nonatomic, weak) NSIndexPath *selectIndexPath;

- (NSString *)currentForumHost;

@end
