//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseViewController.h"


@interface BBSLoginViewController : ForumApiBaseViewController

@property(weak, nonatomic) IBOutlet UITextField *userName;
@property(weak, nonatomic) IBOutlet UITextField *password;
@property(weak, nonatomic) IBOutlet UITextField *vCode;
@property(weak, nonatomic) IBOutlet UIView *loginbgview;
@property(weak, nonatomic) IBOutlet UIView *rootView;

@property(weak, nonatomic) IBOutlet UIImageView *doorImageView;

- (IBAction)login:(id)sender;

- (IBAction)refreshDoor:(id)sender;

- (IBAction)cancelLogin:(id)sender;

@end
