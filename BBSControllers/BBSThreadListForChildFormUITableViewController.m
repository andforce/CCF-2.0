//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSThreadListForChildFormUITableViewController.h"

#import "BBSThreadListCell.h"
#import "BBSCreateNewThreadViewController.h"
#import "BBSUserProfileTableViewController.h"
#import "BBSWebViewController.h"
#import "UIStoryboard+Forum.h"

@interface BBSThreadListForChildFormUITableViewController () <TranslateDataDelegate, MGSwipeTableCellDelegate> {
    NSArray *childForms;
    Forum *transForm;
}

@end

@implementation BBSThreadListForChildFormUITableViewController {
    ViewForumPage *currentForumPage;
}

- (void)transBundle:(TranslateData *)bundle {
    transForm = [bundle getObjectValue:@"TransForm"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    BBSCoreDataManager *manager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    childForms = [[manager selectChildForumsById:transForm.forumId] mutableCopy];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    if (self.threadTopList == nil) {
        self.threadTopList = [NSMutableArray array];
    }

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

- (void)onPullRefresh {
    [self.forumApi forumDisplayWithId:transForm.forumId andPage:1 handler:^(BOOL isSuccess, ViewForumPage *page) {

        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            currentForumPage = page;

            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.threadTopList removeAllObjects];
            [self.dataList removeAllObjects];

            for (Thread *thread in page.dataList) {
                if (thread.isTopThread) {
                    [self.threadTopList addObject:thread];
                } else {
                    [self.dataList addObject:thread];
                }
            }

            [self.tableView reloadData];
        }
    }];
}

- (void)onLoadMore {

    int toLoadPage = currentForumPage == nil ? 1 : currentForumPage.pageNumber.totalPageNumber + 1;

    [self.forumApi forumDisplayWithId:transForm.forumId andPage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *page) {

        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {
            currentForumPage = page;

            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            for (Thread *thread in page.dataList) {
                if (!thread.isTopThread) {
                    [self.dataList addObject:thread];
                }
            }

            [self.tableView reloadData];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return self.threadTopList.count;
    } else {
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // 帖子内容
    static NSString *reusedIdentifier = @"ThreadListCellIdentifier";

    BBSThreadListCell *cell = (BBSThreadListCell *) [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];

    Thread *thread;
    if (indexPath.section == 0) {
        thread = self.threadTopList[(NSUInteger) indexPath.row];
    } else {
        thread = self.dataList[(NSUInteger) indexPath.row];
    }
    [cell setData:thread];

    cell.indexPath = indexPath;

    cell.delegate = self;

    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    return cell;
}

- (BOOL)swipeTableCell:(BBSSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = cell.indexPath;

    Thread *thread;
    if (indexPath.section == 0) {
        thread = self.threadTopList[(NSUInteger) indexPath.row];
    } else {
        thread = self.dataList[(NSUInteger) indexPath.row];
    }

    [self.forumApi favoriteThreadWithId:thread.threadID handler:^(BOOL isSuccess, id message) {

    }];

    return YES;
}

#pragma mark Controller跳转


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {

        BBSCreateNewThreadViewController *newPostController = segue.destinationViewController;
        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putIntValue:transForm.forumId forKey:@"FORM_ID"];
        [bundle putObjectValue:currentForumPage forKey:@"CREATE_THREAD_IN"];
        [self transBundle:bundle forController:newPostController];

    } else if ([sender isKindOfClass:[UITableViewCell class]]) {

        BBSWebViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = nil;
        if (indexPath.section == 0) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }

        TranslateData *transBundle = [[TranslateData alloc] init];
        [transBundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [transBundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:transBundle forController:controller];


    } else if ([sender isKindOfClass:[UIButton class]]) {
        BBSUserProfileTableViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = nil;
        if (indexPath.section == 0) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }
        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
        [self transBundle:bundle forController:controller];
    }


}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createThread:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

    UINavigationController *createController = (id) [storyboard instantiateViewControllerWithIdentifier:@"CreateNewThread"];

    TranslateData *bundle = [[TranslateData alloc] init];
    [bundle putIntValue:transForm.forumId forKey:@"FORM_ID"];
    [bundle putObjectValue:currentForumPage forKey:@"CREATE_THREAD_IN"];
    [self presentViewController:(id) createController withBundle:bundle forRootController:YES animated:YES completion:^{

    }];
}


@end
