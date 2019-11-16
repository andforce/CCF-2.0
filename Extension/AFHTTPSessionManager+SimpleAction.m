//
//  AFHTTPSessionManager+SimpleAction.m
//
//  Created by WDY on 16/1/15.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "AFHTTPSessionManager+SimpleAction.h"
#import "NSString+Extensions.h"
#import "NSData+UTF8.h"

@implementation AFHTTPSessionManager (SimpleAction)


- (void)GETWithURL:(NSURL *)url parameters:(NSDictionary *)parameters charset:(Charset)charset requestCallback:(RequestCallback)callback {

    [self GET:[url absoluteString] parameters:parameters progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {

        if (charset == GBK) {

            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *encodeStr = [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:enc];
//            NSString *encodeStr = [responseObject gbkString];
            callback(YES, encodeStr);
        } else {
            NSString *orgHtml = [responseObject utf8String];
            NSString *html = [orgHtml replaceUnicode];
            if (html == nil) {
                callback(YES, orgHtml);
            } else {
                callback(YES, html);
            }
        }

    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        callback(NO, @"网络异常");
    }];
}

- (void)POSTWithURL:(NSURL *)url parameters:(id)parameters charset:(Charset)charset requestCallback:(RequestCallback)callback {

    [self POST:[url absoluteString] parameters:parameters progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {

        if (charset == GBK) {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *encodeStr = [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:enc];
            callback(YES, encodeStr);
        } else {
            NSString *orgHtml = [responseObject utf8String];
            NSString *html = [orgHtml replaceUnicode];

            if (html == nil) {
                callback(YES, orgHtml);
            } else {
                callback(YES, html);
            }
        }

    }  failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        callback(NO, @"网络异常");
    }];

}

- (void)POSTWithURL:(NSURL *)url parameters:(id)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>))block charset:(Charset)charset requestCallback:(RequestCallback)callback {


    [self POST:[url absoluteString] parameters:parameters constructingBodyWithBlock:block progress:^(NSProgress *_Nonnull uploadProgress) {

    }  success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {

        if (charset == GBK) {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *encodeStr = [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:enc];
            callback(YES, encodeStr);
        } else {
            NSString *orgHtml = [responseObject utf8String];
            NSString *html = [orgHtml replaceUnicode];

            if (html == nil) {
                callback(YES, orgHtml);
            } else {
                callback(YES, html);
            }
        }

    }  failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        NSLog(@"AFHTTPSessionManager+SimpleAction POSTWithURL  %@", error);
        callback(NO, @"网络异常");
    }];
}

- (void)GETWithURLString:(NSString *)url parameters:(NSDictionary *)parameters charset:(Charset)charset requestCallback:(RequestCallback)callback {
    NSURL *nsurl = [NSURL URLWithString:url];
    [self GETWithURL:nsurl parameters:parameters charset:charset requestCallback:callback];
}

- (void)POSTWithURLString:(NSString *)url parameters:(id)parameters charset:(Charset)charset requestCallback:(RequestCallback)callback {
    NSURL *nsurl = [NSURL URLWithString:url];
    [self POSTWithURL:nsurl parameters:parameters charset:charset requestCallback:callback];
}

- (void)POSTWithURLString:(NSString *)url parameters:(id)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block charset:(Charset)charset requestCallback:(RequestCallback)callback {
    NSURL *nsurl = [NSURL URLWithString:url];
    [self POSTWithURL:nsurl parameters:parameters constructingBodyWithBlock:block charset:charset requestCallback:callback];
}

@end
