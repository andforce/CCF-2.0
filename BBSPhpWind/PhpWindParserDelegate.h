//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewForumPage;

@protocol PhpWindParserDelegate <NSObject>

- (ViewForumPage *)parseListMyAllThreadsFromHtml:(NSString *)html;

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int)type;

@end