//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Thread : NSObject

@property(nonatomic, strong) NSString *threadID;           // 1. ID
@property(nonatomic, strong) NSString *threadTitle;        // 2. 主题

@property(nonatomic, assign) BOOL isTopThread;             // 3.是否置顶帖子
@property(nonatomic, assign) BOOL isGoodNess;              // 4.是否是精华帖子
@property(nonatomic, assign) BOOL isContainsImage;         // 5.是否包含图片
@property(nonatomic, assign) int totalPostPageCount;       // 6.总回帖页数


@property(nonatomic, strong) NSString *threadAuthorName;   // 7. 作者名字
@property(nonatomic, strong) NSString *threadAuthorID;     // 8. 作者ID

@property(nonatomic, strong) NSString *postCount;          // 9.回复数
@property(nonatomic, strong) NSString *openCount;          // 10.查看数量

@property(nonatomic, strong) NSString *lastPostTime;       // 11. 最后发表时间
@property(nonatomic, strong) NSString *lastPostAuthorName; // 12. 最后发表的人


// 搜索页面
@property(nonatomic, strong) NSString *fromFormName;       // 13.所属论坛名称



@end
