//
// Created by WDY on 2017/12/12.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "PayManager.h"

@interface PayManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate, SKRequestDelegate> {

    NSString *_currentProductID;

    PayHandler _handler;

    BOOL isRestore;
}

@end

@implementation PayManager {

}

static PayManager *_instance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });

    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;

}

- (void)payForProductID:(NSString *)productID with:(PayHandler)handler {
    _handler = handler;
    _currentProductID = productID;

    isRestore = FALSE;

    if ([SKPaymentQueue canMakePayments]) {
        NSArray *product = @[productID];

        NSSet *nsset = [NSSet setWithArray:product];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
        request.delegate = self;
        [request start];
    } else {
        NSLog(@"PayManager --> 应用没有开启内购权限");
        [self handleResult:FALSE];
    }
}

- (void)restorePayForProductID:(NSString *)productID with:(PayHandler)handler {
    _handler = handler;
    _currentProductID = productID;
    isRestore = YES;

    [self refreshReceipt];
//    if ([SKPaymentQueue canMakePayments]) {
//        NSArray *product = @[productID];
//
//        NSSet *nsset = [NSSet setWithArray:product];
//        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
//        request.delegate = self;
//        [request start];
//    } else {
//        NSLog(@"PayManager --> 应用没有开启内购权限");
//        [self handleResult:FALSE];
//    }
}


- (BOOL)hasPayed:(NSString *)productID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPayed = [defaults boolForKey:productID];
    return isPayed;
}

- (void)setPayed:(BOOL)payed for:(NSString *)productID {
    [[NSUserDefaults standardUserDefaults] setBool:payed forKey:productID];
}


// remove all payment queue
- (void)removeTransactionObserver {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                NSLog(@"PayManager --> 交易完成");
                // 发送到苹果服务器验证凭证

                [self checkPay:_currentProductID with:^(int code) {
                    [[SKPaymentQueue defaultQueue] finishTransaction:tran];

                    // 保存购买购买状态
                    [self setPayed:code == 0 for:_currentProductID];
                    [self handleResult:code == 0];

                    switch (code) {
                        case 0: {
                            NSLog(@"PayManager --> 购买成功!");
                            if (_handler){
                                _handler(YES);
                            }
                            break;
                        }
                        case 21002: {
                            if (_handler){
                                _handler(NO);
                            }
                            // 没有购买
                            NSLog(@"PayManager --> 从未购买过商品");
                            break;
                        }

                        default: {
                            if (_handler){
                                _handler(NO);
                            }
                            NSLog(@"PayManager --> 购买失败，未通过验证！");
                        }
                    }
                }];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"PayManager --> 商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored: {
                NSLog(@"PayManager --> 已经购买过商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:_currentProductID];
                [self handleResult:YES];
            }
                break;
            case SKPaymentTransactionStateFailed: {
                NSLog(@"PayManager --> 交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [self handleResult:FALSE];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    NSArray *product = response.products;
    if ([product count] == 0) {
        return;
    }

    NSLog(@"PayManager --> productID:%@", response.invalidProductIdentifiers);
    NSLog(@"PayManager --> 产品付费数量:%lu", (unsigned long) [product count]);

    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"PayManager --> %@", [pro description]);
        //NSLog(@"PayManager --> %@", [pro localizedTitle]);
        //NSLog(@"PayManager --> %@", [pro localizedDescription]);
        NSLog(@"PayManager --> %@", [pro price]);
        NSLog(@"PayManager --> %@", [pro productIdentifier]);

        if ([pro.productIdentifier isEqualToString:_currentProductID]) {
            p = pro;
        }
    }

    SKPayment *payment = [SKPayment paymentWithProduct:p];

    if (isRestore) {
        NSLog(@"PayManager --> 发送恢复购买请求");
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

    } else {
        NSLog(@"PayManager --> 发送购买请求");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"PayManager --> restore payment finished");

    NSMutableArray * purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"PayManager --> received restored transactions: %ld", queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        NSLog(@"PayManager --> paymentQueueRestoreCompletedTransactionsFinished %@", purchasedItemIDs);
    }
    //[self handleResult:YES];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"PayManager --> restore payment finished %@", error.localizedDescription);

    [self handleResult:NO];
}

