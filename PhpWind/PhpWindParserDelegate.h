//
// Created by 迪远 王 on 2018/6/3.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewForumPage;

@protocol PhpWindParserDelegate <NSObject>

- (ViewForumPage *)parseListMyAllThreadsFromHtml:(NSString *)html;

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int)type;

@end