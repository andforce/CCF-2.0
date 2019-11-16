//
//  ForumMyThreadTableViewController.m
//
//  Created by 迪远 王 on 16/3/6.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumMyThreadTableViewController.h"
#import "ForumSearchResultCell.h"
#import "ForumWebViewController.h"

@interface ForumMyThreadTableViewController ()

@end

@implementation ForumMyThreadTableViewController {
    ViewForumPage *currentForumPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;
}

- (void)onPullRefresh {
    [self.forumApi listMyAllThreadsWithPage:1 handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            [self.tableView.mj_footer endRefreshing];

            currentForumPage = message;
            [self.dataList removeAllObjects];

            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];

            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

        }

    }];
}

- (void)onLoadMore {
    int toLoadPage = currentForumPage == nil ? 1 : currentForumPage.pageNumber.currentPageNumber + 1;
    [self.forumApi listMyAllThreadsWithPage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {
            currentForumPage = message;

            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];

        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SearchResultCell";
    ForumSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    Thread *thread = self.dataList[(NSUInteger) indexPath.row];
    [cell setData:thread];

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
    return cell;
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;
        [controller setHidesBottomBarWhenPushed:YES];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];

        TransBundle *transBundle = [[TransBundle alloc] init];
        [transBundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [transBundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:transBundle forController:controller];
    }
}


- (IBAction)showLeftDrawer:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
