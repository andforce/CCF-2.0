//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSFavThreadPostTableViewController.h"
#import "BBSSimpleThreadTableViewCell.h"
#import "BBSTabBarController.h"
#import "BBSWebViewController.h"
#import "BBSUserProfileTableViewController.h"
#import "BBSLocalApi.h"

@interface BBSFavThreadPostTableViewController () <MGSwipeTableCellDelegate, ThreadListCellDelegate> {
    UIStoryboardSegue *selectSegue;
}

@end

@implementation BBSFavThreadPostTableViewController {
    ViewForumPage *currentForumPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;
}

- (void)onPullRefresh {
    BBSLocalApi *forumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> config = [BBSApiHelper forumConfig:forumApi.currentForumHost];
    BBSUser *user = [forumApi getLoginUser:config.forumURL.host];
    int userId = [user.userID intValue];
    [self.forumApi listFavoriteThreads:userId withPage:1 handler:^(BOOL isSuccess, ViewForumPage *resultPage) {

        [self.tableView.mj_header endRefreshing];
        if (isSuccess) {

            [self.tableView.mj_header endRefreshing];

            currentForumPage = resultPage;
            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:resultPage.dataList];
            [self.tableView reloadData];
        }
    }];
}

- (void)onLoadMore {
    int toLoadPage = currentForumPage == nil ? 1 : currentForumPage.pageNumber.currentPageNumber + 1;
    BBSLocalApi *forumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> config = [BBSApiHelper forumConfig:forumApi.currentForumHost];
    BBSUser *user = [forumApi getLoginUser:config.forumURL.host];
    int userId = [user.userID intValue];
    [self.forumApi listFavoriteThreads:userId withPage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *resultPage) {

        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {
            currentForumPage = resultPage;

            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataList addObjectsFromArray:resultPage.dataList];

            [self.tableView reloadData];
        }
    }];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SimpleThreadTableViewCell";
    BBSSimpleThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.showUserProfileDelegate = self;
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"取消收藏" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

    Thread *list = self.dataList[(NSUInteger) indexPath.row];
    [cell setData:list forIndexPath:indexPath];

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
    return cell;
}


- (BOOL)swipeTableCell:(BBSSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {

    Thread *list = self.dataList[(NSUInteger) cell.indexPath.row];

    [self.forumApi unFavoriteThreadWithId:list.threadID handler:^(BOOL isSuccess, id message) {
        NSLog(@">>>>>>>>>>>> %@", message);
    }];

    [self.dataList removeObjectAtIndex:(NSUInteger) cell.indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];

    return YES;
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

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}

- (void)showUserProfile:(NSIndexPath *)indexPath {

    BBSUserProfileTableViewController *controller = selectSegue.destinationViewController;

    TranslateData *bundle = [[TranslateData alloc] init];
    Thread *thread = self.dataList[(NSUInteger) indexPath.row];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];

}

- (IBAction)showLeftDrawer:(id)sender {
    BBSTabBarController *controller = (BBSTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
