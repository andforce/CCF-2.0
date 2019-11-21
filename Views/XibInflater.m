//
//  XibInflater.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "XibInflater.h"

@implementation XibInflater

+ (id)inflateViewByXibName:(NSString *)xibName {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];

    return [nib objectAtIndex:0];
}
@end
