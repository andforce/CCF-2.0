//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSIGNATURE @"setting_signature"
#define kTOP_THREAD @"setting_top_thread"

@interface NSUserDefaults (Setting)

- (void)setSignature:(BOOL)enable;

- (void)setTopThreadPost:(BOOL)show;

- (BOOL)isSignatureEnabled;

- (BOOL)isTopThreadPostCanShow;

@end
