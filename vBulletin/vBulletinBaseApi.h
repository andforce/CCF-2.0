//
// Created by 迪远 王 on 2018/6/2.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumBrowser.h"
#import "vBulletinApiDelegate.h"
#import "ForumApiBaseDelegate.h"


@interface vBulletinBaseApi : ForumBrowser<ForumApiBaseDelegate, vBulletinApiDelegate>
@end