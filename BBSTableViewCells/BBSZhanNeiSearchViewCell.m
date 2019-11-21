//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSZhanNeiSearchViewCell.h"

@implementation BBSZhanNeiSearchViewCell {
    NSIndexPath *selectIndexPath;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(Thread *)data {
    self.threadTitle.text = data.threadTitle;
}


- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    selectIndexPath = indexPath;
    [self setData:data];
}

@end
