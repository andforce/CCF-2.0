//
//  CrskyLoginViewController.h
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "ForumApiBaseViewController.h"

@interface FeiFanLoginViewController : ForumApiBaseViewController

@property(weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)cancelLogin:(id)sender;

@property(strong, nonatomic) IBOutlet UIView *maskLoadingView;

@end
