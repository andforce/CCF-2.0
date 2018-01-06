//
//  ForumSearchViewController.m
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSearchViewController.h"

#import "ForumSearchResultCell.h"
#import "ForumUserProfileTableViewController.h"
#import <SVProgressHUD.h>
#import "ForumWebViewController.h"
#import "LocalForumApi.h"
#import "ZhanNeiSearchViewCell.h"
#import "PayManager.h"
#import "UIStoryboard+Forum.h"

@interface ForumSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    NSString *_searchid;
    UIStoryboardSegue *selectSegue;
    NSString *searchText;

    BOOL isZhanNeiSearch;

    LocalForumApi *_localForumApi;
    PayManager *_payManager;
}

@end

@implementation ForumSearchViewController{
    ViewSearchForumPage *currentSearchForumPage;
}

- (void)viewDidLoad {

    _localForumApi = [[LocalForumApi alloc] init];
    // payManager
    _payManager = [PayManager shareInstance];

    isZhanNeiSearch = [self isZhanNeiSearch];

    self.searchBar.delegate = self;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = (CGFloat) (isZhanNeiSearch ? 44.0 : 97.0);

    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self onLoadMore];
    }];

}

-(void)viewDidAppear:(BOOL)animated{
    if (![_payManager hasPayed:[_localForumApi currentProductID]]){
        [self showFailedMessage:@"未订阅用户无法搜索"];
    }
}

-(void) showFailedMessage:(id) message{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"操作受限" message:message preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *showPayPage = [UIAlertAction actionWithTitle:@"订阅" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

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
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    if ([bundleId isEqualToString:@"com.andforce.CHH"]){
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

    [SVProgressHUD showWithStatus:@"搜索中" maskType:SVProgressHUDMaskTypeBlack];

    int select = (int) self.segmentedControl.selectedSegmentIndex;

    [self.forumApi searchWithKeyWord:searchText forType:select handler:^(BOOL isSuccess, ViewSearchForumPage *message) {
        
        [SVProgressHUD dismiss];

        if (isSuccess) {
            _searchid = message.searchid;

            currentSearchForumPage = message;

            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];
        } else {
            NSLog(@"searchBarSearchButtonClicked   ERROR %@", message);
            NSString * msg = (id)message;
            [SVProgressHUD showErrorWithStatus:msg maskType:SVProgressHUDMaskTypeBlack];
        }
    }];

}

- (void)showUserProfile:(NSIndexPath *)indexPath {
    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    Thread *thread = self.dataList[(NSUInteger) indexPath.row];
    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];

    [self transBundle:bundle forController:controller];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldBeginEditing");
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (isZhanNeiSearch){
        static NSString *QuoteCellIdentifier = @"ZhanNeiSearchViewCell";

        ZhanNeiSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];

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

        ForumSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];

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


- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = cell.indexPath;


    Thread *play = self.dataList[(NSUInteger) indexPath.row];

    [self.forumApi favoriteThreadWithId:play.threadID handler:^(BOOL isSuccess, id message) {
//        BOOL success = isSuccess;
//        NSString * result = message;
    }];


    return YES;
}

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

    } if ([segue.identifier isEqualToString:@"ZhanNeiSearchViewCell"]) {

        ForumWebViewController *controller = segue.destinationViewController;
        [controller setHidesBottomBarWhenPushed:YES];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];

        TransBundle *transBundle = [[TransBundle alloc] init];
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
