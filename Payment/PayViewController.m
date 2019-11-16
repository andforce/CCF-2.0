//
//  PayViewController.m
//  
//
//  Created by 迪远 王 on 2017/12/24.
//

#import "PayViewController.h"
#import "PayManager.h"
#import "LocalForumApi.h"
#import "ForumShowPrivatePolicyUiViewController.h"
#import "ProgressDialog.h"

@interface PayViewController () {
    LocalForumApi *_localForumApi;
    PayManager *_payManager;

    IBOutlet UIButton *restorePayBtn;
}

@end

@implementation PayViewController

- (IBAction)pay:(UIBarButtonItem *)sender {

    if ([_payManager hasPayed:_localForumApi.currentProductID]) {
        [ProgressDialog showSuccess:@"您已订阅"];
        return;
    }

    [ProgressDialog show];

    [_payManager payForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess) {
            [restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
            [ProgressDialog showSuccess:@"订阅成功"];
        } else {
            [ProgressDialog showError:@"订阅失败"];
        }
    }];

}

- (IBAction)restorePay:(UIButton *)sender {

    if ([_payManager hasPayed:_localForumApi.currentProductID]) {
        [ProgressDialog showStatus:@"您已订阅"];
        return;
    }
    [ProgressDialog show];

    [_payManager restorePayForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess) {
            [restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
            [ProgressDialog showSuccess:@"订阅成功"];
        } else {
            [ProgressDialog showError:@"订阅失败"];
        }
    }];
}

- (IBAction)backOrDismiss:(UIBarButtonItem *)sender {
    [_payManager removeTransactionObserver];

    if (self.canBack) {
        UINavigationController *navigationController = self.navigationController;
        [navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)canBack {
//    UIViewController * c = self.navigationController.presentingViewController;
//    return c != nil;
//    return self.navigationController.topViewController == self;

    return self.navigationController.viewControllers.count > 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _localForumApi = [[LocalForumApi alloc] init];
    // payManager
    _payManager = [PayManager shareInstance];

    if ([_payManager hasPayed:_localForumApi.currentProductID]) {
        [restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
    } else {
        [restorePayBtn setTitle:@"恢复之前的订阅" forState:UIControlStateNormal];
    }

    if (self.canBack) {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_arrow_back_18pt"];
    } else {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_close_18pt"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *type = segue.identifier;
    if ([type isEqualToString:@"ShowTermsOfUse"] || [type isEqualToString:@"ShowPolicy"]) {
        ForumShowPrivatePolicyUiViewController *controller = segue.destinationViewController;

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putStringValue:segue.identifier forKey:@"ShowType"];
        [self transBundle:bundle forController:controller];

    }
}

@end
