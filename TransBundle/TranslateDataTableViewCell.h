//
//  TransValueUITableViewCell.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeTableCellWithIndexPath.h"

@protocol ThreadListCellDelegate <NSObject>

@required
- (void)showUserProfile:(NSIndexPath *)indexPath;

@end


@interface TranslateDataTableViewCell : SwipeTableCellWithIndexPath

@property(weak, nonatomic) id <ThreadListCellDelegate> showUserProfileDelegate;

@end
