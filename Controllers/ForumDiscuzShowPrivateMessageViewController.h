//
//  ForumShowPrivateMessageViewController.h
//
//  Created by 迪远 王 on 16/3/25.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseViewController.h"


@interface ForumDiscuzShowPrivateMessageViewController : ForumApiBaseViewController


@property(nonatomic, strong) NSMutableArray<ViewMessagePage *> *dataList;


- (IBAction)back:(id)sender;

@property(weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)replyPM:(id)sender;

@end
