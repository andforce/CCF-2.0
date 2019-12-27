//
//  Post.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCount.h"


@interface PostFloor : NSObject

@property(nonatomic, strong) NSString *postID;          //1. postId

@property(nonatomic, strong) NSString *postLouCeng;     //2. 帖子楼层
@property(nonatomic, strong) NSString *postTime;        //3. 帖子时间
@property(nonatomic, strong) NSString *postContent;     //4. content html

@property(nonatomic, strong) UserCount *postUserInfo;        //5. user

@end
