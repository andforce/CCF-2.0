//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumApiBaseViewController.h"


@interface ChiphellLoginWebViewController : ForumApiBaseViewController

@property(weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)cancelLogin:(id)sender;

@property(weak, nonatomic) IBOutlet UIView *maskLoadingView;

@end
