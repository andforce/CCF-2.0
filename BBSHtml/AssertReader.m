//
//  NSArray+AssertReader.m
//  Forum
//
//  Created by 迪远 王 on 2019/11/23.
//  Copyright © 2019 None. All rights reserved.
//

#import "AssertReader.h"

@implementation AssertReader : NSObject

+ (NSString *)read:(NSString *)fileName {
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil] encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)js_append_after_post {
    return [self read:@"append_after_post.js"];
}

+ (NSString *)js_click_fast_lib {
    return [self read:@"click_fast_lib.js"];
}

+ (NSString *)js_click_event_handler {
    return [self read:@"click_event_handler.js"];
}

+ (NSString *)js_chiphell_login {
    return [self read:@"chiphell_login.js"];
}

+ (NSString *)js_change_web_login_style {
    return [self read:@"change_web_login_style.js"];
}

+ (NSString *)html_content_template_append_one_post_floor {
    return [self read:@"content_template_append_one_post_floor.html"];
}

+ (NSString *)html_content_template_all_post_floors {
    return [self read:@"content_template_all_post_floors.html"];
}

+ (NSString *)html_content_template_message {
    return [self read:@"content_template_message.html"];
}

+ (NSString *)html_content_template_one_post_floor {
    return [self read:@"content_template_one_post_floor.html"];
}

+ (UIImage *)no_avatar {
    return [UIImage imageNamed:@"no_avatar.jpg"];
}

+ (UIImage *)attachment_flag {
    return [UIImage imageNamed:@"attachment_flag"];
}
@end
