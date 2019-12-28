//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSApiBaseViewController.h"
#import "BBSLocalApi.h"

@interface BBSApiBaseViewController ()

@end

@implementation BBSApiBaseViewController

#pragma mark initData

- (void)initData {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    self.forumApi = [BBSApiHelper forumApi:localForumApi.currentForumHost];
}

#pragma mark override-init

- (instancetype)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithCoder

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithName

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initData];
    }
    return self;
}

- (NSString *)currentForumHost {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *urlStr = [localForumApi currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

@end
