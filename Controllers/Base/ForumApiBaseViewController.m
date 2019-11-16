//
//  ForumApiBaseViewController.m
//
//  Created by 迪远 王 on 16/4/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiBaseViewController.h"
#import "LocalForumApi.h"

@interface ForumApiBaseViewController ()

@end

@implementation ForumApiBaseViewController

#pragma mark initData

- (void)initData {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    self.forumApi = [ForumApiHelper forumApi:localForumApi.currentForumHost];
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

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *urlStr = [localForumApi currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
