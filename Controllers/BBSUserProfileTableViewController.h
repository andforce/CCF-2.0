//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "ForumApiBaseTableViewController.h"

@interface BBSUserProfileTableViewController : ForumApiBaseTableViewController

@property(weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property(weak, nonatomic) IBOutlet UILabel *userName;
@property(weak, nonatomic) IBOutlet UILabel *userRankName;
@property(weak, nonatomic) IBOutlet UILabel *userSignDate;
@property(weak, nonatomic) IBOutlet UILabel *userCurrentLoginDate;
@property(weak, nonatomic) IBOutlet UILabel *userPostCount;


- (IBAction)back:(id)sender;

@end
