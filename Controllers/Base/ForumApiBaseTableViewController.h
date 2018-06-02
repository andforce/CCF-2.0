//
//  ForumApiBaseTableViewController.h
//
//  Created by 迪远 王 on 16/3/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ForumApiHelper.h"
#import "MJRefresh.h"

#import "TranBundleUITableViewController.h"

@interface ForumApiBaseTableViewController : TranBundleUITableViewController

@property(nonatomic, strong) id<ForumApiDelegate> forumApi;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) PageNumber *pageNumber;

- (void)onPullRefresh;

- (void)onLoadMore;

- (BOOL)setPullRefresh:(BOOL)enable;

- (BOOL)setLoadMore:(BOOL)enable;

- (BOOL)autoPullfresh;

- (NSString *)currentForumHost;

- (BOOL) isNeedHideLeftMenu;

@end
