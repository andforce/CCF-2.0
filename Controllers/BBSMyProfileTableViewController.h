//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumBaseStaticTableViewController.h"

// 我的页面

@interface BBSMyProfileTableViewController : ForumBaseStaticTableViewController

- (IBAction)showLeftDrawer:(id)sender;

@property(weak, nonatomic) IBOutlet UILabel *profileName;


@property(weak, nonatomic) IBOutlet UIImageView *prifileAvatar;
@property(weak, nonatomic) IBOutlet UILabel *profileRank;


@property(weak, nonatomic) IBOutlet UILabel *registerDate;
@property(weak, nonatomic) IBOutlet UILabel *lastLoginTime;

@property(weak, nonatomic) IBOutlet UILabel *postCount;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;

@end
