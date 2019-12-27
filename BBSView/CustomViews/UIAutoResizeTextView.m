//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "UIAutoResizeTextView.h"
#import "Forum.pch"

@implementation UIAutoResizeTextView {
    float topY;
}

- (void)didMoveToSuperview {
    topY = self.frame.origin.y + 64 + 10;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillShow:(id)sender {

    CGRect keyboardFrame;


    [[[((NSNotification *) sender) userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];


    [UIView animateWithDuration:0.3 animations:^{

        CGRect frame = self.frame;

        float keyboardHeight = CGRectGetHeight(keyboardFrame);

        float fieldHeight = SCREEN_HEIGHT - topY - keyboardHeight;

        frame.size.height = fieldHeight;

        self.frame = frame;

    }];

}

- (void)keyboardWillHide:(id)sender {
    CGRect keyboardFrame;

    [[[((NSNotification *) sender) userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];


    [UIView animateWithDuration:0.3 animations:^{

        CGRect frame = self.frame;


        float fieldHeight = SCREEN_HEIGHT - topY;

        frame.size.height = fieldHeight;

        self.frame = frame;

    }];

}
@end
