//
//  ForumParserDelegate.h
//  vBulletinForumEngine
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginUser.h"
#import "Message.h"
#import "ViewMessagePage.h"
#import "Post.h"
#import "User.h"
#import "Forum.h"
#import "Thread.h"
#import "UserProfile.h"
#import "ViewThreadPage.h"
#import "ViewForumPage.h"
#import "ViewSearchForumPage.h"
#import "PageNumber.h"

#import "vBulletinParserDelegate.h"
#import "DiscuzParserDelegate.h"

#import "ForumBaseParserDelegate.h"

@protocol ForumParserDelegate <ForumBaseParserDelegate, vBulletinParserDelegate, DiscuzParserDelegate>

@end
