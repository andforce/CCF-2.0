//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSLoginViewController.h"
#import "AppDelegate.h"

#import "UIStoryboard+Forum.h"
#import "BBSCoreDataManager.h"
#import "ForumEntry+CoreDataClass.h"
#import "BBSLocalApi.h"
#import "ProgressDialog.h"

@interface BBSLoginViewController () <UITextFieldDelegate> {

    CGRect screenSize;

    id <BBSApiDelegate> _forumApi;

}

@end

@implementation BBSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    _userName.delegate = self;
    _password.delegate = self;
    _vCode.delegate = self;

    if (@available(iOS 13.0, *)) {
        _userName.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        _password.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        _vCode.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    _userName.returnKeyType = UIReturnKeyNext;
    _password.returnKeyType = UIReturnKeyNext;
    _vCode.returnKeyType = UIReturnKeyDone;
    _password.keyboardType = UIKeyboardTypeASCIICapable;


    screenSize = [UIScreen mainScreen].bounds;

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    _forumApi = [BBSApiHelper forumApi:localForumApi.currentForumHost];

    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

    self.rootView.backgroundColor = forumConfig.themeColor;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [_forumApi refreshVCodeToUIImageView:_doorImageView];

    self.title = [forumConfig.forumURL.host uppercaseString];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)isNeedHideLeftMenu {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return NO;
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if ([string isEqualToString:@""] || string == nil) {
        return YES;
    }

    if (_vCode == textField){
        char commitChar = (char) [string characterAtIndex:0];

        if (commitChar > 96 && commitChar < 123) {

            //小写变成大写

            NSString *uppercaseString = string.uppercaseString;

            NSString *str1 = [textField.text substringToIndex:range.location];

            NSString *str2 = [textField.text substringFromIndex:range.location];

            textField.text = [NSString stringWithFormat:@"%@%@%@", str1, uppercaseString, str2];

            return NO;

        }
    }

    return YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _userName) {
        [_password becomeFirstResponder];
    } else if (_password == textField) {
        [_vCode becomeFirstResponder];
    } else {
        [self login:self];
    }
    return YES;
}

#pragma mark KeynboardNotification

- (void)keyboardWillShow:(id)sender {
    CGRect keyboardFrame;
    [[((NSNotification *) sender) userInfo][UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];

    CGRect focusedFrame = _loginBackgroundView.frame;
    int bottom = (int) (focusedFrame.origin.y + CGRectGetHeight(focusedFrame) + self.rootView.frame.origin.y) + 20;

    int keyboardTop = (int) (CGRectGetHeight(screenSize) - CGRectGetHeight(keyboardFrame));

    if (bottom >= keyboardTop) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.rootView.frame;
            frame.origin.y -= (bottom - keyboardTop) + 50;
            self.rootView.frame = frame;
        }];
    }

}

- (void)keyboardWillHide:(id)sender {
    CGRect keyboardFrame;

    [[((NSNotification *) sender) userInfo][UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];


    if (self.rootView.frame.origin.y != 0) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.rootView.frame;
            frame.origin.y = 0;
            self.rootView.frame = frame;
        }];
    }
}


- (IBAction)login:(id)sender {


    NSString *name = _userName.text;
    NSString *password = _password.text;
    NSString *code = _vCode.text;

    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    [_vCode resignFirstResponder];

    if ([name isEqualToString:@""] || [password isEqualToString:@""]) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"\n用户名或密码为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];

        [alert addAction:action];

        [self presentViewController:alert animated:YES completion:nil];

        return;
    }

    [ProgressDialog showStatus:@"正在登录"];

    [_forumApi loginWithName:name andPassWord:password withCode:code question:nil answer:nil handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {

            [_forumApi listAllForums:^(BOOL success, id msg) {


                [ProgressDialog dismiss];
                if (success) {
                    NSMutableArray<Forum *> *needInsert = msg;
                    BBSCoreDataManager *formManager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeForm];
                    // 需要先删除之前的老数据
                    [formManager deleteData:^NSPredicate * {
                        return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
                    }];

                    BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];

                    [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
                        ForumEntry *newsInfo = (ForumEntry *) target;
                        newsInfo.forumId = [src valueForKey:@"forumId"];
                        newsInfo.forumName = [src valueForKey:@"forumName"];
                        newsInfo.parentForumId = [src valueForKey:@"parentForumId"];
                        newsInfo.forumHost = localeForumApi.currentForumHost;

                    }];

                    UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
                    [stortboard changeRootViewControllerTo:kForumTabBarControllerId];

                }

            }];


        } else {
            [ProgressDialog dismiss];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];

            [alert addAction:action];

            [self presentViewController:alert animated:YES completion:nil];
        }
    }];

}


- (IBAction)refreshDoor:(id)sender {
    [_forumApi refreshVCodeToUIImageView:_doorImageView];
}

- (IBAction)cancelLogin:(id)sender {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    [localForumApi logout];
    NSString *bundleId = [localForumApi bundleIdentifier];

    [localForumApi clearCurrentForumURL];
    [[UIStoryboard mainStoryboard] changeRootViewControllerTo:@"ShowSupportForums" withAnim:UIViewAnimationOptionTransitionFlipFromTop];
}

- (void)exitApplication {
    AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotationAnimation.delegate = self;

    rotationAnimation.fillMode = kCAFillModeForwards;

    rotationAnimation.removedOnCompletion = NO;
    //旋转角度
    rotationAnimation.toValue = @((float) (M_PI / 2));
    //每次旋转的时间（单位秒）
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
    rotationAnimation.repeatCount = 0;
    [window.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
