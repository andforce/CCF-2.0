//
// Created by WDY on 2017/12/12.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "PayManager.h"

@interface PayManager () /*<SKPaymentTransactionObserver, SKProductsRequestDelegate>*/ {

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
        //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;

}

- (void)payForProductID:(NSString *)productID with:(PayHandler)handler {
    _handler = handler;
    _currentProductID = productID;

    isRestore = FALSE;

//    if ([SKPaymentQueue canMakePayments]) {
//        NSArray *product = @[productID];
//
//        NSSet *nsset = [NSSet setWithArray:product];
//        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
//        request.delegate = self;
//        [request start];
//    } else {
//        NSLog(@"应用没有开启内购权限");
//        [self handleResult:FALSE];
//    }
}

- (void)restorePayForProductID:(NSString *)productID with:(PayHandler)handler {
    _handler = handler;
    _currentProductID = productID;
    isRestore = YES;

//    if ([SKPaymentQueue canMakePayments]) {
//        NSArray *product = @[productID];
//
//        NSSet *nsset = [NSSet setWithArray:product];
//        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
//        request.delegate = self;
//        [request start];
//    } else {
//        NSLog(@"应用没有开启内购权限");
//        [self handleResult:FALSE];
//    }
}


- (BOOL)hasPayed:(NSString *)productID {

    return YES;

//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    BOOL isPayed = [defaults boolForKey:productID];
//    return isPayed;
}

- (void)setPayed:(BOOL)payed for:(NSString *)productID {
    [[NSUserDefaults standardUserDefaults] setBool:payed forKey:productID];
}


// remove all payment queue
- (void)removeTransactionObserver {
    //[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
//    for (SKPaymentTransaction *tran in transactions) {
//        switch (tran.transactionState) {
//            case SKPaymentTransactionStatePurchased: {
//                NSLog(@"交易完成");
//                // 发送到苹果服务器验证凭证
//                [self verifyPay:_currentProductID with:^(NSDictionary *response) {
//                    [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//
//                    if (response == nil){
//                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:_currentProductID];
//                        [self handleResult:FALSE];
//                        return;
//                    }
//                    int code = [response[@"status"] intValue];
//
//
//                    // 保存购买购买状态
//                    [self setPayed:code == 0 for:_currentProductID];
//                    [self handleResult:code == 0];
//
//                    switch (code){
//                        case 0:{
////                            NSDictionary *dicReceipt = response[@"receipt"];
////                            NSDictionary *dicInApp = [dicReceipt[@"in_app"] firstObject];
////                            NSString *productIdentifier = dicInApp[@"product_id"];//读取产品标识
////                            //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
////                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
////                            if ([productIdentifier isEqualToString:_currentProductID]) {
////                                NSUInteger purchasedCount = (NSUInteger) [defaults integerForKey:productIdentifier];//已购买数量
////                                [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount + 1) forKey:productIdentifier];
////                            } else {
////                                [defaults setBool:YES forKey:productIdentifier];
////                            }
////                            //在此处对购买记录进行存储，可以存储到开发商的服务器端
//
//                            NSLog(@"购买成功！\t%@", response);
//                            break;
//                        }
//                        case 21002:{
//                            // 没有购买
//                            NSLog(@"从未购买过商品");
//                            break;
//                        }
//
//                        default:{
//                            NSLog(@"购买失败，未通过验证！");
//                        }
//                    }
//
//                }];
//
//
//            }
//                break;
//            case SKPaymentTransactionStatePurchasing:
//                NSLog(@"商品添加进列表");
//                break;
//            case SKPaymentTransactionStateRestored: {
//                NSLog(@"已经购买过商品");
//                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:_currentProductID];
//                [self handleResult:YES];
//            }
//                break;
//            case SKPaymentTransactionStateFailed: {
//                NSLog(@"交易失败");
//                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                [self handleResult:FALSE];
//            }
//                break;
//            default:
//                break;
//        }
//    }
//}

// request Failed
//- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
//    NSLog(@"didFailWithError ：%@", error.localizedDescription);
//}

// request Response
//- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
//    NSArray *product = response.products;
//    if ([product count] == 0) {
//        return;
//    }
//
//    NSLog(@"productID:%@", response.invalidProductIdentifiers);
//    NSLog(@"产品付费数量:%lu", (unsigned long) [product count]);
//
//    SKProduct *p = nil;
//    for (SKProduct *pro in product) {
//        NSLog(@"%@", [pro description]);
//        //NSLog(@"%@", [pro localizedTitle]);
//        //NSLog(@"%@", [pro localizedDescription]);
//        NSLog(@"%@", [pro price]);
//        NSLog(@"%@", [pro productIdentifier]);
//
//        if ([pro.productIdentifier isEqualToString:_currentProductID]) {
//            p = pro;
//        }
//    }
//
//    SKPayment *payment = [SKPayment paymentWithProduct:p];
//
//    if (isRestore){
//        NSLog(@"发送恢复购买请求");
//        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
//
//    } else {
//        NSLog(@"发送购买请求");
//        [[SKPaymentQueue defaultQueue] addPayment:payment];
//    }
//
//}


//- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
//    NSLog(@"restore payment finished");
//
//    [self handleResult:YES];
//}
//
//- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
//    NSLog(@"restore payment finished %@", error.localizedDescription);
//
//    [self handleResult:NO];
//}

- (void)handleResult:(BOOL)isSuccess {
    if (_handler) {
        _handler(isSuccess);
    }
}

//- (BOOL) isSandbox:(SKPaymentTransaction *)transaction{
//    NSString * str = [[NSString alloc]initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
//    NSString *environment=[self environmentForReceipt:str];
//    return [environment containsString:@"environment=Sandbox"];
//}

//收据的环境判断；
- (NSString *)environmentForReceipt:(NSString *)str {
    str = [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];

    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];

    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];

    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    NSArray *arr = [str componentsSeparatedByString:@";"];

    //存储收据环境的变量
    NSString *environment = arr[2];
    return environment;
}

