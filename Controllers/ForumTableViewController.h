//
//  ForumTableViewController.h
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiBaseTableViewController.h"

@interface ForumTableViewController : ForumApiBaseTableViewController
- (IBAction)showLeftDrawer:(id)sender;

- (void)showControllerByShortCutItemType:(NSString *)shortCutItemType;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;

@end
