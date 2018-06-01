//
// Created by 迪远 王 on 2018/6/2.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumConfigDelegate.h"


@interface vBulletinCommonConfig : NSObject <ForumURLCommonConfig, vBulletinConfigDelegate>

@property NSURL *forumURL;
@end