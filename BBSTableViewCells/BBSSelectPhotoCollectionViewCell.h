//
//  SelectPhotoCollectionViewCell.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeleteDelegate <NSObject>

@required
- (void)deleteCurrentImageForIndexPath:(NSIndexPath *)indexPath;

@end


@interface BBSSelectPhotoCollectionViewCell : UICollectionViewCell

@property(nonatomic, weak) id <DeleteDelegate> deleteImageDelete;

@property(weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)setData:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath;

- (IBAction)deleteCurrentImage:(UIButton *)sender;

@end
