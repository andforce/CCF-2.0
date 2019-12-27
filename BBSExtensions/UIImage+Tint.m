//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

- (UIImage *)imageWithTintColorCompat:(UIColor *)tintColor {

    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);

    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;

}

- (UIImage *)scaleUIImage:(CGSize)maxSize {
    CGSize size = self.size;

    if (size.height > maxSize.height || size.width > maxSize.width) {
        CGFloat heightScale = maxSize.height / size.height;
        CGFloat widthScale = maxSize.width / size.width;

        CGFloat scale = heightScale > widthScale ? widthScale : heightScale;

        CGFloat width = size.width;
        CGFloat height = size.height;

        CGFloat scaledWidth = width * scale;
        CGFloat scaledHeight = height * scale;

        CGSize newSize = CGSizeMake(scaledWidth, scaledHeight);
        UIGraphicsBeginImageContext(newSize);//thiswillcrop
        [self drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;

    } else {
        return self;
    }
}

@end
