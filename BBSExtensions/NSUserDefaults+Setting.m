//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "NSUserDefaults+Setting.h"


@implementation NSUserDefaults (Setting)


- (void)setSignature:(BOOL)enable {

    NSNumber *value = enable ? @1 : @0;
    [self setValue:value forKey:kSIGNATURE];
}

- (void)setTopThreadPost:(BOOL)show {
    NSNumber *value = show ? @1 : @0;
    [self setValue:value forKey:kTOP_THREAD];
}


- (BOOL)isSignatureEnabled {
    NSNumber *value = [self valueForKey:kSIGNATURE];
    return [value intValue] == 1;
}

- (BOOL)isTopThreadPostCanShow {
    NSNumber *value = [self valueForKey:kTOP_THREAD];
    return [value intValue] == 1;
}

- (int)fontSize {
    NSInteger size = [self integerForKey:@"font_size"];
    if (size < 100){
        return 100;
    }
    return size;
}

- (void)setFontSize:(int)size {
    [self setValue:@(size) forKey:@"font_size"];
}


@end
