//
//  ForumCreateNewThreadViewController.m
//
//  Created by 迪远 王 on 16/1/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumCreateNewThreadViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LCActionSheet.h"
#import "ActionSheetStringPicker.h"
#import "AFNetworking.h"
#import "UIImage+Tint.h"
#import "LocalForumApi.h"
#import "PayManager.h"
#import "UIStoryboard+Forum.h"
#import "ProgressDialog.h"

@interface ForumCreateNewThreadViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
        UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
        DeleteDelegate, TransBundleDelegate, UIScrollViewDelegate> {


    id<ForumBrowserDelegate> _forumApi;
    int forumId;
    UIImagePickerController *pickControl;
    NSMutableArray<UIImage *> *images;

    ViewForumPage *currentForumPage;

    int categoryIndex;

    PayManager *_payManager;
    LocalForumApi *_localForumApi;

    NSString *_post_hash;
    NSString *_forum_hash;
    NSString *_posttime;
    NSString *_seccodehash;
    NSString *_seccodeverify;
    NSDictionary *_typeidList;
}

@end

@implementation ForumCreateNewThreadViewController

- (void)transBundle:(TransBundle *)bundle {
    forumId = [bundle getIntValue:@"FORM_ID"];
    currentForumPage = [bundle getObjectValue:@"CREATE_THREAD_IN"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    categoryIndex = 0;

    // payManager
    _payManager = [PayManager shareInstance];

    _localForumApi = [[LocalForumApi alloc] init];
    _forumApi = [ForumApiHelper forumApi:_localForumApi.currentForumHost];

    _selectPhotos.delegate = self;
    _selectPhotos.dataSource = self;
    _scrollView.delegate = self;

    //实例化照片选择控制器
    pickControl = [[UIImagePickerController alloc] init];
    //设置照片源
    [pickControl setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //设置协议
    pickControl.delegate = self;
    //设置编辑
    [pickControl setAllowsEditing:NO];
    //选完图片之后回到的视图界面

    images = [NSMutableArray array];

    [ProgressDialog showStatus:@"获取分类"];

    [_forumApi enterCreateThreadPageFetchInfo:forumId :^(NSString *post_hash, NSString *forum_hash, NSString *posttime,
            NSString *seccodehash, NSString *seccodeverify, NSDictionary *typeidList) {

        _post_hash = post_hash;
        _forum_hash = forum_hash;
        _posttime = posttime;
        _seccodehash = seccodehash;
        _seccodeverify = seccodeverify;
        _typeidList = typeidList;

        if (_typeidList != nil){
            [ProgressDialog dismiss];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];

}

-(void)viewDidAppear:(BOOL)animated{
    if (![_payManager hasPayed:[_localForumApi currentProductID]]){
        [self showFailedMessage:@"未订阅用户无法发新帖"];
    }
}

-(void) showFailedMessage:(id) message{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"操作受限" message:message preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *showPayPage = [UIAlertAction actionWithTitle:@"订阅" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

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

    } failureBlock:nil];

}


+ (NSString *)mimeTypeForFileAtPath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef) CFBridgingRetain([path pathExtension]), NULL);


    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }

    return nil;
//    return [NSMakeCollectable((NSString *)CFBridgingRelease(mimeType)) ];
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
        default:
            return nil;
    }
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *select = [info valueForKey:UIImagePickerControllerOriginalImage];

    NSURL *selectUrl = [info valueForKey:UIImagePickerControllerReferenceURL];

    [self fileSizeAtPath:selectUrl];

    UIImage *scaleImage = [select scaleUIImage:CGSizeMake(800, 800)];

    [images addObject:scaleImage];

    [_selectPhotos reloadData];

    //选取完图片之后关闭视图
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *QuoteCellIdentifier = @"SelectPhotoCollectionViewCell";

    SelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QuoteCellIdentifier forIndexPath:indexPath];
    cell.deleteImageDelete = self;
    [cell setData:images[(NSUInteger) indexPath.row] forIndexPath:indexPath];
    return cell;

}

- (void)deleteCurrentImageForIndexPath:(NSIndexPath *)indexPath {
    [images removeObjectAtIndex:(NSUInteger) indexPath.row];
    [self.selectPhotos reloadData];
}


- (IBAction)createThread:(id)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    NSString *title = self.subject.text;
    NSString *message = self.message.text;

    NSString *category = self.category.titleLabel.text;

    if ([category isEqualToString:@"[请选分类]"]){
        [ProgressDialog showError:@"请选择分类"];
        return;
    }

    if (title.length < 1) {
        [ProgressDialog showError:@"标题太短"];
        return;
    }
    [ProgressDialog showStatus:@"正在发送"];

    NSMutableArray<NSData *> *uploadData = [NSMutableArray array];
    for (UIImage *image in images) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [uploadData addObject:data];
    }

    NSString *threadTitle = [category stringByAppendingString:title];

    [_forumApi createNewThreadWithCategory:category categoryIndex:categoryIndex + 1 withTitle:title andMessage:message
                                withImages:[uploadData copy] inPage:currentForumPage handler:^(BOOL isSuccess, id message) {
        [self dismissViewControllerAnimated:YES completion:^{

        }];

        if (isSuccess) {
            [ProgressDialog showSuccess:@"发帖成功"];
        } else {
            [ProgressDialog showError:@"发帖失败"];
        }
    }];
}

- (IBAction)back:(id)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)pickPhoto:(id)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    LCActionSheet *itemActionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [pickControl setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            
            [self presentViewController:pickControl animated:YES completion:nil];
        } else if (buttonIndex == 2) {
            [pickControl setSourceType:UIImagePickerControllerSourceTypeCamera];
            
            [self presentViewController:pickControl animated:YES completion:nil];
        }
    } otherButtonTitleArray:@[@"相册", @"拍照"]];
    
    [itemActionSheet show];

}

- (IBAction)showCategory:(UIButton *)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    NSArray *types = _typeidList.allKeys;

    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择分类"
                                                                                rows:types
                                                                    initialSelection:categoryIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

                self.category.titleLabel.text = types[(NSUInteger) selectedIndex];
                categoryIndex = selectedIndex;


    }  cancelBlock:^(ActionSheetStringPicker *picker) {

    }  origin:sender];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] init];
    cancelItem.title = @"取消";
    [picker setCancelButton:cancelItem];

    UIBarButtonItem *queding = [[UIBarButtonItem alloc] init];
    queding.title = @"确定";
    [picker setDoneButton:queding];


    [picker showActionSheetPicker];
}
@end
