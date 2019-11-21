//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSConfigDelegate.h"


@interface vBulletinCommonConfig : NSObject <BBSBaseConfigDelegate, vBulletinConfigDelegate>

@property(nonatomic) NSURL *forumURL;
@end