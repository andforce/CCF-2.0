//
//  AutoRelayoutUITextView.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "AutoRelayoutUITextView.h"

@implementation AutoRelayoutUITextView {
    UILabel *placeHoler;

}


- (instancetype)init {
    if (self = [super init]) {
        [self initPlaceHolder];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initPlaceHolder];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initPlaceHolder];
    }
    return self;
}

- (void)initPlaceHolder {
    placeHoler = [[UILabel alloc] initWithFrame:self.frame];

    [self addSubview:placeHoler];
    placeHoler.text = @" 发表您的态度...";
    placeHoler.font = [UIFont systemFontOfSize:14];
    placeHoler.enabled = NO;

    UIColor *borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 5.0;
}


- (void)showPlaceHolder:(BOOL)show {
    if (show) {
        placeHoler.text = @" 发表您的态度...";
    } else {
        placeHoler.text = @"";
    }
}


- (void)setContentSize:(CGSize)contentSize {

    CGSize orgSize = self.contentSize;
    [super setContentSize:contentSize];

    if (self.contentSize.height > kMaxHeight || self.contentSize.height < kMiniHeight) {
        return;
    }

    if (orgSize.height != self.contentSize.height) {
        CGRect newFream = self.frame;

        newFream.size.height = self.contentSize.height;
        self.frame = newFream;
        if ([self.heightDelegate respondsToSelector:@selector(heightChanged:)]) {
            [self.heightDelegate heightChanged:self.contentSize.height];
        }
    }
}

@end
