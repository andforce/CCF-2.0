//
//  DiscuzMessageTableViewController.h
//  Forum
//
//  Created by 迪远 王 on 2018/4/30.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "ForumApiBaseTableViewController.h"

@interface DiscuzMessageTableViewController : ForumApiBaseTableViewController

- (IBAction)showLeftDrawer:(id)sender;

@property(weak, nonatomic) IBOutlet UISegmentedControl *messageSegmentedControl;

- (IBAction)writePrivateMessage:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;


@end
