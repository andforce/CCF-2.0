//
//
//  vBulletinForumEngine
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
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

#import "BBSBaseParserDelegate.h"

@protocol BBSParserDelegate <BBSBaseParserDelegate, vBulletinParserDelegate, DiscuzParserDelegate>

@end
