//
//  ForumThreadListTableViewController.m
//
//  Created by 迪远 王 on 16/1/1.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumThreadListTableViewController.h"

#import "ForumThreadListCell.h"
#import "ForumCreateNewThreadViewController.h"
#import "ForumUserProfileTableViewController.h"
#import "ForumThreadListForChildFormUITableViewController.h"
#import "NSUserDefaults+Setting.h"
#import "UIStoryboard+Forum.h"
#import "ForumWebViewController.h"


@interface ForumThreadListTableViewController () <TransBundleDelegate, ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    Forum *transForm;
    NSArray *childForms;
    UIStoryboardSegue *selectSegue;
}

@end

@implementation ForumThreadListTableViewController{
    ViewForumPage *currentForumPage;
}

#pragma mark trans value

- (void)transBundle:(TransBundle *)bundle {
    transForm = [bundle getObjectValue:@"TransForm"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    childForms = [[manager selectChildForumsById:transForm.forumId] mutableCopy];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    if (self.threadTopList == nil) {
        self.threadTopList = [NSMutableArray array];
    }

    self.titleNavigationItem.title = transForm.forumName;

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

    int toLoadPage = currentForumPage == nil ? 1: currentForumPage.pageNumber.currentPageNumber + 1;
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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        // 子论坛列表
        return childForms.count;
    } else if (section == 1) {
        if ([[NSUserDefaults standardUserDefaults] isTopThreadPostCanShow]) {
            return self.threadTopList.count;
        } else {
            return 0;
        }


    } else {
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *reusedIdentifier = @"ThreadListCellIdentifier";

    if (indexPath.section == 0) {
        // 子论坛
        static NSString *reusedIdentifierForm = @"ThreadListCellShowChildForm";
        MGSwipeTableCellWithIndexPath *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifierForm];

        cell.indexPath = indexPath;

        cell.delegate = self;

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"订阅此论坛" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

        Forum *form = childForms[(NSUInteger) indexPath.row];
        cell.textLabel.text = form.forumName;

        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0,16,0,16);
        [cell setSeparatorInset:edgeInsets];
        [cell setLayoutMargins:UIEdgeInsetsZero];

        return cell;
    } else if (indexPath.section == 1) {

        // 置顶帖子
        ForumThreadListCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];

        Thread *play = self.threadTopList[(NSUInteger) indexPath.row];

        [cell setData:play forIndexPath:indexPath];

        cell.showUserProfileDelegate = self;

        cell.indexPath = indexPath;

        cell.delegate = self;

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;


        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];

        return cell;
    } else {

        // 普通帖子
        ForumThreadListCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];

        Thread *play = self.dataList[(NSUInteger) indexPath.row];

        [cell setData:play forIndexPath:indexPath];

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
    if (indexPath.section == 0) {
        Forum *parent = childForms[(NSUInteger) cell.indexPath.section];

        [self.forumApi favoriteForumWithId:[NSString stringWithFormat:@"%d", parent.forumId] handler:^(BOOL isSuccess, id message) {
            NSLog(@">>>>>>>>>>>> %@", message);
        }];
    } else if (indexPath.section == 1) {
        Thread *play = self.threadTopList[(NSUInteger) indexPath.row];

        [self.forumApi favoriteThreadWithId:play.threadID handler:^(BOOL isSuccess, id message) {

        }];
    } else {
        Thread *play = self.dataList[(NSUInteger) indexPath.row];

        [self.forumApi favoriteThreadWithId:play.threadID handler:^(BOOL isSuccess, id message) {

        }];
    }


    return YES;
}

- (void)showUserProfile:(NSIndexPath *)indexPath {

    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    Thread *thread = nil;

    NSInteger section = indexPath.section;
    
    if (section == 0) {
        // 子论坛列表
    } else if (section == 1) {
        thread = self.threadTopList[(NSUInteger) indexPath.row];
    } else {
        thread = self.dataList[(NSUInteger) indexPath.row];
    }
    
    if (thread) {
        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
        [self transBundle:bundle forController:controller];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark Controller跳转


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {

        ForumCreateNewThreadViewController *newPostController = segue.destinationViewController;
        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putIntValue:transForm.forumId forKey:@"FORM_ID"];
        [bundle putObjectValue:currentForumPage forKey:@"CREATE_THREAD_IN"];
        [self transBundle:bundle forController:newPostController];



    } else if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;
        [controller setHidesBottomBarWhenPushed:YES];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Thread *thread = nil;
        NSInteger section = indexPath.section;
        if (section == 1) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else if (section == 2) {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [bundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:bundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowChildForm"]) {
        ForumThreadListForChildFormUITableViewController *controller = segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        int row = (int)indexPath.row;
        Forum * forum = childForms[(NSUInteger) row];
        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putObjectValue: forum forKey:@"TransForm"];
        [self transBundle:bundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    } else if ([sender isKindOfClass:[UIButton class]]) {
        ForumUserProfileTableViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = nil;
        if (indexPath.section == 0) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }
        TransBundle * bundle = [[TransBundle alloc] init];
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

    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:transForm.forumId forKey:@"FORM_ID"];
    [bundle putObjectValue:currentForumPage forKey:@"CREATE_THREAD_IN"];
    [self presentViewController:(id) createController withBundle:bundle forRootController:YES animated:YES completion:^{

    }];
}

@end
