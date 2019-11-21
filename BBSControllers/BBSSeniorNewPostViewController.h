//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSApiBaseViewController.h"


@interface BBSSeniorNewPostViewController : BBSApiBaseViewController


@property(weak, nonatomic) IBOutlet UITextView *replyContent;

- (IBAction)insertSmile:(id)sender;

- (IBAction)insertPhoto:(id)sender;

- (IBAction)back:(id)sender;

- (IBAction)sendSeniorMessage:(UIBarButtonItem *)sender;

@property(weak, nonatomic) IBOutlet UICollectionView *insertCollectionView;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
