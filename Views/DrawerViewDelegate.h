//
//  DrawerViewDelegate.h
//  iOSMaps
//
//  Created by WDY on 15/12/10.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DrawerViewDelegate <NSObject>

@optional
- (void)leftDrawerDidOpened;

- (void)leftDrawerDidClosed;

- (void)rightDrawerDidOpened;

- (void)rightDrawerDidClosed;

- (void)didDrawerMoveToSuperview:(NSInteger)index;


@end
