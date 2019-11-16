//
// Created by 迪远 王 on 2016/11/6.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TransBundle : NSObject

- (void)putIntValue:(int)value forKey:(NSString *)key;

- (void)putStringValue:(NSString *)value forKey:(NSString *)key;

- (int)getIntValue:(NSString *)key;

- (NSString *)getStringValue:(NSString *)key;

- (void)putObjectValue:(id)value forKey:(NSString *)key;

- (id)getObjectValue:(NSString *)key;

- (BOOL)containsKey:(NSString *)key;
@end