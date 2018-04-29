//
//  ForumMyProfileTableViewController.h
//
//  Created by 迪远 王 on 16/10/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumBaseStaticTableViewController.h"

// 我的页面

@interface ForumMyProfileTableViewController : ForumBaseStaticTableViewController

- (IBAction)showLeftDrawer:(id)sender;

@property(weak, nonatomic) IBOutlet UILabel *profileName;


@property(weak, nonatomic) IBOutlet UIImageView *prifileAvatar;
@property(weak, nonatomic) IBOutlet UILabel *profileRank;


@property(weak, nonatomic) IBOutlet UILabel *registerDate;
@property(weak, nonatomic) IBOutlet UILabel *lastLoginTime;

@property(weak, nonatomic) IBOutlet UILabel *postCount;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;

@end
