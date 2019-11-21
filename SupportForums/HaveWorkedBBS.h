//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorkedBBS.h"


@interface HaveWorkedBBS : NSObject <NSCoding, NSCopying>

@property(nonatomic, strong) NSArray<WorkedBBS *> *forums;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end
