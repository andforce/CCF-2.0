//
//  UIImage+Tint.h
//  iOSMaps
//
//  Created by 迪远 王 on 15/12/12.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *)imageWithTintColorCompat:(UIColor *)tintColor;

- (UIImage *)scaleUIImage:(CGSize)maxSize;

@end
