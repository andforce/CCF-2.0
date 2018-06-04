//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumBrowser.h"
#import "ForumApiBaseDelegate.h"
#import "vBulletinApiDelegate.h"

@interface DRLForumApi : ForumBrowser<ForumApiBaseDelegate, vBulletinApiDelegate>
@end