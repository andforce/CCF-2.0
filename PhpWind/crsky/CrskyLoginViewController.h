//
//  CrskyLoginViewController.h
//  Forum
//
//  Created by 迪远 王 on 2017/7/29.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "ForumApiBaseViewController.h"

@interface CrskyLoginViewController : ForumApiBaseViewController

@property(weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)cancelLogin:(id)sender;

@property(strong, nonatomic) IBOutlet UIView *maskLoadingView;

@end
