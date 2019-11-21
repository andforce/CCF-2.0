//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseViewController.h"


@interface BBSWebViewController : ForumApiBaseViewController
//@property(weak, nonatomic) IBOutlet UIWebView *webView;

@property(nonatomic, strong) UIImageView *animatedFromView;


- (IBAction)back:(UIBarButtonItem *)sender;

- (IBAction)showMoreAction:(UIBarButtonItem *)sender;

- (IBAction)changeNumber:(id)sender;

- (IBAction)reply:(id)sender;

@property(weak, nonatomic) IBOutlet UIButton *changePageButton;
@property(weak, nonatomic) IBOutlet UILabel *pageTitleTextView;

- (IBAction)firstPage:(id)sender;

- (IBAction)previousPage:(id)sender;

- (IBAction)lastPage:(id)sender;

- (IBAction)nextPage:(id)sender;

@property(strong, nonatomic) IBOutletCollection(UIVisualEffectView) NSArray *blurView;
@property(strong, nonatomic) IBOutlet UIView *bottomView;

@end
