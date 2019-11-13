//
//  ForumApiBaseTableViewController.m
//
//  Created by 迪远 王 on 16/3/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiBaseTableViewController.h"
#import "LocalForumApi.h"

@interface ForumApiBaseTableViewController () {
    BOOL disablePullrefresh;

    BOOL disableLoadMore;
}

@end

@implementation ForumApiBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    if ([self setPullRefresh:YES]) {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self onPullRefresh];
        }];

        if ([self autoPullfresh]) {
            [self.tableView.mj_header beginRefreshing];
        }
    }


    if ([self setLoadMore:YES]) {
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [self onLoadMore];
        }];
    }
}

- (BOOL)isNeedHideLeftMenu {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return ![bundleId isEqualToString:@"com.andforce.forums"];

}

- (void)onPullRefresh {

}

- (void)onLoadMore {

}

- (BOOL)autoPullfresh {
    return YES;
}

- (NSString *)currentForumHost {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString * urlStr = [localForumApi currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}


- (BOOL)setPullRefresh:(BOOL)enable {
    return YES;
}

- (BOOL)setLoadMore:(BOOL)enable {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

#pragma mark initData

- (void)initData {

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    self.forumApi = [ForumApiHelper forumApi:localForumApi.currentForumHost];
    self.dataList = [[NSMutableArray alloc] init];
}


#pragma mark override-init

- (instancetype)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithCoder

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithName

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithStyle

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-numberOfRowsInSection

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
