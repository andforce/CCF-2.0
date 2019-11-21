//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewForumPage;

@protocol DiscuzParserDelegate <NSObject>

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html;

- (ViewForumPage *)parseNoticeMessageFromHtml:(NSString *)html;

@end