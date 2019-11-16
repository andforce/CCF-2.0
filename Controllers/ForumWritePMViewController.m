
//
//  ForumWritePMViewController.m
//
//  Created by 迪远 王 on 16/4/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumWritePMViewController.h"
#import "PayManager.h"
#import "LocalForumApi.h"
#import "UIStoryboard+Forum.h"
#import "ProgressDialog.h"


@interface ForumWritePMViewController () <TransBundleDelegate> {
    User *_toUser;
    BOOL isReply;
    LocalForumApi *_localForumApi;
    PayManager *_payManager;

    Message *_privateMessage;
}

@end


@implementation ForumWritePMViewController

// 上一Cotroller传递过来的数据
- (void)transBundle:(TransBundle *)bundle {
    if ([bundle containsKey:@"isReply"]) {
        isReply = YES;
        _privateMessage = [bundle getObjectValue:@"toReplyMessage"];

        _toUser = [[User alloc] init];
        _toUser.userName = _privateMessage.pmAuthor;
        _toUser.userID = _privateMessage.pmAuthorId;

    } else {
        _toUser = [bundle getObjectValue:@"PROFILE_NAME"];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];

    _localForumApi = [[LocalForumApi alloc] init];

    // payManager
    _payManager = [PayManager shareInstance];

    if (isReply) {
        self.toWho.text = _toUser.userName;
        self.privateMessageTitle.text = [NSString stringWithFormat:@"回复：%@", _privateMessage.pmTitle];
        [self.privateMessageContent becomeFirstResponder];
    } else {
        if (_toUser != nil) {
            self.toWho.text = _toUser.userName;
            [self.privateMessageTitle becomeFirstResponder];
        } else {
            [self.toWho becomeFirstResponder];
        }
    }

    self.toWho.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    if (![_payManager hasPayed:[_localForumApi currentProductID]]) {
        [self showFailedMessage:@"未订阅用户无法使用私信"];
    }
}

- (void)showFailedMessage:(id)message {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"操作受限" message:message preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *showPayPage = [UIAlertAction actionWithTitle:@"订阅" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        UIViewController *controller = [[UIStoryboard mainStoryboard] finControllerById:@"ShowPayPage"];

        [self presentViewController:controller animated:YES completion:^{

        }];

    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self dismissViewControllerAnimated:YES completion:^{

        }];

    }];

    [alert addAction:cancel];

    [alert addAction:showPayPage];


    [self presentViewController:alert animated:YES completion:^{

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)sendPrivateMessage:(id)sender {

    if ([self.toWho.text isEqualToString:@""]) {
        [ProgressDialog showError:@"无收件人"];
    } else if ([self.privateMessageTitle.text isEqualToString:@""]) {
        [ProgressDialog showError:@"无标题"];
    } else if ([self.privateMessageContent.text isEqualToString:@""]) {
        [ProgressDialog showError:@"无内容"];
    } else {

        [self.privateMessageContent resignFirstResponder];

        [ProgressDialog showStatus:@"正在发送"];

        if (isReply) {

            [self.forumApi replyPrivateMessage:_privateMessage andReplyContent:self.privateMessageContent.text handler:^(BOOL isSuccess, id message) {
                [ProgressDialog dismiss];

                if (isSuccess) {
                    [self dismissViewControllerAnimated:YES completion:^{

                    }];
                } else {
                    [ProgressDialog showError:message];
                }
            }];
        } else {
            [self.forumApi sendPrivateMessageTo:_toUser andTitle:self.privateMessageTitle.text andMessage:self.privateMessageContent.text handler:^(BOOL isSuccess, id message) {

                [ProgressDialog dismiss];

                if (isSuccess) {
                    [self dismissViewControllerAnimated:YES completion:^{

                    }];
                } else {
                    [ProgressDialog showError:message];
                }

            }];
        }

    }
}

@end
