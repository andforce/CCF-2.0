//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostFloor.h"
#import "PageNumber.h"

@interface ViewThreadPage : NSObject

@property(nonatomic, assign) int threadID;                          // 1. ID
@property(nonatomic, assign) int forumId;                           // 2. 主题所属论坛
@property(nonatomic, strong) NSString *threadTitle;                 // 3. title
@property(nonatomic, strong) NSMutableArray<PostFloor *> *postList;      // 4. Posts
@property(nonatomic, strong) NSString *originalHtml;                // 5. orgHtml

@property(nonatomic, strong) PageNumber *pageNumber;                // 6. number

@property(nonatomic, assign) BOOL isCanReply;                       // 7. can reply

@property(nonatomic, strong) NSString *securityToken;               // 8. forumhash
@property(nonatomic, strong) NSString *ajaxLastPost;                // 9. ajaxLastPost


#pragma for PhpWind
@property(nonatomic, strong) NSString *quickReplyTitle;            // 10. quick reply title

@end
