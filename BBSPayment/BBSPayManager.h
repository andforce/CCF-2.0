//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 None. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSPayManager : NSObject

typedef void (^PayHandler)(BOOL isSuccess);

typedef void (^StatusHandler)(int status);

typedef void (^TimeHaveHandler)(long timeHave);

typedef void (^VerifyHandler)(NSDictionary *response);

+ (instancetype)shareInstance;


- (void)verifyPay:(NSString *)productID with:(TimeHaveHandler)handler;

- (void)payForProductID:(NSString *)productID with:(PayHandler)handler;

- (void)restorePayForProductID:(NSString *)productID with:(PayHandler)handler;

- (BOOL)hasPayed:(NSString *)productID;

- (void)setPayed:(BOOL)payed for:(NSString *)productID;

- (NSNumber *)getPayedExpireDate:(NSString *)productID;

- (void)removeTransactionObserver;

@end
