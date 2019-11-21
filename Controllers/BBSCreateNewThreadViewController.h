//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BBSSelectPhotoCollectionViewCell.h"
#import "ForumApiBaseViewController.h"

@interface BBSCreateNewThreadViewController : ForumApiBaseViewController


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
