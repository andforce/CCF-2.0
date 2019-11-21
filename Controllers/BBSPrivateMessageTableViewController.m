//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSPrivateMessageTableViewController.h"
#import "BBSMessageTableViewCell.h"
#import "BBSShowPrivateMessageViewController.h"

#import "BBSUserProfileTableViewController.h"
#import "UIStoryboard+Forum.h"
#import "BBSTabBarController.h"

@interface BBSPrivateMessageTableViewController () <ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    int messageType;
    UIStoryboardSegue *selectSegue;
}

@end


@implementation BBSPrivateMessageTableViewController {
    ViewForumPage *currentForumPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    [self.messageSegmentedControl addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)didClicksegmentedControlAction:(UISegmentedControl *)Seg {
    NSInteger index = Seg.selectedSegmentIndex;
    switch (index) {
        case 0:
            messageType = 0;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
        case 1:
            messageType = -1;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
        default:
            messageType = 0;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
    }
}

- (void)onPullRefresh {
    [self refreshMessage:1];
}


- (void)refreshMessage:(int)page {
    [self.forumApi listPrivateMessageWithType:messageType andPage:page handler:^(BOOL isSuccess, ViewForumPage *message) {
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
    [self.forumApi listPrivateMessageWithType:messageType andPage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *message) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"BBSMessageTableViewCell";
    BBSMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.showUserProfileDelegate = self;

    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

    Message *message = self.dataList[(NSUInteger) indexPath.row];

    [cell setData:message forIndexPath:indexPath];

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
    return cell;
}

- (BOOL)swipeTableCell:(SwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = cell.indexPath;

    Message *deleteMessage = self.dataList[(NSUInteger) indexPath.row];
    NSInteger delType = _messageSegmentedControl.selectedSegmentIndex;
    [self.forumApi deletePrivateMessage:deleteMessage withType:(int) delType handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {
            [self.dataList removeObjectAtIndex:(NSUInteger) cell.indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.2f];
        }
    }];

    return YES;
}

- (void)reloadData {
    [self.tableView reloadData];
};

#pragma mark CCFThreadListCellDelegate

- (void)showUserProfile:(NSIndexPath *)indexPath {
    BBSUserProfileTableViewController *controller = selectSegue.destinationViewController;
    Message *message = self.dataList[(NSUInteger) indexPath.row];
    TranslateData *bundle = [[TranslateData alloc] init];
    [bundle putIntValue:[message.pmAuthorId intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];
}


#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([sender isKindOfClass:[UITableViewCell class]]) {
        BBSShowPrivateMessageViewController *controller = segue.destinationViewController;

        [controller setHidesBottomBarWhenPushed:YES];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Message *message = self.dataList[(NSUInteger) indexPath.row];

        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putObjectValue:message forKey:@"TransPrivateMessage"];
        [bundle putIntValue:(int) _messageSegmentedControl.selectedSegmentIndex forKey:@"TransPrivateMessageType"];


        [self transBundle:bundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}


- (IBAction)showLeftDrawer:(id)sender {
    BBSTabBarController *controller = (BBSTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}

- (IBAction)writePrivateMessage:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"CreatePM"];
    [self.navigationController presentViewController:controller animated:YES completion:^{

    }];
}
@end
