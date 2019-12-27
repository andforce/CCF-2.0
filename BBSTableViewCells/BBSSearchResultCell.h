//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBBSTableViewCell.h"


@interface BBSSearchResultCell : BaseBBSTableViewCell


@property(weak, nonatomic) IBOutlet UILabel *postTitle;
@property(weak, nonatomic) IBOutlet UILabel *postAuthor;
@property(weak, nonatomic) IBOutlet UILabel *postTime;
@property(weak, nonatomic) IBOutlet UILabel *postBelongForm;
@property(weak, nonatomic) IBOutlet UIImageView *postAuthorAvatar;

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath;

- (IBAction)showUserProfile:(UIButton *)sender;

@end
