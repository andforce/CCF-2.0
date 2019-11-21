//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSApiBaseTableViewController.h"

@interface BBSSearchViewController : BBSApiBaseTableViewController


@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;


- (IBAction)back:(id)sender;

@end
