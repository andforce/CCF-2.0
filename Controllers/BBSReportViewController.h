//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "ForumApiBaseViewController.h"
#import "UIAutoResizeTextView.h"

@interface BBSReportViewController : ForumApiBaseViewController
- (IBAction)back:(id)sender;

- (IBAction)reportThreadPost:(id)sender;

@property(weak, nonatomic) IBOutlet UIAutoResizeTextView *reportMessage;

@end
