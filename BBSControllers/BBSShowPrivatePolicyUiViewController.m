//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSShowPrivatePolicyUiViewController.h"

@interface BBSShowPrivatePolicyUiViewController () <TranslateDataDelegate> {
    NSString *_title;
    NSString *_html;
}

@end

@implementation BBSShowPrivatePolicyUiViewController

- (void)transBundle:(TranslateData *)bundle {

    NSString *type = [bundle getStringValue:@"ShowType"];
    NSLog(@"ShowType %@", type);

    if ([type isEqualToString:@"ShowTermsOfUse"]) {
        _title = @"使用条款";
        _html = @"use_terms_content";
    } else if ([type isEqualToString:@"ShowPolicy"]) {
        _title = @"隐私政策";
        _html = @"privacy_content";
    } else if ([type isEqualToString:@"ShowMore"]) {
        _title = @"了解更多";
        _html = @"more_about_content";
    }
}

- (IBAction)close:(id)sender {
    UINavigationController *navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = _title;

    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.backgroundColor = [UIColor whiteColor];

    [self.webView setOpaque:NO];

    NSURL *url = [[NSBundle mainBundle] URLForResource:_html withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
