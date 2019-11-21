//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "TransBundleUIViewController.h"


@implementation TransBundleUIViewController {

}

- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TranslateData *)bundle forRootController:(BOOL)forRootController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion {

    UIViewController *target = forRootController ? viewControllerToPresent.childViewControllers.firstObject : viewControllerToPresent;

    NSAssert([target conformsToProtocol:@protocol(TranslateDataDelegate)], @"目标Controller未实现TransBundleDelegate协议");


    NSAssert([target respondsToSelector:@selector(transBundle:)], @"目标Controller未实现transBundle:方法");

    self.transDelegate = (id <TranslateDataDelegate>) target;

    [self.transDelegate transBundle:bundle];

    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag backToViewController:(UIViewController *)controller withBundle:(TranslateData *)bundle completion:(void (^ __nullable)(void))completion {
    UIViewController *target = controller;

    NSAssert([target conformsToProtocol:@protocol(TranslateDataDelegate)], @"目标Controller未实现TransBundleDelegate协议");


    NSAssert([target respondsToSelector:@selector(transBundle:)], @"目标Controller未实现transBundle:方法");

    self.transDelegate = (id <TranslateDataDelegate>) target;

    [self.transDelegate transBundle:bundle];

    [self dismissViewControllerAnimated:flag completion:completion];
}

- (void)transBundle:(TranslateData *)bundle forController:(UIViewController *)controller {
    UIViewController *target = controller;

    NSAssert([target conformsToProtocol:@protocol(TranslateDataDelegate)], @"目标Controller未实现TransBundleDelegate协议");


    NSAssert([target respondsToSelector:@selector(transBundle:)], @"目标Controller未实现transBundle:方法");

    self.transDelegate = (id <TranslateDataDelegate>) target;

    [self.transDelegate transBundle:bundle];
}

@end
