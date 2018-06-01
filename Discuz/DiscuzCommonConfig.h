//
// Created by 迪远 王 on 2018/6/2.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumURLCommonConfig.h"
#import "DiscuzConfigDelegate.h"


@interface DiscuzCommonConfig : NSObject<ForumURLCommonConfig, DiscuzConfigDelegate>

@property NSURL *forumURL;

@end