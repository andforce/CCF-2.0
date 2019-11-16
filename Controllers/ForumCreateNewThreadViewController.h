//
//  ForumCreateNewThreadViewController.h
//
//  Created by 迪远 王 on 16/1/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SelectPhotoCollectionViewCell.h"
#import "ForumApiBaseViewController.h"

@interface ForumCreateNewThreadViewController : ForumApiBaseViewController


@property(weak, nonatomic) IBOutlet UITextField *subject;

@property(weak, nonatomic) IBOutlet UITextView *message;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic) IBOutlet UIButton *category;

- (IBAction)createThread:(id)sender;

- (IBAction)back:(id)sender;

- (IBAction)pickPhoto:(id)sender;


@property(weak, nonatomic) IBOutlet UICollectionView *selectPhotos;

- (IBAction)showCategory:(UIButton *)sender;

@end
