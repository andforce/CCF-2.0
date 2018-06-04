//
//  ForumApi.h
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginUser.h"
#import "ViewForumPage.h"
#import "ViewSearchForumPage.h"
#import "ForumConfigDelegate.h"
#import "Forum.h"
#import "vBulletinApiDelegate.h"
#import "DiscuzApiDelegate.h"
#import "PhpWindApiDelegate.h"
#import "ForumApiBaseDelegate.h"

@class ViewThreadPage;
@class ViewMessagePage;
@class Message;
@class ForumWebViewController;

typedef void (^UserInfoHandler)(BOOL isSuccess, id userName, id userId);

@protocol ForumApiDelegate <ForumApiBaseDelegate, vBulletinApiDelegate, DiscuzApiDelegate, PhpWindApiDelegate>


@end
