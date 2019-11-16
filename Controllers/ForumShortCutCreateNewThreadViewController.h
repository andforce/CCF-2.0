//
// Created by 迪远 王 on 2016/12/4.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectPhotoCollectionViewCell.h"
#import "ForumApiBaseViewController.h"

@interface ForumShortCutCreateNewThreadViewController : ForumApiBaseViewController

@property(weak, nonatomic) IBOutlet UITextField *subject;

@property(weak, nonatomic) IBOutlet UITextView *message;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic) IBOutlet UITextField *createWhichForum;

- (IBAction)createThread:(id)sender;

- (IBAction)back:(id)sender;

- (IBAction)pickPhoto:(id)sender;

- (IBAction)showAllForums:(id)sender;

@property(weak, nonatomic) IBOutlet UICollectionView *selectPhotos;

- (IBAction)showCategory:(UIButton *)sender;

@end