- (void)handleResult:(BOOL)isSuccess {
    if (_handler) {
        _handler(isSuccess);
    }
}

//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

// 验证购买，避免越狱软件模拟苹果请求达到非法购买问题, 先验证Appstore版本，如果失败了再验证沙盒
- (void)verifyPay:(NSString *)productID with:(TimeHaveHandler)handler {
    _currentProductID = productID;

    NSLog(@"PayManager --> verifyPay:\tproductID:%@", _currentProductID);

    [self getInternetDateWithSuccess:AppStore handle:^(NSDate *netDate) {
        [self verifyWithUrl:[NSURL URLWithString:AppStore] handler:^(NSDictionary *response) {
            [self verifyReceipt:netDate response:response timeHave:handler];
        }];
    } failure:^(NSError *error) {
        NSLog(@"PayManager --> verifyPay: 获取网络时间失败，没法验证是否购买了");
        handler(0);
    }];
}

- (void)verifyReceipt:(NSDate *)netDate response:(NSDictionary *)response timeHave:(TimeHaveHandler)handler {
    if (response) {
        NSLog(@"PayManager --> verifyPay:开始验证正式环境:%@", response);

        // 21007 说明是沙河下的收据却拿到正式环境进行了验证，因此需要重新在沙河下进行验证
        if ([response[@"status"] intValue] == 21007) {

            NSLog(@"PayManager --> 21007 说明是沙河下的收据却拿到正式环境进行了验证，因此需要重新在沙河下进行验证");

            [self verifyWithUrl:[NSURL URLWithString:SANDBOX] handler:^(NSDictionary *responseSandbox) {
                NSLog(@"PayManager --> verifyPay: 验证SandBox环境返回的数据 %@", responseSandbox);

                long time = [self checkReceiptTimeHave:netDate receipt:responseSandbox];
                handler(time);

            }];
        } else {
            NSLog(@"PayManager --> verifyPay: 不是21007，所以开始解析正式环境的数据");

            long time = [self checkReceiptTimeHave:netDate receipt:response];
            handler(time);
        }
    } else {
        NSLog(@"PayManager --> verifyPay: 验证正式环境失败，直接返回");
        handler(0);
    }
}

- (long)checkReceiptTimeHave:(NSDate *)currentTime receipt:(NSDictionary *)responseSandbox {
    if (responseSandbox && currentTime) {
        NSDictionary *receipt = responseSandbox[@"receipt"];
        NSArray *in_app = receipt[@"in_app"];

        if (receipt && in_app) {
            long first = 0;
            for (int i = 0; i < in_app.count; ++i) {
                NSDictionary *one = in_app[(NSUInteger) i];
                NSString *purchase_date_ms = one[@"purchase_date_ms"];
                long purchase_date = [purchase_date_ms longLongValue];
                if (first == 0) {
                    first = purchase_date;
                } else if (purchase_date < first) {
                    first = purchase_date;
                }
            }
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:first / 1000];
            NSCalendar *calendar = nil;
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
                calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            } else {
                calendar = [NSCalendar currentCalendar];
            }
            NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:date];
            [dateComponents setYear:+in_app.count];

            NSDate *newdate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
            if ([newdate compare:currentTime] == NSOrderedAscending) {
                NSLog(@"PayManager --> checkReceiptTimeHave: 验证SandBox in_app，购买过期了，验证失败");
                return 0;
            } else {
                NSTimeInterval interval = [newdate timeIntervalSinceDate:currentTime];
                NSLog(@"PayManager --> checkReceiptTimeHave: 验证SandBox in_app，购买过，还没有过期，剩余 %ld", (long) interval);
                return (long) interval;
            }
        }
    }

    return 0;
}

