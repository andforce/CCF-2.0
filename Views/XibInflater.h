//
//  XibInflater.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XibInflater : NSObject


+ (id)inflateViewByXibName:(NSString *)xibName;

@end
