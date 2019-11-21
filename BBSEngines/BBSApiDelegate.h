//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginUser.h"
#import "ViewForumPage.h"
#import "ViewSearchForumPage.h"
#import "BBSConfigDelegate.h"
#import "Forum.h"
#import "vBulletinApiDelegate.h"
#import "DiscuzApiDelegate.h"
#import "PhpWindApiDelegate.h"
#import "BBSApiBaseDelegate.h"

@class ViewThreadPage;
@class ViewMessagePage;
@class Message;
@class BBSWebViewController;

typedef void (^UserInfoHandler)(BOOL isSuccess, id userName, id userId);

@protocol BBSApiDelegate <BBSApiBaseDelegate, vBulletinApiDelegate, DiscuzApiDelegate, PhpWindApiDelegate>


@end
