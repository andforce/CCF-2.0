//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSBaseConfigDelegate.h"
#import "DiscuzConfigDelegate.h"


@interface DiscuzCommonConfig : NSObject <BBSBaseConfigDelegate, DiscuzConfigDelegate>

@property NSURL *forumURL;

@end