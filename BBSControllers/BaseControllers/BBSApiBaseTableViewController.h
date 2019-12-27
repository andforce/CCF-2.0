//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BBSApiHelper.h"
#import "MJRefresh.h"

#import "TranslateDataUITableViewController.h"

@interface BBSApiBaseTableViewController : TranslateDataUITableViewController

@property(nonatomic, strong) id <BBSApiDelegate> forumApi;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) PageNumber *pageNumber;

- (void)onPullRefresh;

- (void)onLoadMore;

- (BOOL)setPullRefresh:(BOOL)enable;

- (BOOL)setLoadMore:(BOOL)enable;

- (BOOL)autoPullfresh;

- (NSString *)currentForumHost;

- (BOOL)isNeedHideLeftMenu;

@end
