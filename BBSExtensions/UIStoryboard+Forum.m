//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "UIStoryboard+Forum.h"

#import "AppDelegate.h"


#define kCCFStoryboard @"Main"


@implementation UIStoryboard (Forum)

+ (UIStoryboard *)mainStoryboard {
    return [UIStoryboard storyboardWithName:kCCFStoryboard bundle:nil];
}

- (UIViewController *)finControllerById:(NSString *)controllerId {
    UITabBarController *controller = [self instantiateViewControllerWithIdentifier:controllerId];
    return controller;
}

- (void)changeRootViewControllerTo:(NSString *)identifier {

    [self changeRootViewControllerTo:identifier withAnim:UIViewAnimationOptionTransitionFlipFromTop];
}

- (void)changeRootViewControllerToController:(UIViewController *)controller {

    [self changeRootViewControllerToController:controller withAnim:UIViewAnimationOptionTransitionFlipFromTop];
}


- (void)changeRootViewControllerTo:(NSString *)identifier withAnim:(UIViewAnimationOptions)anim {
    UITabBarController *rootViewController = [self instantiateViewControllerWithIdentifier:identifier];

    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];

    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    [UIView transitionWithView:app.window
                      duration:0.5
                       options:anim
                    animations:^{
                        app.window.rootViewController = rootViewController;
                    }
                    completion:nil];
}

- (void)changeRootViewControllerToController:(UIViewController *)controller withAnim:(UIViewAnimationOptions)anim {
    [[UIApplication sharedApplication].keyWindow setRootViewController:controller];

    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    [UIView transitionWithView:app.window
                      duration:0.5
                       options:anim
                    animations:^{
                        app.window.rootViewController = controller;
                    }
                    completion:nil];
}

@end
