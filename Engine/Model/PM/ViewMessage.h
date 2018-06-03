//
// Created by 迪远 王 on 2018/6/3.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;


@interface ViewMessage : NSObject

@property(nonatomic, strong) User *pmUserInfo;
@property(nonatomic, strong) NSString *pmID;
@property(nonatomic, strong) NSString *pmTitle;
@property(nonatomic, strong) NSString *pmTime;
@property(nonatomic, strong) NSString *pmContent;

@end