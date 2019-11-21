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
        _html = @"terms_of_use";
    } else if ([type isEqualToString:@"ShowPolicy"]) {
        _title = @"隐私政策";
        _html = @"privacy";
    } else if ([type isEqualToString:@"ShowMore"]) {
        _title = @"了解更多";
        _html = @"more";
    }
}


- (IBAction)close:(id)sender {

    UINavigationController *navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = _title;

    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    //self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

    for (UIView *view in [[self.webView subviews][0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
        }
    }
    [self.webView setOpaque:NO];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:_html ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSURL *url = [[NSURL alloc] initWithString:filePath];
    [self.webView loadHTMLString:htmlString baseURL:url];
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
