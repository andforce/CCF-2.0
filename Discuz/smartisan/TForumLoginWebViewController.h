//
//  TForumLoginWebViewController.h
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "ForumApiBaseViewController.h"

@interface TForumLoginWebViewController : ForumApiBaseViewController

@property(weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)cancelLogin:(id)sender;

@property(strong, nonatomic) IBOutlet UIView *maskLoadingView;

@end
