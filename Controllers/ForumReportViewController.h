//
//  ForumReportViewController.h
//
//  Created by 迪远 王 on 2016/11/15.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiBaseViewController.h"
#import "UIAutoResizeTextView.h"

@interface ForumReportViewController : ForumApiBaseViewController
- (IBAction)back:(id)sender;

- (IBAction)reportThreadPost:(id)sender;

@property(weak, nonatomic) IBOutlet UIAutoResizeTextView *reportMessage;

@end
