//  WKWebVIewHybridDemo
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WKWebVIew)

+ (void)wk_registerScheme:(NSString *)scheme;

+ (void)wk_unregisterScheme:(NSString *)scheme;


@end
