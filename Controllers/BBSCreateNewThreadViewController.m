//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSCreateNewThreadViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking/AFImageDownloader.h>
#import "LCActionSheet.h"
#import "ActionSheetStringPicker.h"
#import "UIImage+Tint.h"
#import "BBSLocalApi.h"
#import "BBSPayManager.h"
#import "UIStoryboard+Forum.h"
#import "ProgressDialog.h"
#import "UIKit+AFNetworking.h"
#import "NSString+Extensions.h"

@interface BBSCreateNewThreadViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
        UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
        DeleteDelegate, TranslateDataDelegate, UIScrollViewDelegate> {


    id <BBSApiDelegate> _forumApi;
    int forumId;
    UIImagePickerController *pickControl;
    NSMutableArray<UIImage *> *images;

    ViewForumPage *currentForumPage;

    int categoryIndex;

    BBSPayManager *_payManager;
    BBSLocalApi *_localForumApi;

    NSString *_post_hash;
    NSString *_forum_hash;
    NSString *_posttime;
    NSString *_seccodehash;
    NSString *_seccodeverify;
    NSDictionary *_typeidList;

    IBOutlet UITextField *secCodeTV;
    IBOutlet UIImageView *vCodeImgV;
    IBOutlet NSLayoutConstraint *vCodeHeight;
    IBOutlet NSLayoutConstraint *vCodeTVHeight;
}

@end

@implementation BBSCreateNewThreadViewController

- (void)transBundle:(TranslateData *)bundle {
    forumId = [bundle getIntValue:@"FORM_ID"];
    currentForumPage = [bundle getObjectValue:@"CREATE_THREAD_IN"];
}

- (IBAction)refreshSecCode:(id)sender {

    [_forumApi enterCreateThreadPageFetchInfo:forumId :^(NSString *responseHtml, NSString *post_hash, NSString *forum_hash, NSString *posttime,
            NSString *seccodehash, NSString *seccodeverify, NSDictionary *typeidList) {

        _post_hash = post_hash;
        _forum_hash = forum_hash;
        _posttime = posttime;
        _seccodehash = seccodehash;
        _seccodeverify = seccodeverify;
        _typeidList = typeidList;

        AFImageDownloader *downloader = [[vCodeImgV class] sharedImageDownloader];
        id <AFImageRequestCache> imageCache = downloader.imageCache;
        [imageCache removeImageWithIdentifier:_seccodeverify];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_seccodeverify]];

        NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSDictionary *dictCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];

        NSString *object = dictCookies[@"Cookie"];
        [request setValue:object forHTTPHeaderField:@"Cookie"];

        [request setValue:@"bbs.smartisan.com" forHTTPHeaderField:@"Host"];
        [request setValue:@"image/webp,image/apng,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [request setValue:@"1" forHTTPHeaderField:@"DNT"];
        [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:@"zh-CN,zh;q=0.9,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
        NSString *referer = [NSString stringWithFormat:@"http://bbs.smartisan.com/forum.php?mod=post&action=newthread&fid=%d&referer=", forumId];
        [request setValue:referer forHTTPHeaderField:@"Referer"];
        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36" forHTTPHeaderField:@"User-Agent"];

        UIImageView *view = vCodeImgV;

        [vCodeImgV setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, UIImage *_Nonnull image) {
            [view setImage:image];
        }                         failure:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, NSError *_Nonnull error) {
            NSLog(@"refreshDoor failed >> >> %@", urlRequest.allHTTPHeaderFields);
        }];

        if (_typeidList != nil) {
            [ProgressDialog dismiss];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    categoryIndex = 0;

    // payManager
    _payManager = [BBSPayManager shareInstance];

    _localForumApi = [[BBSLocalApi alloc] init];
    _forumApi = [BBSApiHelper forumApi:_localForumApi.currentForumHost];

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

    _category.titleLabel.text = @"[无分类]";
    _category.enabled = NO;

    [_forumApi enterCreateThreadPageFetchInfo:forumId :^(NSString *responseHtml, NSString *post_hash, NSString *forum_hash, NSString *posttime,
            NSString *seccodehash, NSString *seccodeverify, NSDictionary *typeidList) {

        _post_hash = post_hash;
        _forum_hash = forum_hash;
        _posttime = posttime;
        _seccodehash = seccodehash;
        _seccodeverify = seccodeverify;
        _typeidList = typeidList;

        AFImageDownloader *downloader = [[vCodeImgV class] sharedImageDownloader];
        id <AFImageRequestCache> imageCache = downloader.imageCache;
        [imageCache removeImageWithIdentifier:_seccodeverify];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_seccodeverify]];

        NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSDictionary *dictCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];

        NSString *object = dictCookies[@"Cookie"];
        [request setValue:object forHTTPHeaderField:@"Cookie"];

        [request setValue:@"bbs.smartisan.com" forHTTPHeaderField:@"Host"];
        [request setValue:@"image/webp,image/apng,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [request setValue:@"1" forHTTPHeaderField:@"DNT"];
        [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:@"zh-CN,zh;q=0.9,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
        NSString *referer = [NSString stringWithFormat:@"http://bbs.smartisan.com/forum.php?mod=post&action=newthread&fid=%d&referer=", forumId];
        [request setValue:referer forHTTPHeaderField:@"Referer"];
        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36" forHTTPHeaderField:@"User-Agent"];

        UIImageView *view = vCodeImgV;

        [vCodeImgV setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, UIImage *_Nonnull image) {
            [view setImage:image];
            vCodeHeight.constant = 46.0;
            vCodeTVHeight.constant = 30.0;
        }                         failure:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, NSError *_Nonnull error) {
            NSLog(@"refreshDoor failed >> >> %@", urlRequest.allHTTPHeaderFields);
            vCodeHeight.constant = 0.0;
        }];

        if (_typeidList != nil) {
            [ProgressDialog dismiss];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }

        if (typeidList.allKeys.count > 0) {
            [_category setTitle:@"[请选分类]" forState:UIControlStateNormal];
            [_category setTitle:@"[请选分类]" forState:UIControlStateDisabled];
            _category.enabled = YES;
        } else {
            [_category setTitle:@"[无分类]" forState:UIControlStateNormal];
            [_category setTitle:@"[无分类]" forState:UIControlStateDisabled];
            _category.enabled = NO;
        }
    }];

    vCodeHeight.constant = 0.0;
    vCodeTVHeight.constant = 0.0;

}