//- (void)checkReceipt:(TimeHaveHandler)handler netDate:(NSDate *)netDate responseSandbox:(NSDictionary *)responseSandbox {
//    if ([responseSandbox[@"status"] intValue] == 0){
//        NSDictionary * receipt = responseSandbox[@"receipt"];
//        if (receipt == nil){
//            NSLog(@"PayManager --> verifyPay: 验证SandBox返回数据是空的");
//            handler(0L);
//        } else {{
//            NSArray *in_app = receipt[@"in_app"];
//            if (in_app == nil || in_app.count == 0){
//                NSLog(@"PayManager --> verifyPay: 验证SandBox in_app 的数量是空的，没有查到购买的数据");
//                handler(0L);
//            } else {
//                long first = 0;
//                for (int i = 0; i < in_app.count; ++i) {
//                    NSDictionary *one = in_app[(NSUInteger) i];
//                    NSString * purchase_date_ms = one[@"purchase_date_ms"];
//                    long dateMs = [purchase_date_ms longLongValue];
//                    if (first == 0){
//                        first = dateMs;
//                    } else if (dateMs < first){
//                        first = dateMs;
//                    }
//                }
//
//                NSDate *date = [NSDate dateWithTimeIntervalSince1970:first / 1000];
//                NSCalendar *calendar = nil;
//                if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
//                    calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
//                } else {
//                    calendar = [NSCalendar currentCalendar];
//                }
//                NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:date];
//                [dateComponents setYear:+ in_app.count];
//
//                NSDate *newdate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
//                if ([newdate compare:netDate] == NSOrderedAscending){
//                    NSLog(@"PayManager --> verifyPay: 验证SandBox in_app，购买过期了，验证失败");
//                    handler(0);
//                } else {
//                    NSTimeInterval interval = [newdate timeIntervalSinceDate:netDate];
//                    NSLog(@"PayManager --> verifyPay: 验证SandBox in_app，购买过，还没有过期，剩余 %ld", (long)interval);
//                    handler((long)interval);
//                }
//            }
//
//        }}
//    } else {
//        NSLog(@"PayManager --> verifyPay: 验证SandBox返回status 不是0");
//        handler(0L);
//    }
//}

- (void)checkPay:(NSString *)productID with:(StatusHandler)handler {
    _currentProductID = productID;

    NSLog(@"PayManager --> verify->:\tproductID:%@", _currentProductID);

    [self getInternetDateWithSuccess:AppStore handle:^(NSDate *netDate) {
        [self verifyWithUrl:[NSURL URLWithString:AppStore] handler:^(NSDictionary *response) {
            if (response) {
                NSLog(@"PayManager --> verify->:\tAppStore 环境:%@", response);

                // 21007 说明是沙河下的收据却拿到正式环境进行了验证，因此需要重新在沙河下进行验证
                if ([response[@"status"] intValue] == 21007) {
                    [self verifyWithUrl:[NSURL URLWithString:SANDBOX] handler:^(NSDictionary *responseSandbox) {
                        NSLog(@"PayManager --> verify->:\tSandbox 环境:%@", responseSandbox);
                        handler([responseSandbox[@"status"] intValue]);
                    }];
                } else {
                    handler([response[@"status"] intValue]);
                }
            } else {
                NSLog(@"PayManager --> verifyPay: response is nil.");
                handler(-1);
            }
        }];
    } failure:^(NSError *error) {
        handler(-1);
    }];
}

- (void)verifyWithUrl:(NSURL *)url handler:(VerifyHandler)handler {
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    // 保证数据
    if (!receiptData) {
        NSLog(@"PayManager --> verify->:\tverifyWithUrl() %@: 没有任何收据，无需再次验证了", url);
        handler(nil);
        return;
    }

    //转化为base64字符串
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    //http://cwqqq.com/2017/12/05/ios_in-app_pay_server_side_code
    //NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\", \"password\":\"%@\"}",
    //                                                  receiptString, @"b3189c215c0b423d985bc8d2548bb91a"];

    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [self postWithReceipt:url bodyData:bodyData handler:handler];

}

- (void)postWithReceipt:(NSURL *)url bodyData:(NSData *)bodyData handler:(VerifyHandler)handler {
    //创建请求到苹果官方进行购买验证
    //1.创建NSURLSession对象（可以获取单例对象）
    NSURLSession *session = [NSURLSession sharedSession];

    //2.根据NSURLSession对象创建一个Task

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = bodyData;
    request.HTTPMethod = @"POST";

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *__nullable data,
            NSURLResponse *__nullable response, NSError *__nullable error) {

        if (error) {
            NSLog(@"PayManager --> verify->:\tverifyWithUrl() %@: 验证发生错误: %@", url ,error.localizedDescription);
            handler(nil);
            return;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"PayManager --> verify->:\tverifyWithUrl() %@: 验证返回数据: %@", url, dic);
        handler(dic);
    }];

    //3.执行Task
    //注意：刚创建出来的task默认是挂起状态的，需要调用该方法来启动任务（执行任务）
    [dataTask resume];
}

