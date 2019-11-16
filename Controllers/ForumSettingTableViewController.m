//
//  ForumSettingTableViewController.m
//
//  Created by 迪远 王 on 16/4/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSettingTableViewController.h"
#import "NSUserDefaults+Setting.h"

@interface ForumSettingTableViewController ()

@property(strong, nonatomic) IBOutlet UILabel *version;

@end

@implementation ForumSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self.signatureSwitch setOn:[NSUserDefaults standardUserDefaults].isSignatureEnabled];
    [self.topThreadPostSwitch setOn:[NSUserDefaults standardUserDefaults].isTopThreadPostCanShow];

    NSString *versionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    _version.text = versionCode;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 2 && indexPath.row == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/andforce/Forum"]];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 5;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (IBAction)back:(UIBarButtonItem *)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchSignature:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setSignature:sender.isOn];
}

- (IBAction)switchTopThread:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setTopThreadPost:sender.isOn];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
