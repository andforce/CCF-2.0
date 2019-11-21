//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
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
