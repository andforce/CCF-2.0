//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSSearchViewController.h"

#import "BBSSearchResultCell.h"
#import "BBSUserProfileTableViewController.h"
#import "BBSWebViewController.h"
#import "BBSLocalApi.h"
#import "BBSZhanNeiSearchViewCell.h"
#import "BBSPayManager.h"
#import "UIStoryboard+Forum.h"
#import "ProgressDialog.h"

@interface BBSSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    NSString *_searchid;
    UIStoryboardSegue *selectSegue;
    NSString *searchText;

    BOOL isZhanNeiSearch;

    BBSLocalApi *_localForumApi;
    BBSPayManager *_payManager;
}

@end

@implementation BBSSearchViewController {
    ViewSearchForumPage *currentSearchForumPage;
}

- (void)viewDidLoad {

    _localForumApi = [[BBSLocalApi alloc] init];
    // payManager
    _payManager = [BBSPayManager shareInstance];

    isZhanNeiSearch = [self isZhanNeiSearch];

    self.searchBar.delegate = self;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = (CGFloat) (isZhanNeiSearch ? 44.0 : 97.0);

    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self onLoadMore];
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    if (![_payManager hasPayed:[_localForumApi currentProductID]]) {
        [self showFailedMessage:@"搜索需要解锁高级功能"];
    }
}

- (void)showFailedMessage:(id)message {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"操作受限" message:message preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *showPayPage = [UIAlertAction actionWithTitle:@"解锁" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        UIViewController *controller = [[UIStoryboard mainStoryboard] finControllerById:@"ShowPayPage"];

        [self presentViewController:controller animated:YES completion:^{

        }];

    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self.navigationController popViewControllerAnimated:YES];

    }];

    [alert addAction:cancel];

    [alert addAction:showPayPage];


    [self presentViewController:alert animated:YES completion:^{

    }];
}

- (BOOL)isZhanNeiSearch {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    if ([bundleId isEqualToString:@"com.andforce.CHH"]) {
        return YES;
    } else {
        return [localForumApi.currentForumHost containsString:@"chiphell"];
    }
}

- (void)onLoadMore {

    if (!isZhanNeiSearch && _searchid == nil) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }

    int toLoadPage = currentSearchForumPage.pageNumber.currentPageNumber + 1;
    int select = (int) self.segmentedControl.selectedSegmentIndex;
    [self.forumApi listSearchResultWithSearchId:_searchid keyWord:searchText andPage:toLoadPage type:select handler:^(BOOL isSuccess, ViewSearchForumPage *message) {
        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {

            currentSearchForumPage = message;

            if (currentSearchForumPage.pageNumber.currentPageNumber >= currentSearchForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];
        } else {
            NSLog(@"searchBarSearchButtonClicked   ERROR %@", message);
        }
    }];

}


#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchText = searchBar.text;

    [searchBar resignFirstResponder];

    [ProgressDialog showStatus:@"搜索中"];

    int select = (int) self.segmentedControl.selectedSegmentIndex;

    [self.forumApi searchWithKeyWord:searchText forType:select handler:^(BOOL isSuccess, ViewSearchForumPage *message) {

        [ProgressDialog dismiss];

        if (isSuccess) {
            _searchid = message.searchid;

            currentSearchForumPage = message;

            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];
        } else {
            NSLog(@"searchBarSearchButtonClicked   ERROR %@", message);
            NSString *msg = (id) message;
            [ProgressDialog showError:msg];
        }
    }];

}

- (void)showUserProfile:(NSIndexPath *)indexPath {
    BBSUserProfileTableViewController *controller = selectSegue.destinationViewController;
    Thread *thread = self.dataList[(NSUInteger) indexPath.row];
    TranslateData *bundle = [[TranslateData alloc] init];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];

    [self transBundle:bundle forController:controller];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldBeginEditing");
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (isZhanNeiSearch) {
        static NSString *QuoteCellIdentifier = @"ZhanNeiSearchViewCell";

        BBSZhanNeiSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];

        [cell setData:thread forIndexPath:indexPath];

        cell.indexPath = indexPath;

        cell.delegate = self;

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
        [cell setData:self.dataList[(NSUInteger) indexPath.row]];
        return cell;
    } else {
        static NSString *QuoteCellIdentifier = @"SearchResultCell";

        BBSSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];

        [cell setData:thread forIndexPath:indexPath];

        cell.showUserProfileDelegate = self;

        cell.indexPath = indexPath;

        cell.delegate = self;

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
        [cell setData:self.dataList[(NSUInteger) indexPath.row]];
        return cell;
    }
}


- (BOOL)swipeTableCell:(SwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = cell.indexPath;


    Thread *play = self.dataList[(NSUInteger) indexPath.row];

    [self.forumApi favoriteThreadWithId:play.threadID handler:^(BOOL isSuccess, id message) {

    }];


    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        BBSWebViewController *controller = segue.destinationViewController;
        [controller setHidesBottomBarWhenPushed:YES];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];

        TranslateData *transBundle = [[TranslateData alloc] init];
        [transBundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [transBundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:transBundle forController:controller];

    }
    if ([segue.identifier isEqualToString:@"ZhanNeiSearchViewCell"]) {

        BBSWebViewController *controller = segue.destinationViewController;
        [controller setHidesBottomBarWhenPushed:YES];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];

        TranslateData *transBundle = [[TranslateData alloc] init];
        [transBundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        //[transBundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:transBundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
