//
//  HybridNSURLProtocol.m
//  WKWebVIewHybridDemo
//
//  Created by shuoyu liu on 2017/1/16.
//  Copyright © 2017年 shuoyu liu. All rights reserved.
//

#import "HybridNSURLProtocol.h"
#import <UIKit/UIKit.h>

#import "SDImageCache.h"
#import "NSData+ImageContentType.h"
#import "UIImage+MultiFormat.h"
#import <UIImageView+WebCache.h>

static NSString *const sourUrl = @"https://m.baidu.com/static/index/plus/plus_logo.png";
static NSString *const sourIconUrl = @"http://m.baidu.com/static/search/baiduapp_icon.png";
static NSString *const localUrl = @"http://mecrm.qa.medlinker.net/public/image?id=57026794&certType=workCertPicUrl&time=1484625241";

static NSString *const KHybridNSURLProtocolHKey = @"KHybridNSURLProtocol";

@interface HybridNSURLProtocol () <NSURLSessionDelegate, NSURLConnectionDataDelegate>

//@property(nonnull, strong) NSURLSessionDataTask *task;

@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) NSMutableData *responseData;

@end


@implementation HybridNSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSLog(@"request.URL.absoluteString = %@", request.URL.absoluteString);
    NSString *scheme = [[request URL] scheme];
    if (([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
            [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame)) {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:KHybridNSURLProtocolHKey inRequest:request])
            return NO;
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];

    //request截取重定向
    if ([request.URL.absoluteString isEqualToString:sourUrl]) {
        NSURL *url1 = [NSURL URLWithString:localUrl];
        mutableReqeust = [NSMutableURLRequest requestWithURL:url1];
    }

    return mutableReqeust;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {

    NSMutableURLRequest *mutableURLRequest = [[self request] mutableCopy];
    //做下标记，防止递归调用
    [NSURLProtocol setProperty:@YES forKey:KHybridNSURLProtocolHKey inRequest:mutableURLRequest];

    //查看本地是否已经缓存了图片
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];

    UIImage *memCachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];

    NSData *data = nil;

    if (memCachedImage){
        if (!memCachedImage.images) {
            data = UIImageJPEGRepresentation(memCachedImage, 1.f);
        }
    } else {
        UIImage *diskCache = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        if (diskCache){
            data = UIImageJPEGRepresentation(memCachedImage, 1.f);
        }
    }

    if (data == nil && [[self.request.URL absoluteString] rangeOfString:@"no_avatar.gif"].location != NSNotFound){
        UIImage * defaultAvatarImage = [UIImage imageNamed:@"defaultAvatar.gif"];
        data = UIImageJPEGRepresentation(defaultAvatarImage, 1.f);
    }

    if (data){
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableURLRequest.URL
                                                            MIMEType:[NSData sd_contentTypeForImageData:data]
                                               expectedContentLength:data.length
                                                    textEncodingName:nil];
        [self.client URLProtocol:self
              didReceiveResponse:response
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];

        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
        NSLog(@"---------- ---------- ---------- ---------- ---------- 有缓存直接利用 %@", self.request.URL);
    } else {
        NSLog(@"--- --- --- --- --- --- --- --- --- --- --- --- --- --- 没有缓存需要请求 %@", self.request.URL);
    }

    self.connection = [NSURLConnection connectionWithRequest:mutableURLRequest delegate:self];
}

- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark- NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *cacheImage = [UIImage sd_imageWithData:self.responseData];
    //利用SDWebImage提供的缓存进行保存图片
    [[SDImageCache sharedImageCache] storeImage:cacheImage
                           recalculateFromImage:NO
                                      imageData:self.responseData
                                         forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL]
                                         toDisk:YES];

    [self.client URLProtocolDidFinishLoading:self];
}
@end
