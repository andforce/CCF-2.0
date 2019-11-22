//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonUtils : NSObject

+ (UIImage *)createImageWithColor:(UIColor *)color;

+ (NSInteger)readUserData:(NSString *)key;

+ (void)writeUserData:(NSString *)key withValue:(NSInteger)value;

+ (NSString *)timeForShort:(NSString *)time withFormat:(NSString *)format;

+ (NSString *)timeForShort:(NSString *)timeStamp;

+ (NSString *)randomNumber:(int)len;

@end
