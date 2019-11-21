//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "ForumApiBaseViewController.h"

@interface BBSWritePMViewController : ForumApiBaseViewController
- (IBAction)back:(id)sender;

@property(weak, nonatomic) IBOutlet UITextField *toWho;
@property(weak, nonatomic) IBOutlet UITextField *privateMessageTitle;
@property(weak, nonatomic) IBOutlet UITextView *privateMessageContent;

- (IBAction)sendPrivateMessage:(id)sender;

@end
