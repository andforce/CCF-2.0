//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSBaseStaticTableViewController.h"

@interface BBSMyProfileTableViewController : BBSBaseStaticTableViewController

- (IBAction)showLeftDrawer:(id)sender;

@property(weak, nonatomic) IBOutlet UILabel *profileName;


@property(weak, nonatomic) IBOutlet UIImageView *profileAvatar;
@property(weak, nonatomic) IBOutlet UILabel *profileRank;


@property(weak, nonatomic) IBOutlet UILabel *registerDate;
@property(weak, nonatomic) IBOutlet UILabel *lastLoginTime;

@property(weak, nonatomic) IBOutlet UILabel *postCount;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;

@end
