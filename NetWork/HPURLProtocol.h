//
//  HPURLProtocol.h
//  HiPDA
//
//
//  https://github.com/JaviSoto/JSTAPIToolsURLProtocol
//

#import <Foundation/Foundation.h>

@protocol HPURLMapping <NSObject>

/**
 Whenever `JSTAPIToolsURLProtocol` receives an http or https request, it will call this method to query for the APItools host to use instead.
 E.g. If a request is sent to https://api.twitter.com/1.1/statuses/user_timeline.json it will call this method with @"api.twitter.com".
 - To no forward the request to APItools, this method must return nil.
 - To formward the request to APItools, return your appropiate apitools hostname associated with the api.twitter.com host, like @"tw-ghzbf45ab8cz.my.apitools.com".
 @note The implementation of this methd must be thread-safe since it will be invoked from arbitrary background threads.
 This method is called once per request, so consider storing the mapping in an NSDictionary.
 */
- (NSString *)apiToolsHostForOriginalURLHost:(NSString *)originalURLHost;

@end

/**
 This class allows you to easily make your application redirects some of the HTTP(s) requests it makes to your https://www.apitools.com/ account.
 APItools is a web application that stores requests and lets you track, transform and analyze the traffic between your app and the APIs it uses.
 */

/*
 现在这个类做两件事
 1. 替换url里的域名为ip (这个其实可以在请求时直接替换, 然后设置http的header[host])
 2. 缓存所有的图片(gif由于性能的问题有些例外)
 */
@interface HPURLProtocol : NSURLProtocol

/**
 Your application should call this method whenever it wants to enable the request forwarding towards APItools.
 It's recommended to enable it as early as possible in the application lifecycle, for example in the `+load` method of another class.
 You may choose to only call this method on debug builds (#if DEBUG).
 @note You can only call this method once during your application lifecycle.
 */
+ (void)registerURLProtocolWithURLMapping:(id <HPURLMapping>)URLMapping;

+ (void)registerURLProtocolIfNeed;

@end
