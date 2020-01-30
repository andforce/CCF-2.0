//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 None. All rights reserved.
//

#import "BBSBrowser.h"

#import "Forum.pch"

@implementation BBSBrowser

- (instancetype)init {
    self = [super init];
    if (self) {
        _browser = [AFHTTPSessionManager manager];
        _browser.responseSerializer = [AFHTTPResponseSerializer serializer];
        _browser.responseSerializer.acceptableContentTypes = [_browser.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [_browser.requestSerializer setValue:ForumUserAgent forHTTPHeaderField:@"User-Agent"];

    }
    return self;
}

@end