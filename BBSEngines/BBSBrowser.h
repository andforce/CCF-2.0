//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBSConfigDelegate.h"
#import "AFImageDownloader.h"

@protocol BBSParserDelegate;
@class LoginUser;

@interface BBSBrowser : NSObject

@property(nonatomic, strong) AFHTTPSessionManager *browser;

@end
