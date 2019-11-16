//
//  ViewThreadPage.h
//
//  Created by WDY on 15/12/29.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "PageNumber.h"

@interface ViewThreadPage : NSObject

@property(nonatomic, assign) int threadID;                          // 1. ID
@property(nonatomic, assign) int forumId;                           // 2. 主题所属论坛
@property(nonatomic, strong) NSString *threadTitle;                 // 3. title
@property(nonatomic, strong) NSMutableArray<Post *> *postList;      // 4. Posts
@property(nonatomic, strong) NSString *originalHtml;                // 5. orgHtml

@property(nonatomic, strong) PageNumber *pageNumber;                // 6. number

@property(nonatomic, assign) BOOL isCanReply;                       // 7. can reply

@property(nonatomic, strong) NSString *securityToken;               // 8. forumhash
@property(nonatomic, strong) NSString *ajaxLastPost;                // 9. ajaxLastPost


#pragma for PhpWind
@property(nonatomic, strong) NSString *quickReplyTitle;            // 10. quick reply title

@end
