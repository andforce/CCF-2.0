//
// Created by 迪远 王 on 2018/3/4.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "ProgressDialog.h"


@implementation ProgressDialog {

}
+ (void)show {
    [self initHUD];
    [SVProgressHUD show];
}

+ (void)dismiss {
    [SVProgressHUD dismiss];
}


+ (void)initHUD {
    [SVProgressHUD setMinimumSize:CGSizeMake(100.0, 100.0)];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMaximumDismissTimeInterval:1];
    [SVProgressHUD setMaximumDismissTimeInterval:1];
}

+ (void)showStatus:(NSString *)message {
    [self initHUD];
    [SVProgressHUD showWithStatus:message];
}

+ (void)showError:(NSString *)message {
    [self initHUD];
    [SVProgressHUD showErrorWithStatus:message];
}

+ (void)showSuccess:(NSString *)message {
    [self initHUD];
    [SVProgressHUD showSuccessWithStatus:message];
}


@end