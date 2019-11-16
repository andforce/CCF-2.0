//
//  ForumFavFormController.m
//
//  Created by 迪远 王 on 16/1/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumFavFormController.h"
#import "ForumCoreDataManager.h"
#import "ForumThreadListTableViewController.h"
#import "ForumTabBarController.h"
#import "MGSwipeTableCellWithIndexPath.h"
#import "LocalForumApi.h"

//订阅论坛

@interface ForumFavFormController () <MGSwipeTableCellDelegate> {

}

@end

@implementation ForumFavFormController

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

    [self.forumApi listFavoriteForums:^(BOOL isSuccess, NSMutableArray<Forum *> *message) {


        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            self.dataList = message;
            [self.tableView reloadData];

            NSMutableArray *ids = [NSMutableArray array];
            for (Forum *forum in message) {
                [ids addObject:@(forum.forumId)];
            }
            LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
            [localForumApi saveFavFormIds:ids];
        }

    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    if (localForumApi.favFormIds == nil) {
        [self.forumApi listFavoriteForums:^(BOOL isSuccess, NSMutableArray<Forum *> *message) {
            self.dataList = message;
            [self.tableView reloadData];

            NSMutableArray *ids = [NSMutableArray array];
            for (Forum *forum in message) {
                [ids addObject:@(forum.forumId)];
            }
            [localForumApi saveFavFormIds:ids];

        }];
    } else {
        ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
        NSArray *forms = [[manager selectFavForums:localForumApi.favFormIds] mutableCopy];

        [self.dataList addObjectsFromArray:forms];

        [self.tableView reloadData];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadListFormFavForumList"]) {
        ForumThreadListTableViewController *controller = segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        Forum *select = self.dataList[(NSUInteger) path.row];
        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:select forKey:@"TransForm"];
        [self transBundle:bundle forController:controller];
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"FavFormControllerCell";
    MGSwipeTableCellWithIndexPath *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    cell.indexPath = indexPath;
    cell.delegate = self;
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"取消订阅" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;


    Forum *form = self.dataList[(NSUInteger) indexPath.row];

    cell.textLabel.text = form.forumName;

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [cell setSeparatorInset:edgeInsets];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 54;
}

- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {


    Forum *parent = self.dataList[(NSUInteger) cell.indexPath.row];

    [self.forumApi unFavouriteForumWithId:[NSString stringWithFormat:@"%d", parent.forumId] handler:^(BOOL isSuccess, id message) {

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

- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}
@end
