//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TranslateData : NSObject

- (void)putIntValue:(int)value forKey:(NSString *)key;

- (void)putStringValue:(NSString *)value forKey:(NSString *)key;

- (int)getIntValue:(NSString *)key;

- (NSString *)getStringValue:(NSString *)key;

- (void)putObjectValue:(id)value forKey:(NSString *)key;

- (id)getObjectValue:(NSString *)key;

- (BOOL)containsKey:(NSString *)key;
@end