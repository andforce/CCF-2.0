//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSUserThreadTableViewController.h"
#import "BBSSearchResultCell.h"
#import "BBSWebViewController.h"

@interface BBSUserThreadTableViewController () <TranslateDataDelegate> {
    UserProfile *userProfile;
}

@end

@implementation BBSUserThreadTableViewController {
    ViewForumPage *currentForumPage;
}

- (void)transBundle:(TranslateData *)bundle {
    userProfile = [bundle getObjectValue:@"UserProfile"];
}


- (void)onPullRefresh {
    int userId = [userProfile.profileUserId intValue];
    [self.forumApi listAllUserThreads:userId withPage:1 handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            [self.tableView.mj_footer endRefreshing];

            currentForumPage = message;

            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.dataList removeAllObjects];

            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];

        }
    }];
}

- (void)onLoadMore {

    int toLoadPage = currentForumPage == nil ? 1 : currentForumPage.pageNumber.currentPageNumber + 1;
    int userId = [userProfile.profileUserId intValue];
    [self.forumApi listAllUserThreads:userId withPage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *message) {
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
    BBSSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

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

        BBSWebViewController *controller = segue.destinationViewController;
        [controller setHidesBottomBarWhenPushed:YES];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Thread *thread = self.dataList[(NSUInteger) indexPath.row];


        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [bundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];
        [self transBundle:bundle forController:controller];
    }
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
