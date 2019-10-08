//
//  LeftDrawerItem.m
//  iOSMaps
//
//  Created by 迪远 王 on 15/12/12.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "LeftDrawerItem.h"
#import "CommonUtils.h"
#import "UIImage+Tint.h"
#import "UIColor+MyColor.h"


#define kMarginLeft 15

@implementation LeftDrawerItem


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {

        UIColor *blueHighLightColor = [UIColor colorWithBlueHighLight];

        UIImage *leftImage = self.imageView.image;


        UIImage *leftImageTint;
        if (@available(iOS 13.0, *)) {
            leftImageTint = [leftImage imageWithTintColor:blueHighLightColor];
        } else {
            leftImageTint = [leftImage imageWithTintColorCompat:blueHighLightColor];
        }

        [self setImage:leftImage forState:UIControlStateNormal];
        [self setImage:leftImageTint forState:UIControlStateHighlighted];
        [self setImage:leftImageTint forState:UIControlStateSelected];
        
        NSString *text = self.titleLabel.text;
        [self setTitle:text forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:blueHighLightColor forState:UIControlStateHighlighted];
        [self setTitleColor:blueHighLightColor forState:UIControlStateSelected];


        UIImage *normalImage = [CommonUtils createImageWithColor:[UIColor whiteColor]];
        [self setBackgroundImage:normalImage forState:UIControlStateNormal];


        UIImage *highLight = [CommonUtils createImageWithColor:[UIColor colorWithButtonHighLight]];
        [self setBackgroundImage:highLight forState:UIControlStateHighlighted];
        [self setBackgroundImage:highLight forState:UIControlStateSelected];


        //self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;


    }

    return self;
}

- (id)initWithLeftIcon:(NSString *)name andRightText:(NSString *)text {
    if (self = [super init]) {

        UIColor *blueHighLightColor = [UIColor colorWithBlueHighLight];

        UIImage *leftImage = [UIImage imageNamed:name];


        UIImage *leftImageTint;
        if (@available(iOS 13.0, *)) {
            leftImageTint = [leftImage imageWithTintColor:blueHighLightColor];

        } else {
            leftImageTint = [leftImage imageWithTintColorCompat:blueHighLightColor];
        }
        
        [self setImage:leftImage forState:UIControlStateNormal];
        [self setImage:leftImageTint forState:UIControlStateHighlighted];
        [self setImage:leftImageTint forState:UIControlStateSelected];

        [self setTitle:text forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:blueHighLightColor forState:UIControlStateHighlighted];
        [self setTitleColor:blueHighLightColor forState:UIControlStateSelected];


        UIImage *normalImage = [CommonUtils createImageWithColor:[UIColor whiteColor]];
        [self setBackgroundImage:normalImage forState:UIControlStateNormal];


        UIImage *highLight = [CommonUtils createImageWithColor:[UIColor colorWithButtonHighLight]];
        [self setBackgroundImage:highLight forState:UIControlStateHighlighted];
        [self setBackgroundImage:highLight forState:UIControlStateSelected];



        //self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;


    }

    return self;
}


- (void)didMoveToSuperview {
    
    UIView *superView = [self superview];
    CGRect rect = superView.frame;

    NSLog(@"SUper ----> didMoveToSuperview %lf", rect.size.width);
    CGRect selfFrame = self.frame;
    NSLog(@"Self ---> didMoveToSuperview %lf", selfFrame.size.width);
    selfFrame.size.width = rect.size.width;

    self.frame = selfFrame;
}
@end
