//
//  ForumLoginViewController.h
//
//  Created by WDY on 15/12/30.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseViewController.h"


@interface ForumLoginViewController : ForumApiBaseViewController

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