- (void)viewDidAppear:(BOOL)animated {
    if (![_payManager hasPayed:[_localForumApi currentProductID]]) {
        [self showFailedMessage:@"发新帖需要解锁高级功能"];
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

    UIImage *scaleImage = [select scaleUIImage:CGSizeMake(500, 500)];

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

    BBSSelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QuoteCellIdentifier forIndexPath:indexPath];
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

    if ([category isEqualToString:@"[请选分类]"]) {
        [ProgressDialog showError:@"请选择分类"];
        return;
    }

    if (title.length < 1) {
        [ProgressDialog showError:@"标题太短"];
        return;
    }

    if (vCodeHeight.constant > 1 && [[secCodeTV.text trim] isEqualToString:@""]) {
        [ProgressDialog showError:@"输入验证码"];
        return;
    }

    [ProgressDialog showStatus:@"正在发送"];

    NSMutableArray<NSData *> *uploadData = [NSMutableArray array];
    for (UIImage *image in images) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [uploadData addObject:data];
    }

    if ([_localForumApi.currentForumHost isEqualToString:@"bbs.smartisan.com"]) {
        NSString *categoryName = _typeidList.allKeys[(NSUInteger) categoryIndex];

        [_forumApi createNewThreadWithCategory:categoryName categoryValue:[_typeidList valueForKey:categoryName] withTitle:title
                                    andMessage:message withImages:uploadData inPage:currentForumPage postHash:_post_hash
                                      formHash:_forum_hash secCodeHash:_seccodehash seccodeverify:[secCodeTV.text trim] postTime:_posttime handler:^(BOOL isSuccess, id message) {

                    if (isSuccess) {
                        [ProgressDialog showSuccess:@"发帖成功"];
                    } else {
                        [ProgressDialog showError:@"发帖失败"];
                    }
                }];
    } else {
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


}

- (IBAction)back:(id)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)pickPhoto:(id)sender {

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

- (IBAction)showCategory:(UIButton *)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    NSArray *types = _typeidList.allKeys;

    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择分类"
                                                                                rows:types
                                                                    initialSelection:categoryIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

                self.category.titleLabel.text = types[(NSUInteger) selectedIndex];
                categoryIndex = selectedIndex;


            }                                                            cancelBlock:^(ActionSheetStringPicker *picker) {

            }                                                                 origin:sender];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] init];
    cancelItem.title = @"取消";
    [picker setCancelButton:cancelItem];

    UIBarButtonItem *queding = [[UIBarButtonItem alloc] init];
    queding.title = @"确定";
    [picker setDoneButton:queding];


    [picker showActionSheetPicker];
}
@end
