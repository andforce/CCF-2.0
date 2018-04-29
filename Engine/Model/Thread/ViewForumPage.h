//
//  ViewForumPage.h
//
//  Created by WDY on 16/3/16.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thread.h"
#import "PageNumber.h"

@interface ViewForumPage : NSObject

@property(nonatomic, assign) int forumId;
@property(nonatomic, strong) NSString *token;

@property(nonatomic, strong) NSMutableArray<Thread *> *dataList;
@property(nonatomic, strong) PageNumber *pageNumber;

@property(nonatomic, assign) BOOL isCanCreateThread;

@end
