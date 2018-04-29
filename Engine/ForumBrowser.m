//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "ForumBrowser.h"

@implementation ForumBrowser

- (instancetype)init {
    self = [super init];
    if (self){
        _browser = [AFHTTPSessionManager manager];
        _browser.responseSerializer = [AFHTTPResponseSerializer serializer];
        _browser.responseSerializer.acceptableContentTypes = [_browser.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [_browser.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36" forHTTPHeaderField:@"User-Agent"];

    }
    return self;
}

@end