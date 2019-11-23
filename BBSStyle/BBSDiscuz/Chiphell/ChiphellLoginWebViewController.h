//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "BBSApiBaseViewController.h"


@interface ChiphellLoginWebViewController : BBSApiBaseViewController

@property(weak, nonatomic) IBOutlet WKWebView *webView;

- (IBAction)cancelLogin:(id)sender;

@property(weak, nonatomic) IBOutlet UIView *maskLoadingView;

@end
