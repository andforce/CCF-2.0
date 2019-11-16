//
//  AutoSendBackTabBar.m
//  Forum
//
//  Created by WDY on 2017/11/17.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "AutoSendBackTabBar.h"
#import "ForumTabBarController.h"

@implementation AutoSendBackTabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    self.clipsToBounds = NO;

    id controller = (ForumTabBarController *) self.superview.nextResponder;
    if ([controller isKindOfClass:[ForumTabBarController class]]) {
        [controller bringLeftDrawerToFront];
    }
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
}

@end
