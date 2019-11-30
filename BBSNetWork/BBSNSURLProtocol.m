//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSNSURLProtocol.h"
#import <UIKit/UIKit.h>

#import "SDImageCache.h"
#import "NSData+ImageContentType.h"
#import "UIImage+MultiFormat.h"
#import <UIImageView+WebCache.h>

#import "AssertReader.h"

static NSString *const sourUrl = @"https://m.baidu.com/static/index/plus/plus_logo.png";
static NSString *const localUrl = @"http://mecrm.qa.medlinker.net/public/image?id=57026794&certType=workCertPicUrl&time=1484625241";

static NSString *const KHybridNSURLProtocolHKey = @"KHybridNSURLProtocol";

@interface BBSNSURLProtocol () <NSURLSessionDelegate, NSURLConnectionDataDelegate>

@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) NSMutableData *responseData;

@end


@implementation BBSNSURLProtocol

//如果返回YES则进入该自定义加载器进行处理，如果返回NO则不进入该自定义选择器，使用系统默认行为进行处理。
//YES 处理
//NO 不处理
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {

    NSString *protocol = request.URL.scheme;

    if (![@[@"http", @"https"] containsObject:protocol]) {
        return NO;
    }

    if ([NSURLProtocol propertyForKey:KHybridNSURLProtocolHKey inRequest:request]) {
        return NO;
    }

    if ([self.class shouldCache:request]) {
        return YES;
    }
    return NO;
}

+ (BOOL)shouldCache:(NSURLRequest *)request {
    // 1. 如果是SDWebImage的请求, request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData, SDWebImage自己会处理缓存
    // 2. 这里是通过url后缀来判断是不是图片的, 还可以从response.MIMEType
    NSString *absUrl = [[request.URL absoluteString] lowercaseString];
    if (request.cachePolicy != NSURLRequestReloadIgnoringLocalCacheData &&
            ([absUrl hasSuffix:@"&stc=1"] || [absUrl hasSuffix:@".jpg"] || [absUrl hasSuffix:@".png"] || [absUrl hasSuffix:@".jpeg"] || [absUrl hasSuffix:@".gif"])) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];

    //request截取重定向
    if ([request.URL.absoluteString isEqualToString:sourUrl]) {
        NSURL *url1 = [NSURL URLWithString:localUrl];
        mutableRequest = [NSMutableURLRequest requestWithURL:url1];
    }

    return mutableRequest;
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

    if (memCachedImage) {
        if (!memCachedImage.images) {
            data = UIImageJPEGRepresentation(memCachedImage, 1.f);
        }
    } else {
        UIImage *diskCache = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        if (diskCache) {
            data = UIImageJPEGRepresentation(memCachedImage, 1.f);
        }
    }

    if (data == nil && ([[self.request.URL absoluteString] rangeOfString:@"no_avatar.gif"].location != NSNotFound ||
            [[self.request.URL absoluteString] rangeOfString:@"no_avatar.jpg"].location != NSNotFound)) {
        UIImage *defaultAvatarImage = [AssertReader no_avatar];
        data = UIImageJPEGRepresentation(defaultAvatarImage, 1.f);
    }

    if (data) {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableURLRequest.URL
                                                            MIMEType:[NSData sd_contentTypeForImageData:data]
                                               expectedContentLength:data.length
                                                    textEncodingName:nil];
        [self.client URLProtocol:self
              didReceiveResponse:response
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];

        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
        NSLog(@"NSURLProtocol: ----->> in cache: %@", self.request.URL);
    } else {
        NSLog(@"NSURLProtocol: ----->> no cache: %@", self.request.URL);
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
