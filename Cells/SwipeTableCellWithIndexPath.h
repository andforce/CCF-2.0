//
//  MGSwipeTableCellWithIndexPath.h
//  DRL
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface SwipeTableCellWithIndexPath : MGSwipeTableCell

@property(nonatomic, weak) NSIndexPath *indexPath;

@end
