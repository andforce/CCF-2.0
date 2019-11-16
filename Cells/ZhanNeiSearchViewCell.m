//
//  ZhanNeiSearchViewCell.m
//  
//
//  Created by 迪远 王 on 2017/11/19.
//

#import "ZhanNeiSearchViewCell.h"

@implementation ZhanNeiSearchViewCell {
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
