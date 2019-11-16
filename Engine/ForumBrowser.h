//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ForumConfigDelegate.h"
#import "AFImageDownloader.h"

@protocol ForumParserDelegate;
@class LoginUser;

@interface ForumBrowser : NSObject

@property(nonatomic, strong) AFHTTPSessionManager *browser;

@end
