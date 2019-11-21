//  DRL
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "ForumApiBaseTableViewController.h"

@interface BBSTableViewController : ForumApiBaseTableViewController
- (IBAction)showLeftDrawer:(id)sender;

- (void)showControllerByShortCutItemType:(NSString *)shortCutItemType;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;

@end
