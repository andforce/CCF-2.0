//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSSettingTableViewController : UITableViewController
- (IBAction)back:(UIBarButtonItem *)sender;

- (IBAction)switchSignature:(UISwitch *)sender;

- (IBAction)switchTopThread:(UISwitch *)sender;


@property(weak, nonatomic) IBOutlet UISwitch *signatureSwitch;
@property(weak, nonatomic) IBOutlet UISwitch *topThreadPostSwitch;

@end
