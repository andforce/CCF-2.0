//
//  ForumSupportNavigationController.m
//  Forum
//
//  Created by 迪远 王 on 2017/5/6.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "ForumSupportNavigationController.h"

@interface ForumSupportNavigationController ()

@end

@implementation ForumSupportNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

@end
