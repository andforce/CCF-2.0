//
//  WebViewController.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "WebViewController.h"
#import "ForumApi.h"
#import "PostFloor.h"

#import "ViewThreadPage.h"

#define S(f, ...) [NSString stringWithFormat:f,##__VA_ARGS__]

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


//    NSString *path = @"http://baidu.com";
//    NSURL *url = [[NSURL alloc] initWithString:path];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];

    ForumApi *api = [[ForumApi alloc] init];


    [api showThreadWithId:[@"1115335" intValue] andPage:1 handler:^(BOOL isSuccess, id message) {
        NSString *string = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] mutableCopy];
        ShowThreadPage *page = (ShowThreadPage *) message;


        NSArray<Post *> *list = page.dataList;

        NSString *postList = @"";
        for (Post *post in list) {
            postList = [postList stringByAppendingString:post.postContent];
        }


        string = [string stringByReplacingOccurrencesOfString:@"<span style=\"display:none\">##lists##</span>" withString:postList];

        NSData *htmlData = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

        [self.webView setScalesPageToFit:YES];
        self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
        //self.webView.delegate = self;
        self.webView.backgroundColor = [UIColor whiteColor];

        [self.webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"]];
    }];


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
