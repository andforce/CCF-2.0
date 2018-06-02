//
//  ForumBaseStaticTableViewController.h
//
//  Created by 迪远 王 on 16/10/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiHelper.h"
#import "MJRefresh.h"

@interface ForumBaseStaticTableViewController : UITableViewController

@property(nonatomic, strong) id<ForumApiDelegate> forumApi;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) int currentPage;
@property(nonatomic, assign) int totalPage;

- (void)onPullRefresh;


- (void)onLoadMore;

- (BOOL)setPullRefresh:(BOOL)enable;

- (BOOL)setLoadMore:(BOOL)enable;

- (BOOL)autoPullfresh;

- (NSString *) currentForumHost;

@end
