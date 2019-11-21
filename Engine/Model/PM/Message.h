//
//  Message.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property(nonatomic, strong) NSString *pmID;
@property(nonatomic, strong) NSString *pmTitle;
@property(nonatomic, strong) NSString *pmAuthor;
@property(nonatomic, strong) NSString *pmAuthorId;
@property(nonatomic, strong) NSString *pmTime;
@property(nonatomic, assign) BOOL isReaded;


@property(nonatomic, strong) NSString *forumhash;
@property(nonatomic, strong) NSString *ptid;
@property(nonatomic, strong) NSString *pid;


@end
