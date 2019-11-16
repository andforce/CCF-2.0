//
// Created by WDY on 2017/12/12.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <StoreKit/StoreKit.h>

@interface PayManager : NSObject

typedef void (^PayHandler)(BOOL isSuccess);

typedef void (^VerifyHandler)(NSDictionary *response);

+ (instancetype)shareInstance;


- (void)verifyPay:(NSString *)productID with:(VerifyHandler)handler;

- (void)payForProductID:(NSString *)productID with:(PayHandler)handler;

- (void)restorePayForProductID:(NSString *)productID with:(PayHandler)handler;

- (BOOL)hasPayed:(NSString *)productID;

- (void)setPayed:(BOOL)payed for:(NSString *)productID;

- (void)removeTransactionObserver;

@end
