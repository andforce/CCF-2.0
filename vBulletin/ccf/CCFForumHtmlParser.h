//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumParserDelegate.h"
#import "ForumBaseParserDelegate.h"
#import "vBulletinParserDelegate.h"


@interface CCFForumHtmlParser : NSObject <ForumBaseParserDelegate, vBulletinParserDelegate>
@end