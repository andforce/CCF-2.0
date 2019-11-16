//
//  TransBundleUINavigationController.h
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransBundle.h"
#import "TransBundleDelegate.h"

@interface TransBundleUINavigationController : UINavigationController

@property(nonatomic, strong) id <TransBundleDelegate> transDelegate;

@property(nonatomic, strong) TransBundle *bundle;

- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TransBundle *)bundle forRootController:(BOOL)forRootController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

- (void)dismissViewControllerAnimated:(BOOL)flag backToViewController:(UIViewController *_Nonnull)controller withBundle:(TransBundle *_Nonnull)bundle completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

- (void)transBundle:(TransBundle *_Nonnull)bundle forController:(UIViewController *_Nonnull)controller;

@end
