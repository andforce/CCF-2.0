//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSBrowser.h"
#import "BBSApiBaseDelegate.h"
#import "DiscuzApiDelegate.h"

@interface ChiphellForumApi : BBSBrowser <BBSApiBaseDelegate, DiscuzApiDelegate>
@end