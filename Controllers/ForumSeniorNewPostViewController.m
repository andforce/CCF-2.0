//
//  ForumSeniorNewPostViewController.m
//
//  Created by 迪远 王 on 16/1/16.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSeniorNewPostViewController.h"

#import "SelectPhotoCollectionViewCell.h"
#import "LCActionSheet.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Tint.h"
#import "LocalForumApi.h"
#import "PayManager.h"
#import "UIStoryboard+Forum.h"
#import "ProgressDialog.h"


@interface ForumSeniorNewPostViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,
        UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DeleteDelegate, TransBundleDelegate, UIScrollViewDelegate> {

    UIImagePickerController *pickControl;
    NSMutableArray<UIImage *> *images;
    NSString *userName;
    NSString *securityToken;

    int forumId;
    int threadId;
    NSString *postId;

    ViewThreadPage *replyThread;

    BOOL isQuoteReply;

    LocalForumApi *_localForumApi;

    PayManager *_payManager;
}

@end

@implementation ForumSeniorNewPostViewController


- (void)transBundle:(TransBundle *)bundle {
    userName = [bundle getStringValue:@"USER_NAME"];
    threadId = [bundle getIntValue:@"THREAD_ID"];
    securityToken = [bundle getStringValue:@"SECURITY_TOKEN"];
    forumId = [bundle getIntValue:@"FORM_ID"];
    int pid = [bundle getIntValue:@"POST_ID"];
    postId = [NSString stringWithFormat:@"%d", pid];

    replyThread = [bundle getObjectValue:@"QUICK_REPLY_THREAD"];

    isQuoteReply = [bundle getIntValue:@"IS_QUOTE_REPLY"] == 1;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _localForumApi = [[LocalForumApi alloc] init];

    // payManager
    _payManager = [PayManager shareInstance];

    _insertCollectionView.delegate = self;
    _insertCollectionView.dataSource = self;
    _scrollView.delegate = self;

    //实例化照片选择控制器
    pickControl = [[UIImagePickerController alloc] init];

    //设置协议
    pickControl.delegate = self;
    //设置编辑
    [pickControl setAllowsEditing:NO];
    //选完图片之后回到的视图界面

    images = [NSMutableArray array];

    [self.replyContent becomeFirstResponder];

    if (userName != nil) {
        self.replyContent.text = [NSString stringWithFormat:@"@%@\n", userName];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (![_payManager hasPayed:[_localForumApi currentProductID]]) {
        [self showFailedMessage:@"回帖需要解锁高级功能"];
    }
}

- (void)showFailedMessage:(id)message {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"操作受限" message:message preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *showPayPage = [UIAlertAction actionWithTitle:@"解锁" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        UIViewController *controller = [[UIStoryboard mainStoryboard] finControllerById:@"ShowPayPage"];

        [self presentViewController:controller animated:YES completion:^{

        }];

    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self dismissViewControllerAnimated:YES completion:^{

        }];

    }];

    [alert addAction:cancel];

    [alert addAction:showPayPage];


    [self presentViewController:alert animated:YES completion:^{

    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (long long)fileSizeAtPathWithString:(NSString *)filePath {


    NSFileManager *manager = [NSFileManager defaultManager];


    if ([manager fileExistsAtPath:filePath]) {

        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)fileSizeAtPath:(NSURL *)filePath {
    //return [self fileSizeAtPathWithString:filePath.path];
    ALAssetsLibrary *alLibrary = [[ALAssetsLibrary alloc] init];
    __block long long fileSize = (long long int) 0.0;

    [alLibrary assetForURL:filePath resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];

        fileSize = [representation size];


        NSLog(@"图片大小:   %lld", fileSize);

    }         failureBlock:nil];

}


- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *select = [info valueForKey:UIImagePickerControllerOriginalImage];

    NSURL *selectUrl = [info valueForKey:UIImagePickerControllerReferenceURL];

    [self fileSizeAtPath:selectUrl];

    CGSize maxImageSize = CGSizeMake(800, 800);

    [images addObject:[select scaleUIImage:maxImageSize]];

    [_insertCollectionView reloadData];

    //选取完图片之后关闭视图
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return images.count;
}


- (void)deleteCurrentImageForIndexPath:(NSIndexPath *)indexPath {
    [images removeObjectAtIndex:(NSUInteger) indexPath.row];
    [self.insertCollectionView reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *Identifier = @"SelectPhotoCollectionViewCell";

    SelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    cell.deleteImageDelete = self;

    [cell setData:images[(NSUInteger) indexPath.row] forIndexPath:indexPath];

    return cell;

}

- (IBAction)insertSmile:(id)sender {

}

- (IBAction)insertPhoto:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    LCActionSheet *itemActionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *_Nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [pickControl setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

            [self presentViewController:pickControl animated:YES completion:nil];
        } else if (buttonIndex == 2) {
            [pickControl setSourceType:UIImagePickerControllerSourceTypeCamera];

            [self presentViewController:pickControl animated:YES completion:nil];
        }
    }                                        otherButtonTitleArray:@[@"相册", @"拍照"]];

    [itemActionSheet show];

}

- (IBAction)back:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    [self dismissViewControllerAnimated:YES completion:nil];

    [_payManager removeTransactionObserver];
}

- (IBAction)sendSeniorMessage:(UIBarButtonItem *)sender {
    [self.replyContent resignFirstResponder];

    [ProgressDialog showStatus:@"正在回复"];

    NSMutableArray < NSData * > *uploadImages = [NSMutableArray array];
    for (UIImage *image in images) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [uploadImages addObject:data];
    }

    [self.forumApi replyWithMessage:self.replyContent.text withImages:uploadImages toPostId:postId thread:replyThread isQoute:isQuoteReply handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {
            [ProgressDialog showSuccess:@"回复成功"];

            ViewThreadPage *thread = message;

            TransBundle *bundle = [[TransBundle alloc] init];
            [bundle putObjectValue:thread forKey:@"Senior_Reply_Callback"];

            UITabBarController *presenting = (UITabBarController *) self.presentingViewController;
            UINavigationController *selected = presenting.selectedViewController;
            UIViewController *detail = selected.topViewController;

            [self dismissViewControllerAnimated:YES backToViewController:detail withBundle:bundle completion:^{

            }];

        } else {
            [ProgressDialog showError:message];
        }
    }];
}

@end
