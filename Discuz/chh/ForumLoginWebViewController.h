//
// Created by 迪远 王 on 2017/5/7.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumApiBaseViewController.h"


@interface ForumLoginWebViewController : ForumApiBaseViewController

@property(weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)cancelLogin:(id)sender;

@property(weak, nonatomic) IBOutlet UIView *maskLoadingView;

@end
