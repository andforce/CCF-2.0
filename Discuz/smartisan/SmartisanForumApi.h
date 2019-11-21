//
//  TForumApi.h
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSBrowser.h"
#import "BBSApiBaseDelegate.h"
#import "DiscuzApiDelegate.h"


@interface SmartisanForumApi : BBSBrowser <BBSApiBaseDelegate, DiscuzApiDelegate>

@end
