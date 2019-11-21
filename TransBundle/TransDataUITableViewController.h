//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TranslateData.h"
#import "TranslateDataDelegate.h"

@interface TransDataUITableViewController : UITableViewController
@property(nonatomic, strong) id <TranslateDataDelegate> delegate;

@property(nonatomic, strong) TranslateData *bundle;

- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TranslateData *)bundle forRootController:(BOOL)forRootController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

- (void)dismissViewControllerAnimated:(BOOL)flag backToViewController:(UIViewController *_Nonnull)controller withBundle:(TranslateData *_Nullable)bundle completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

- (void)transBundle:(TranslateData *_Nonnull)bundle forController:(UIViewController *_Nonnull)controller;

@end
