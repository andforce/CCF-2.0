//
//
//  DRL
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import<CommonCrypto/CommonDigest.h>

@interface NSString (Extensions)
- (NSString *)replaceUnicode;

- (NSString *)md5HexDigest;

- (NSString *)stringWithRegular:(NSString *)regular;

- (NSString *)stringWithRegular:(NSString *)regular andChild:(NSString *)childRegular;

- (NSString *)removeStringWithRegular:(NSString *)regular;

- (NSString *)trim;

- (NSArray *)arrayWithRegular:(NSString *)regular;

- (NSString *)encodeWithGBKEncoding;

- (NSString *)decodeWithGBKEncoding;

- (NSData *)dataForGBK;

- (NSData *)dataForUTF8;
@end
