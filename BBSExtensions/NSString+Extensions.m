//  DRL
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)


- (NSString *)replaceUnicode {

    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];

    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:nil error:nil];

    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];

}

- (NSString *)md5HexDigest {
    const char *str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    unsigned long len = strlen(str);

    CC_MD5(str, (CC_LONG) len, result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

- (NSString *)stringWithRegular:(NSString *)regular {

    NSRange timeRange = [self rangeOfString:regular options:NSRegularExpressionSearch];

    if (timeRange.location != NSNotFound) {
        return [self substringWithRange:timeRange];
    }
    return nil;
}

- (NSString *)stringWithRegular:(NSString *)regular andChild:(NSString *)childRegular {
    NSString *parentStyring = [self findStringWithRegular:self :regular];

    if (parentStyring != nil) {
        return [parentStyring findStringWithRegular:parentStyring :childRegular];
    }

    return nil;
}


- (NSString *)findStringWithRegular:(NSString *)src :(NSString *)regular {

    NSRange range = [src rangeOfString:regular options:NSRegularExpressionSearch];

    if (range.location != NSNotFound) {
        return [src substringWithRange:range];
    }
    return nil;
}

- (NSString *)removeStringWithRegular:(NSString *)regular {
    NSArray *toRemove = [self arrayWithRegular:regular];
    NSString *result = self;
    for (NSString *remove in toRemove) {
        result = [result stringByReplacingOccurrencesOfString:remove withString:@""];
    }
    return result;
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray *)arrayWithRegular:(NSString *)regular {

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regular options:NSRegularExpressionCaseInsensitive error:nil];

    NSArray *result = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];

    NSMutableArray *stringArray = [NSMutableArray array];

    for (NSTextCheckingResult *tmpresult in result) {

        NSString *str = [self substringWithRange:tmpresult.range];
        [stringArray addObject:str];

    }
    return [stringArray copy];
}

- (NSString *)encodeWithGBKEncoding {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *encoded = [self stringByAddingPercentEscapesUsingEncoding:enc];
    return encoded;
}

- (NSString *)decodeWithGBKEncoding {
    NSString *cleanString = [self stringByReplacingOccurrencesOfString:@"%" withString:@""];

    NSData *data = [self stringFromHexStringNew:cleanString];
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *decoded = [[NSString alloc] initWithData:data encoding:encoding];
    return decoded;
}

- (NSData *)dataForGBK {
    NSString *encodeStr = [[self encodeWithGBKEncoding] stringByReplacingOccurrencesOfString:@"%" withString:@""];

    return [self stringFromHexStringNew:encodeStr];
}

- (NSData *)dataForUTF8 {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)stringFromHexStringNew:(NSString *)hexString {

    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:[hexString length] / 4];

    for (int i = 0; i < [hexString length] - 1; i += 2) {

        NSString *hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSString *temp10 = [NSString stringWithFormat:@"%lu", strtoul([hexCharStr UTF8String], 0, 16)];
        NSLog(@"心跳数字 10进制 %@", temp10);
        //转成数字
        int cycleNumber = [temp10 intValue];
        NSLog(@"心跳数字 ：%d", cycleNumber);

        [resData appendBytes:&cycleNumber length:1];
    }
    return [resData copy];
}

@end
