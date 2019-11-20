//
//  ForumPayUITableViewController.m
//  Forum
//
//  Created by WangDiyuan on 2018/2/28.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "ForumPayUITableViewController.h"
#import "ForumShowPrivatePolicyUiViewController.h"
#import "PayManager.h"
#import "LocalForumApi.h"
#import "ProgressDialog.h"

@interface ForumPayUITableViewController () {
    LocalForumApi *_localForumApi;
    PayManager *_payManager;
    IBOutlet UILabel *_restoreLabel;
}

@end

@implementation ForumPayUITableViewController

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

- (NSDate *)getLocalDateFormatAnyDate:(NSDate *)anyDate {
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSTimeZone *desTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [desTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _localForumApi = [[LocalForumApi alloc] init];
    // payManager
    _payManager = [PayManager shareInstance];
    
    [_payManager verifyPay:_localForumApi.currentProductID with:^(long timeHave) {

    }];

    if (self.canBack) {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_arrow_back_18pt"];
    } else {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_close_18pt"];
    }

    NSNumber *expTime = [_payManager getPayedExpireDate:[_localForumApi currentProductID]];
    long exptimeLong = [expTime intValue];
    if (exptimeLong != 0){
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:exptimeLong];
        NSDate *localDate = [self getLocalDateFormatAnyDate:date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设置格式：zzz表示时区
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        //NSDate转NSString
        NSString *currentDateString = [dateFormatter stringFromDate:localDate];
        _restoreLabel.text = [NSString stringWithFormat:@"高级功能到期:%@", currentDateString];
    } else {
        _restoreLabel.text = @"恢复之前购买";
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}


- (IBAction)pay:(UIBarButtonItem *)sender {

    [ProgressDialog show];

    [_payManager payForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess) {
            [ProgressDialog showSuccess:@"解锁成功"];
        } else {
            [ProgressDialog showError:@"解锁失败"];
        }
    }];

}

- (IBAction)restorePay:(id)sender {

    [ProgressDialog show];

    [_payManager restorePayForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess) {
            [ProgressDialog showSuccess:@"解锁成功"];
        } else {
            [ProgressDialog showError:@"解锁失败"];
        }
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:FALSE];

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self pay:nil];
        } else if (indexPath.row == 1) {
            [self restorePay:nil];
        }
    }
}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (BOOL)setPullRefresh:(BOOL)enable {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    }
    return 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *type = segue.identifier;
    if ([type isEqualToString:@"ShowTermsOfUse"] || [type isEqualToString:@"ShowPolicy"] || [type isEqualToString:@"ShowMore"]) {
        ForumShowPrivatePolicyUiViewController *controller = segue.destinationViewController;

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putStringValue:segue.identifier forKey:@"ShowType"];
        [self transBundle:bundle forController:controller];

    }
}

@end
