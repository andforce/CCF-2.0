//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "NSUserDefaults+Setting.h"


@implementation NSUserDefaults (Setting)


- (void)setSignature:(BOOL)enable {

    NSNumber *value = enable ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0];
    [self setValue:value forKey:kSIGNATURE];
}

- (void)setTopThreadPost:(BOOL)show {
    NSNumber *value = show ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0];
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
@end
