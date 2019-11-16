//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumBrowser.h"
#import "ForumApiBaseDelegate.h"
#import "DiscuzApiDelegate.h"

@interface CHHForumApi : ForumBrowser <ForumApiBaseDelegate, DiscuzApiDelegate>
@end