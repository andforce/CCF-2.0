//
//  ForumFavFormController.h
//
//  Created by 迪远 王 on 16/1/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseTableViewController.h"

@interface ForumFavFormController : ForumApiBaseTableViewController

- (IBAction)showLeftDrawer:(id)sender;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;

@end
