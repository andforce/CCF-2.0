//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TranslateData.h"
#import "TranslateDataDelegate.h"

@interface TranslateDataNavigationController : UINavigationController

@property(nonatomic, strong) id <TranslateDataDelegate> transDelegate;

@property(nonatomic, strong) TranslateData *bundle;

- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TranslateData *)bundle forRootController:(BOOL)forRootController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

- (void)dismissViewControllerAnimated:(BOOL)flag backToViewController:(UIViewController *_Nonnull)controller withBundle:(TranslateData *_Nonnull)bundle completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

- (void)transBundle:(TranslateData *_Nonnull)bundle forController:(UIViewController *_Nonnull)controller;

@end
