//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSPayUITableViewController.h"
#import "BBSShowPrivatePolicyUiViewController.h"
#import "BBSPayManager.h"
#import "BBSLocalApi.h"
#import "ProgressDialog.h"

@interface BBSPayUITableViewController () {
    BBSLocalApi *_localForumApi;
    BBSPayManager *_payManager;
    IBOutlet UILabel *_restoreLabel;
}

@end

@implementation BBSPayUITableViewController

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
    _localForumApi = [[BBSLocalApi alloc] init];
    // payManager
    _payManager = [BBSPayManager shareInstance];
    
    [_payManager verifyPay:_localForumApi.currentProductID with:^(long timeHave) {

    }];

    if (self.canBack) {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"bbs_arrow_back_18pt"];
    } else {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"bbs_close_18pt"];
    }

    [self setExpTime];
}

-(void) setExpTime {
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
            [self setExpTime];
        } else {
            [ProgressDialog showError:@"解锁失败"];
        }
    }];

}

- (IBAction)restorePay:(id)sender {

    if ([_restoreLabel.text isEqualToString:@"恢复之前购买"]){
        [ProgressDialog show];

        [_payManager restorePayForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
            if (isSuccess) {
                [ProgressDialog showSuccess:@"恢复成功"];
                [self setExpTime];
            } else {
                [ProgressDialog showError:@"恢复失败"];
            }
        }];
    }

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
        BBSShowPrivatePolicyUiViewController *controller = segue.destinationViewController;

        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putStringValue:segue.identifier forKey:@"ShowType"];
        [self transBundle:bundle forController:controller];

    }
}

@end
