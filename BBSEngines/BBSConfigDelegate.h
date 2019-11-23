//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBSCommonConfigDelegate.h"
#import "DiscuzConfigDelegate.h"
#import "PhpWindConfigDelegage.h"
#import "vBulletinConfigDelegate.h"
#import "BBSBaseConfigDelegate.h"

@protocol BBSConfigDelegate <BBSBaseConfigDelegate, BBSCommonConfigDelegate, DiscuzConfigDelegate, PhpWindConfigDelegage, vBulletinConfigDelegate>


@end