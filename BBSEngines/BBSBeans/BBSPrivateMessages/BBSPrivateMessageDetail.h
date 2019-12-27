//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 None. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserCount;


@interface BBSPrivateMessageDetail : NSObject

@property(nonatomic, strong) UserCount *pmUserInfo;
@property(nonatomic, strong) NSString *pmID;
@property(nonatomic, strong) NSString *pmTitle;
@property(nonatomic, strong) NSString *pmTime;
@property(nonatomic, strong) NSString *pmContent;

@end