//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;


@interface BBSPrivateMessageDetail : NSObject

@property(nonatomic, strong) User *pmUserInfo;
@property(nonatomic, strong) NSString *pmID;
@property(nonatomic, strong) NSString *pmTitle;
@property(nonatomic, strong) NSString *pmTime;
@property(nonatomic, strong) NSString *pmContent;

@end