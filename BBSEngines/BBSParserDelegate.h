//  vBulletinForumEngine
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSUser.h"
#import "BBSPrivateMessage.h"
#import "BBSPrivateMessagePage.h"
#import "PostFloor.h"
#import "UserCount.h"
#import "Forum.h"
#import "Thread.h"
#import "CountProfile.h"
#import "ViewThreadPage.h"
#import "ViewForumPage.h"
#import "BBSSearchResultPage.h"
#import "PageNumber.h"

#import "vBulletinParserDelegate.h"
#import "DiscuzParserDelegate.h"

#import "BBSBaseParserDelegate.h"

@protocol BBSParserDelegate <BBSBaseParserDelegate, vBulletinParserDelegate, DiscuzParserDelegate>

@end
