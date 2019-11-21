//
//  AutoSendBackTabBar.m
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "AutoSendBackTabBar.h"
#import "BBSTabBarController.h"

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

    id controller = (BBSTabBarController *) self.superview.nextResponder;
    if ([controller isKindOfClass:[BBSTabBarController class]]) {
        [controller bringLeftDrawerToFront];
    }
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
}

@end
