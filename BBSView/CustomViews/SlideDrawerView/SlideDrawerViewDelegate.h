//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SlideDrawerViewDelegate <NSObject>

@optional
- (void)leftDrawerDidOpened;

- (void)leftDrawerDidClosed;

- (void)rightDrawerDidOpened;

- (void)rightDrawerDidClosed;

- (void)didDrawerMoveToSuperview:(NSInteger)index;


@end
