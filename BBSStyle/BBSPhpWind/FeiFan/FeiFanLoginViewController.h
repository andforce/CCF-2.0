//
//  CrskyLoginViewController.h
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSApiBaseViewController.h"

#import <WebKit/WebKit.h>

@interface FeiFanLoginViewController : BBSApiBaseViewController

@property(weak, nonatomic) IBOutlet WKWebView *webView;

- (IBAction)cancelLogin:(id)sender;

@property(strong, nonatomic) IBOutlet UIView *maskLoadingView;

@end
