//
//  ForumApiBaseTableViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/3/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ForumApi.h"
#import "MJRefresh.h"
#import "UITableView+FDTemplateLayoutCell.h"

#import "vBulletinForumEngine.h"
#import "TranBundleUITableViewController.h"

@interface ForumApiBaseTableViewController : TranBundleUITableViewController

@property(nonatomic, strong) ForumApi *ccfApi;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) int currentPage;
@property(nonatomic, assign) int totalPage;


- (void)onPullRefresh;


- (void)onLoadMore;

- (BOOL)setPullRefresh:(BOOL)enable;

- (BOOL)setLoadMore:(BOOL)enable;

- (BOOL)autoPullfresh;
@end
