//
//  SelectPhotoCollectionViewCell.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSSelectPhotoCollectionViewCell.h"

@implementation BBSSelectPhotoCollectionViewCell {
    NSIndexPath *path;
}

- (void)setData:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    path = indexPath;
    self.imageView.image = image;
}

- (IBAction)deleteCurrentImage:(UIButton *)sender {
    [self.deleteImageDelete deleteCurrentImageForIndexPath:path];
}
@end
