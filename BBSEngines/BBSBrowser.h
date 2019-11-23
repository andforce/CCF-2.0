//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 None. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBSConfigDelegate.h"
#import "AFImageDownloader.h"

@protocol BBSParserDelegate;
@class BBSUser;

@interface BBSBrowser : NSObject

@property(nonatomic, strong) AFHTTPSessionManager *browser;

@end