//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

// 验证购买，避免越狱软件模拟苹果请求达到非法购买问题, 先验证Appstore版本，如果失败了再验证沙盒
- (void)verifyPay:(NSString *)productID with:(VerifyHandler)handler {
    _currentProductID = productID;

    NSLog(@"verify->:\tproductID:%@", _currentProductID);

    [self verifyWithUrl:[NSURL URLWithString:AppStore] handler:^(NSDictionary *response) {
        if (response) {
            NSLog(@"verify->:\tAppStore 环境:%@", response);

            // 21007 说明是沙河下的收据却拿到正式环境进行了验证，因此需要重新在沙河下进行验证
            if ([response[@"status"] intValue] == 21007) {
                [self verifyWithUrl:[NSURL URLWithString:SANDBOX] handler:^(NSDictionary *response) {
                    NSLog(@"verify->:\tSandbox 环境:%@", response);
                    handler(response);
                }];
                return;
            }
        } else {
            NSLog(@"verifyPay: response is nil.");
        }

        handler(response);
    }];

}

- (void)verifyWithUrl:(NSURL *)url handler:(VerifyHandler)handler {
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    // 保证数据
    if (!receiptData) {
        NSLog(@"verify->:\tverifyWithUrl() : 没有任何收据，无需再次验证了");
        handler(nil);
        return;
    }

    //转化为base64字符串
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\", \"password\":\"%@\"}",
                                                      receiptString, @"b3189c215c0b423d985bc8d2548bb91a"];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    //创建请求到苹果官方进行购买验证

    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody = bodyData;
    requestM.HTTPMethod = @"POST";

    //创建连接并发送同步请求
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        NSLog(@"verify->:\tverifyWithUrl() : 验证发生错误: %@", error.localizedDescription);
        handler(nil);
        return;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"verify->:\tverifyWithUrl() : 验证返回数据: %@", dic);
    handler(dic);
}

@end