- (void)getInternetDateWithSuccess:(NSString *) urlString handle:(void (^)(NSDate *netDate))success failure:(void (^)(NSError *error))failure {

    //1.创建URL
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    //2.创建request请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:5];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];

    //3.创建URLSession对象
    NSURLSession *session = [NSURLSession sharedSession];
    //4.设置数据返回回调的block

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error == nil && response != nil) {

            //这么做的原因是简体中文下的手机不能识别“MMM”，只能识别“MM”
            NSArray *monthEnglishArray = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sept", @"Sep", @"Oct", @"Nov", @"Dec"];
            NSArray *monthNumArray = @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"09", @"10", @"11", @"12"];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSDictionary *allHeaderFields = [httpResponse allHeaderFields];
            NSString *dateStr = allHeaderFields[@"Date"];
            NSLog(@"PayManager --> 网络时间 %@", dateStr);

            dateStr = [dateStr substringFromIndex:5];
            dateStr = [dateStr substringToIndex:[dateStr length] - 4];
            dateStr = [dateStr stringByAppendingString:@" +0000"];
            //当前语言是中文的话，识别不了英文缩写
            for (NSInteger i = 0; i < monthEnglishArray.count; i++) {
                NSString *monthEngStr = monthEnglishArray[(NSUInteger) i];
                NSString *monthNumStr = monthNumArray[(NSUInteger) i];
                dateStr = [dateStr stringByReplacingOccurrencesOfString:monthEngStr withString:monthNumStr];
            }

            NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
            [dMatter setDateFormat:@"dd MM yyyy HH:mm:ss Z"];
            NSDate *netDate = [dMatter dateFromString:dateStr];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(netDate);
            });

        } else {

            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });

        }

    }];

    //5、执行网络请求

    [task resume];
}


// https://zhuanlan.zhihu.com/p/79337802
// 通过刷新收据恢复购买
- (void)refreshReceipt {
    SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
    request.delegate = self;
    [request start];
    NSLog(@"PayManager --> On refresh receipt started");
}

#pragma mark - SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"PayManager --> On refresh receipt finished");
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]) {
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
        NSString *receiptString = receiptData.base64Encoding;

        NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];
        NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

        NSURL *appStore = [NSURL URLWithString:AppStore];
        NSURL *sandBox = [NSURL URLWithString:SANDBOX];


        [self getInternetDateWithSuccess:AppStore handle:^(NSDate *netDate) {

            [self postWithReceipt:appStore bodyData:data handler:^(NSDictionary *response) {
                if (response){
                    if ([response[@"status"] intValue] == 21007) {
                        [self postWithReceipt:sandBox bodyData:data handler:^(NSDictionary *sandboxResponse) {
                            NSLog(@"PayManager --> requestDidFinish: Sandbox环境恢复: %@", sandboxResponse);
                            [self verifyReceipt:netDate response:sandboxResponse timeHave:^(long timeHave) {

                                [self setPayed:timeHave > 0 for:_currentProductID];
                                _handler(timeHave > 0);
                            }];
                        }];

                    } else {
                        [self verifyReceipt:netDate response:response timeHave:^(long timeHave) {
                            [self setPayed:timeHave > 0 for:_currentProductID];
                            _handler(timeHave > 0);
                        }];
                        NSLog(@"PayManager --> requestDidFinish: 正式环境恢复: %@", response);
                    }
                } else {
                    NSLog(@"PayManager --> requestDidFinish: 没有返回数据，恢复验证失败");
                    [self setPayed:NO for:_currentProductID];
                    _handler(NO);
                }
            }];
        } failure:^(NSError *error) {
            NSLog(@"PayManager --> requestDidFinish: 获取网络时间失败，没法验证是否购买了");
            [self setPayed:NO for:_currentProductID];
            _handler(NO);
        }];
    }
}

// request Failed
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (_handler){
        _handler(NO);
    }
    NSLog(@"PayManager --> didFailWithError ：%@", error.localizedDescription);
}


@end
