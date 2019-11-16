//
//  AFHTTPSessionManager+SimpleAction.h
//
//  Created by WDY on 16/1/15.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^RequestCallback)(BOOL isSuccess, NSString *html);

typedef NS_ENUM(NSInteger, Charset) {
    UTF_8 = 0,
    GBK

};

@interface AFHTTPSessionManager (SimpleAction)

- (void)GETWithURLString:(NSString *)url parameters:(NSDictionary *)parameters charset:(Charset)charset requestCallback:(RequestCallback)callback;

- (void)POSTWithURLString:(NSString *)url parameters:(id)parameters charset:(Charset)charset requestCallback:(RequestCallback)callback;

- (void)POSTWithURLString:(NSString *)url parameters:(id)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block charset:(Charset)charset requestCallback:(RequestCallback)callback;

@end
