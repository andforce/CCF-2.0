//
//  PayViewController.m
//  
//
//  Created by Diyuan Wang on 2019/11/21.
//

#import "BBSPayViewController.h"
#import "BBSPayManager.h"
#import "BBSLocalApi.h"
#import "BBSShowPrivatePolicyUiViewController.h"
#import "ProgressDialog.h"

@interface BBSPayViewController () {
    BBSLocalApi *_localForumApi;
    BBSPayManager *_payManager;

    IBOutlet UIButton *restorePayBtn;
}

@end

@implementation BBSPayViewController

- (IBAction)pay:(UIBarButtonItem *)sender {

    if ([_payManager hasPayed:_localForumApi.currentProductID]) {
        [ProgressDialog showSuccess:@"您已解锁"];
        return;
    }

    [ProgressDialog show];

    [_payManager payForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess) {
            [restorePayBtn setTitle:@"您已解锁" forState:UIControlStateNormal];
            [ProgressDialog showSuccess:@"解锁成功"];
        } else {
            [ProgressDialog showError:@"解锁失败"];
        }
    }];

}

- (IBAction)restorePay:(UIButton *)sender {

    if ([_payManager hasPayed:_localForumApi.currentProductID]) {
        [ProgressDialog showStatus:@"您已解锁"];
        return;
    }
    [ProgressDialog show];

    [_payManager restorePayForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess) {
            [restorePayBtn setTitle:@"您已解锁" forState:UIControlStateNormal];
            [ProgressDialog showSuccess:@"解锁成功"];
        } else {
            [ProgressDialog showError:@"解锁失败"];
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
    return self.navigationController.viewControllers.count > 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _localForumApi = [[BBSLocalApi alloc] init];
    // payManager
    _payManager = [BBSPayManager shareInstance];

    if ([_payManager hasPayed:_localForumApi.currentProductID]) {
        [restorePayBtn setTitle:@"您已解锁" forState:UIControlStateNormal];
    } else {
        [restorePayBtn setTitle:@"恢复之前的购买" forState:UIControlStateNormal];
    }

    if (self.canBack) {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"bbs_arrow_back_18pt"];
    } else {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"bbs_close_18pt"];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *type = segue.identifier;
    if ([type isEqualToString:@"ShowTermsOfUse"] || [type isEqualToString:@"ShowPolicy"]) {
        BBSShowPrivatePolicyUiViewController *controller = segue.destinationViewController;

        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putStringValue:segue.identifier forKey:@"ShowType"];
        [self transBundle:bundle forController:controller];

    }
}

@end
