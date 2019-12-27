//
//  AFHTTPSessionManager+SimpleAction.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
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
