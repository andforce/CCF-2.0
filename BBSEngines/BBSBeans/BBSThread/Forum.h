//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Forum : NSObject

@property(nonatomic, assign) int forumId;
@property(nonatomic, strong) NSString *forumName;
@property(nonatomic, strong) NSString *forumHost;
@property(nonatomic, assign) int parentForumId;

@property(nonatomic, strong) NSArray<Forum *> *childForums;

@end
