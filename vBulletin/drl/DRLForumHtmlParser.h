//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumBaseParserDelegate.h"
#import "vBulletinParserDelegate.h"


@interface DRLForumHtmlParser : NSObject <ForumBaseParserDelegate, vBulletinParserDelegate>
@end