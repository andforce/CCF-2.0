//
//  TForumApi.h
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumBrowser.h"
#import "ForumApiBaseDelegate.h"
#import "DiscuzApiDelegate.h"


@interface TForumApi : ForumBrowser <ForumApiBaseDelegate, DiscuzApiDelegate>

@end
