//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSReportViewController.h"
#import "ProgressDialog.h"

@interface BBSReportViewController () <TranslateDataDelegate> {
    NSString *userName;
    int postId;
}

@end

@implementation BBSReportViewController

- (void)transBundle:(TranslateData *)bundle {
    userName = [bundle getStringValue:@"POST_USER"];
    postId = [bundle getIntValue:@"POST_ID"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.reportMessage becomeFirstResponder];
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reportThreadPost:(id)sender {
    [self.reportMessage resignFirstResponder];
    [ProgressDialog showStatus:@"请等待..."];

    if (userName == nil || postId == 0) {

        [ProgressDialog showSuccess:@"已经举报给管理员"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.forumApi reportThreadPost:postId andMessage:self.reportMessage.text handler:^(BOOL isSuccess, id message) {
            [ProgressDialog showSuccess:@"已经举报给管理员"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }

}
@end
