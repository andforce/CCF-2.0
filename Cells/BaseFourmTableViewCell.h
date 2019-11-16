//
//  BaseFourmTableViewCell.h
//
//  Created by 迪远 王 on 16/3/19.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "ForumApiHelper.h"
#import "TransValueUITableViewCell.h"


@interface BaseFourmTableViewCell : TransValueUITableViewCell

- (void)setData:(id)data;

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath;

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)userId;

@property(nonatomic, weak) NSIndexPath *selectIndexPath;

- (NSString *)currentForumHost;

@end
