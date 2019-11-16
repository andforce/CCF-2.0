//
//  ForumPrivateMessageTableViewController.h
//
//  Created by WDY on 16/3/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseTableViewController.h"


@interface ForumPrivateMessageTableViewController : ForumApiBaseTableViewController

- (IBAction)showLeftDrawer:(id)sender;

@property(weak, nonatomic) IBOutlet UISegmentedControl *messageSegmentedControl;

- (IBAction)writePrivateMessage:(UIBarButtonItem *)sender;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;

@end
