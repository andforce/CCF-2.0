//
//  BBSFontSizeTableViewController.m
//  Forum
//
//  Created by 迪远 王 on 2020/1/29.
//  Copyright © 2020 None. All rights reserved.
//

#import "BBSFontSizeTableViewController.h"
#import "NSUserDefaults+Setting.h"

@interface BBSFontSizeTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *fontSizeTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *normalSize;
@property (strong, nonatomic) IBOutlet UITableViewCell *middleSize;
@property (strong, nonatomic) IBOutlet UITableViewCell *bigSize;

@end

@implementation BBSFontSizeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    int size = [[NSUserDefaults standardUserDefaults] fontSize];
    if (size == 100){
        _normalSize.accessoryType = UITableViewCellAccessoryCheckmark;
        _middleSize.accessoryType = UITableViewCellAccessoryNone;
        _bigSize.accessoryType = UITableViewCellAccessoryNone;
    } else if (size == 120){
        _normalSize.accessoryType = UITableViewCellAccessoryNone;
        _middleSize.accessoryType = UITableViewCellAccessoryCheckmark;
        _bigSize.accessoryType = UITableViewCellAccessoryNone;
    } else if (size == 140){
        _normalSize.accessoryType = UITableViewCellAccessoryNone;
        _middleSize.accessoryType = UITableViewCellAccessoryNone;
        _bigSize.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        _normalSize.accessoryType = UITableViewCellAccessoryNone;
        _middleSize.accessoryType = UITableViewCellAccessoryNone;
        _bigSize.accessoryType = UITableViewCellAccessoryNone;

        switch (indexPath.row){
            case 0:{
                _normalSize.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setFontSize:100];
                break;
            }
            case 1:{
                _middleSize.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setFontSize:120];
                break;
            }
            case 2:{
                _bigSize.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setFontSize:140];
                break;
            }
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 5;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

@end
