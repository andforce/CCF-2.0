//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

/**
* 将UIColor变换为UIImage
*
**/
+ (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return theImage;
}

+ (NSInteger)readUserData:(NSString *)key {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSUInteger value = (NSUInteger) [defaults integerForKey:key];

    return value;
}


+ (void)writeUserData:(NSString *)key withValue:(NSInteger)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:key];
    [defaults synchronize];
}


+ (NSString *)timeForShort:(NSString *)time withFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:time];

    NSTimeInterval intervalTime = date.timeIntervalSinceNow;

    NSTimeInterval interval = -intervalTime;
    if (interval < 60) {
        return @"刚刚";
    } else if (interval >= 60 && interval <= 60 * 60) {
        return [NSString stringWithFormat:@"%d分钟前", (int) (interval / 60)];
    } else if (interval > 60 * 60 && interval < 60 * 60 * 24) {
        return [NSString stringWithFormat:@"%d小时前", (int) (interval / (60 * 60))];
    } else if (interval >= 60 * 60 * 24 && interval < 60 * 60 * 24 * 7) {
        return [NSString stringWithFormat:@"%d天前", (int) (interval / (60 * 60 * 24))];
    } else if (interval >= 60 * 60 * 24 * 7 && interval < 60 * 60 * 24 * 30) {
        return [NSString stringWithFormat:@"%d周前", (int) (interval / (60 * 60 * 24 * 7))];
    } else if (interval >= 60 * 60 * 24 * 30 && interval <= 60 * 60 * 24 * 365) {
        return [NSString stringWithFormat:@"%d月前", (int) (interval / (60 * 60 * 24 * 30))];
    } else if (interval > 60 * 60 * 24 * 365) {
        return [NSString stringWithFormat:@"%d年前", (int) (interval / (60 * 60 * 24 * 365))];
    }

    return time;
}

+ (NSString *)timeForShort:(NSString *)timeStamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStamp integerValue]];

    NSTimeInterval intervalTime = date.timeIntervalSinceNow;

    NSTimeInterval interval = -intervalTime;
    if (interval < 60) {
        return @"刚刚";
    } else if (interval >= 60 && interval <= 60 * 60) {
        return [NSString stringWithFormat:@"%d分钟前", (int) (interval / 60)];
    } else if (interval > 60 * 60 && interval < 60 * 60 * 24) {
        return [NSString stringWithFormat:@"%d小时前", (int) (interval / (60 * 60))];
    } else if (interval >= 60 * 60 * 24 && interval < 60 * 60 * 24 * 7) {
        return [NSString stringWithFormat:@"%d天前", (int) (interval / (60 * 60 * 24))];
    } else if (interval >= 60 * 60 * 24 * 7 && interval < 60 * 60 * 24 * 30) {
        return [NSString stringWithFormat:@"%d周前", (int) (interval / (60 * 60 * 24 * 7))];
    } else if (interval >= 60 * 60 * 24 * 30 && interval <= 60 * 60 * 24 * 365) {
        return [NSString stringWithFormat:@"%d月前", (int) (interval / (60 * 60 * 24 * 30))];
    } else if (interval > 60 * 60 * 24 * 365) {
        return [NSString stringWithFormat:@"%d年前", (int) (interval / (60 * 60 * 24 * 365))];
    }

    return timeStamp;
}

+ (NSString *)randomNumber:(int)len {
    static const NSString *kRandomAlphabet = @"0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity:(NSUInteger) len];
    for (int i = 0; i < len; i++) {
        [randomString appendFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((u_int32_t) [kRandomAlphabet length])]];
    }
    return randomString;
}

@end
