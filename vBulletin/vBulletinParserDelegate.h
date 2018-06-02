//
// Created by 迪远 王 on 2018/5/1.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol vBulletinParserDelegate <NSObject>

- (NSString *)parsePostHash:(NSString *)html;

- (NSString *)parserPostStartTime:(NSString *)html;

- (NSString *)parseLoginErrorMessage:(NSString *)html;

- (NSString *)parseQuote:(NSString *)html;

- (NSString *)parseQuickReplyQuoteContent:(NSString *)html;

- (NSString *)parseQuickReplyTitle:(NSString *)html;

- (NSString *)parseQuickReplyTo:(NSString *)html;

@end