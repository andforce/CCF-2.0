//
//  ForumTableViewController.m
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumTableViewController.h"
#import "ForumCoreDataManager.h"
#import "ForumThreadListTableViewController.h"
#import "ForumListHeaderView.h"
#import "XibInflater.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeTableCellWithIndexPath.h"
#import "ForumTabBarController.h"
#import "UIStoryboard+Forum.h"

#import "ForumEntry+CoreDataClass.h"
#import "ForumSearchViewController.h"
#import "ForumNavigationViewController.h"


@interface ForumTableViewController () <MGSwipeTableCellDelegate>

@end

@implementation ForumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    ForumCoreDataManager *formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];

    [self.dataList removeAllObjects];

    [self.dataList addObjectsFromArray:[[formManager selectAllForums] copy]];

    [self.tableView reloadData];

}

- (BOOL)setPullRefresh:(BOOL)enable {
    return YES;
}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (BOOL)autoPullfresh {
    return NO;
}

- (void)onPullRefresh {

    [self.forumApi listAllForums:^(BOOL isSuccess, id message) {

        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            NSMutableArray<Forum *> *needInsert = message;
            ForumCoreDataManager *formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
            // 需要先删除之前的老数据
            [formManager deleteData:^NSPredicate * {
                return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
            }];

            [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
                ForumEntry *newsInfo = (ForumEntry *) target;
                newsInfo.forumId = [src valueForKey:@"forumId"];
                newsInfo.forumName = [src valueForKey:@"forumName"];
                newsInfo.parentForumId = [src valueForKey:@"parentForumId"];
                newsInfo.forumHost = [src valueForKey:@"forumHost"];

            }];

            [self.dataList removeAllObjects];

            [self.dataList addObjectsFromArray:[[formManager selectAllForums] copy]];

            [self.tableView reloadData];
        }

    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    ForumListHeaderView *headerView = [XibInflater inflateViewByXibName:@"ForumListHeaderView"];
    Forum *parent = self.dataList[section];
    headerView.textLabel.text = parent.forumName;
    return headerView;


}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Forum *forum = self.dataList[section];
    return forum.childForums.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MGSwipeTableCellWithIndexPath *cell = (MGSwipeTableCellWithIndexPath *) [tableView dequeueReusableCellWithIdentifier:@"DRLForumCell"];

    cell.indexPath = indexPath;
    cell.delegate = self;
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"订阅此论坛" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;


    Forum *parent = self.dataList[indexPath.section];
    Forum *child = parent.childForums[indexPath.row];

    cell.textLabel.text = child.forumName;

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [cell setSeparatorInset:edgeInsets];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    return cell;
}

- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {

    Forum *parent = self.dataList[cell.indexPath.section];
    Forum *child = parent.childForums[cell.indexPath.row];

    [self.forumApi favoriteForumWithId:[NSString stringWithFormat:@"%d", child.forumId] handler:^(BOOL isSuccess, id message) {
        NSLog(@">>>>>>>>>>>> %@", message);
    }];

    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowThreadList"]) {
        ForumThreadListTableViewController *controller = segue.destinationViewController;

        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        Forum *select = self.dataList[(NSUInteger) path.section];
        Forum *child = select.childForums[(NSUInteger) path.row];

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:child forKey:@"TransForm"];
        [self transBundle:bundle forController:controller];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)showControllerByShortCutItemType:(NSString *)shortCutItemType {

    if ([shortCutItemType isEqualToString:@"OPEN_JINGPING_HOME"]) {
        TransBundle *bundle = [[TransBundle alloc] init];
        Forum *child = [[Forum alloc] init];
        child.forumName = @"精品家园";
        child.forumId = 147;
        [bundle putObjectValue:child forKey:@"TransForm"];

        NSArray<UIViewController *> *childViewControllers = self.navigationController.childViewControllers;
        for (int i = 0; i < childViewControllers.count; ++i) {
            UIViewController *child = childViewControllers[i];
            if ([child isKindOfClass:[ForumThreadListTableViewController class]]) {
                ForumThreadListTableViewController *ftl = (ForumThreadListTableViewController *) child;
                NSString *title = ftl.titleNavigationItem.title;
                if ([title isEqualToString:@"精品家园"]) {
                    [self transBundle:bundle forController:ftl];
                    return;
                }
            }
        }

        ForumThreadListTableViewController *controller = (ForumThreadListTableViewController *) [[UIStoryboard mainStoryboard] finControllerById:@"ThreadList"];

        [self transBundle:bundle forController:controller];
        [self.navigationController pushViewController:controller animated:YES];


    } else if ([shortCutItemType isEqualToString:@"OPEN_ERSHOU_FORUM"]) {

        TransBundle *bundle = [[TransBundle alloc] init];
        Forum *child = [[Forum alloc] init];
        child.forumName = @"二手闲置";
        child.forumId = 174;

        NSArray<UIViewController *> *childViewControllers = self.navigationController.childViewControllers;
        for (int i = 0; i < childViewControllers.count; ++i) {
            UIViewController *child = childViewControllers[i];
            if ([child isKindOfClass:[ForumThreadListTableViewController class]]) {
                ForumThreadListTableViewController *ftl = (ForumThreadListTableViewController *) child;
                NSString *title = ftl.titleNavigationItem.title;
                if ([title isEqualToString:@"二手闲置"]) {
                    [self transBundle:bundle forController:ftl];
                    return;
                }
            }
        }

        ForumThreadListTableViewController *controller = (ForumThreadListTableViewController *) [[UIStoryboard mainStoryboard] finControllerById:@"ThreadList"];

        [bundle putObjectValue:child forKey:@"TransForm"];
        [self transBundle:bundle forController:controller];

        [self.navigationController pushViewController:controller animated:YES];

    } else if ([shortCutItemType isEqualToString:@"OPEN_CREATE_NEW_THREAD"]) {

        NSArray<UIViewController *> *childViewControllers = self.navigationController.viewControllers;
        for (int i = 0; i < childViewControllers.count; ++i) {
            UIViewController *child = childViewControllers[i];
            if ([child isKindOfClass:[ForumNavigationViewController class]]) {
                return;
            }
        }

        ForumNavigationViewController *controller = (ForumNavigationViewController *) [[UIStoryboard mainStoryboard] finControllerById:@"ShortCutCreateNewThreadNV"];

        [self presentViewController:controller animated:YES completion:^{

        }];
    } else if ([shortCutItemType isEqualToString:@"OPEN_SEARCH_FORUM"]) {

        NSArray<UIViewController *> *childViewControllers = self.navigationController.viewControllers;
        for (int i = 0; i < childViewControllers.count; ++i) {
            UIViewController *child = childViewControllers[i];
            if ([child isKindOfClass:[ForumSearchViewController class]]) {
                return;
            }
        }

        ForumSearchViewController *controller = (ForumSearchViewController *) [[UIStoryboard mainStoryboard] finControllerById:@"SearchForum"];

        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}
@end
