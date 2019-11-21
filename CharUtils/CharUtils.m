//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "CharUtils.h"
#import "CharUnicodeBlock.h"

@implementation CharUtils


+ (BOOL)isCNCharCode:(unichar)c {
    UnicodeBlock ub = [CharUnicodeBlock unicodeBlockOf:c];
    if (ub == CJK_UNIFIED_IDEOGRAPHS || ub == CJK_COMPATIBILITY_IDEOGRAPHS
            || ub == CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A || ub == CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B
            || ub == CJK_SYMBOLS_AND_PUNCTUATION || ub == HALFWIDTH_AND_FULLWIDTH_FORMS
            || ub == GENERAL_PUNCTUATION) {
        return true;
    }
    return false;
}


@end


