//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSParserDelegate.h"
#import "BBSBaseParserDelegate.h"
#import "vBulletinParserDelegate.h"


@interface Et8NetHtmlParser : NSObject <BBSBaseParserDelegate, vBulletinParserDelegate>
@end