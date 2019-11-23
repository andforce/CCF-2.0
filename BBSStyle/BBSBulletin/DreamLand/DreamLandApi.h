//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSBrowser.h"
#import "BBSApiBaseDelegate.h"
#import "vBulletinApiDelegate.h"

@interface DreamLandApi : BBSBrowser <BBSApiBaseDelegate, vBulletinApiDelegate>
@end