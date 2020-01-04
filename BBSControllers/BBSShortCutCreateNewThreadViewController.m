//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 None. All rights reserved.
//

#import "BBSShortCutCreateNewThreadViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"
#import "UIImage+Tint.h"
#import "BBSLocalApi.h"
#import "ProgressDialog.h"

@interface BBSShortCutCreateNewThreadViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
        UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
        DeleteDelegate, TranslateDataDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {


    id <BBSApiDelegate> _forumApi;
    int forumId;
    UIImagePickerController *pickControl;
    NSMutableArray<UIImage *> *images;
    Forum *createForum;

    UIPickerView *_pickerView;
    int _pickerViewSelectRow;

    NSMutableArray<NSString *> *forumNames;
}

@end


@implementation BBSShortCutCreateNewThreadViewController

- (void)transBundle:(TranslateData *)bundle {
    forumId = [bundle getIntValue:@"FORM_ID"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    forumNames = [NSMutableArray array];

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    _forumApi = [BBSApiHelper forumApi:localForumApi.currentForumHost];

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

    _createWhichForum.enabled = NO;

//    if (@available(iOS 13.0, *)) {
//        self.subject.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
//        self.createWhichForum.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
//    }
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

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath.path error:&error];
    id fileSize = fileAttributes[NSFileSize];
    NSLog(@"图片大小:   %@", fileSize);
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
    }
    return nil;
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    //    UIImage *image=info[@"UIImagePickerControllerOriginalImage"];

    //    UIImage *image=info[@"UIImagePickerControllerEditedImage"];

    UIImage *select = [info valueForKey:UIImagePickerControllerOriginalImage];

    NSURL *selectUrl = [info valueForKey:UIImagePickerControllerReferenceURL];

    //NSData *date = UIImageJPEGRepresentation(select, 1.0);

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

    if (title.length < 1) {
        [ProgressDialog showError:@"标题太短"];
        return;
    }

    if (self.createWhichForum.text.length == 0) {
        [ProgressDialog showError:@"标题太短"];
        return;
    }

    [ProgressDialog showStatus:@"正在发送"];

    NSMutableArray<NSData *> *uploadData = [NSMutableArray array];
    for (UIImage *image in images) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [uploadData addObject:data];
    }

    ViewForumPage *viewForumPage = [[ViewForumPage alloc] init];
    viewForumPage.forumId = forumId;

    [_forumApi createNewThreadWithCategory:title categoryIndex:0 withTitle:title andMessage:message withImages:[uploadData copy] inPage:viewForumPage handler:^(BOOL isSuccess, id message) {
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

//    LCActionSheet *itemActionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *_Nonnull actionSheet, NSInteger buttonIndex) {
//        if (buttonIndex == 1) {
//            [pickControl setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//
//            [self presentViewController:pickControl animated:YES completion:nil];
//        } else if (buttonIndex == 2) {
//            [pickControl setSourceType:UIImagePickerControllerSourceTypeCamera];
//
//            [self presentViewController:pickControl animated:YES completion:nil];
//        }
//    }                                        otherButtonTitleArray:@[@"相册", @"拍照"]];
//
//    [itemActionSheet show];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [pickControl setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

        [self presentViewController:pickControl animated:YES completion:nil];

    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [pickControl setSourceType:UIImagePickerControllerSourceTypeCamera];

        [self presentViewController:pickControl animated:YES completion:nil];

    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {


    }]];

    UIPopoverPresentationController *popover = alertController.popoverPresentationController;

    if (popover) {
        popover.barButtonItem = self.navigationItem.rightBarButtonItem;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }

    [self presentViewController:alertController animated:true completion:nil];

}

- (UIPickerView *)pickerView:(UIAlertController *) controller {
    CGRect controllerFrame = controller.view.frame;
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(controllerFrame.origin.x - 8, controllerFrame.origin.y + 16, controllerFrame.size.width - 8, 200)];

    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    [_pickerView selectRow:0 inComponent:0 animated:YES];

    return _pickerView;

}

#pragma mark - delegate
// 选中某一组的某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _pickerViewSelectRow = row;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return forumNames[row];
}

- (IBAction)showAllForums:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [_forumApi listAllForums:^(BOOL isSuccess, id message) {
        NSArray<Forum *> *all = message;

        NSMutableArray<Forum *> *canCreateThreadFrums = [NSMutableArray array];

        [forumNames removeAllObjects];

        for (Forum *forum in all) {
            if (forum.parentForumId != -1) {
                [canCreateThreadFrums addObject:forum];
                [forumNames addObject:[forum forumName]];
            }
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择板块"
                message:@"\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];


        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {


            self.createWhichForum.text = forumNames[(NSUInteger) _pickerViewSelectRow];
            createForum = canCreateThreadFrums[(NSUInteger) _pickerViewSelectRow];

            forumId = createForum.forumId;

        }]];

        UIPickerView *pickerView = [self pickerView:alertController];
        [alertController.view addSubview:pickerView];

        UIPopoverPresentationController *popover = alertController.popoverPresentationController;

        if (popover) {
            popover.sourceView = self.view;
            popover.sourceRect = self.view.frame;
            popover.permittedArrowDirections = UIPopoverArrowDirectionDown;

            [self presentViewController:alertController animated:true completion:^{
                CGRect frame = pickerView.frame;
                CGRect controllerFrame = alertController.view.frame;
                CGRect newF = CGRectMake(controllerFrame.origin.x, controllerFrame.origin.y, controllerFrame.size.width, controllerFrame.size.height);
                pickerView.frame = newF;
            }];
        } else {
            [self presentViewController:alertController animated:true completion:nil];
        }

//        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择板块" rows:forumNames initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//
//            self.createWhichForum.text = forumNames[(NSUInteger) selectedIndex];
//            createForum = canCreateThreadFrums[(NSUInteger) selectedIndex];
//
//            forumId = createForum.forumId;
//
//        } cancelBlock:^(ActionSheetStringPicker *picker) {
//
//        } origin:sender];
//
//        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] init];
//        cancelItem.title = @"取消";
//        [picker setCancelButton:cancelItem];
//
//        UIBarButtonItem *queding = [[UIBarButtonItem alloc] init];
//        queding.title = @"确定";
//        [picker setDoneButton:queding];
//
//
//        [picker showActionSheetPicker];

    }];

}

- (IBAction)showCategory:(UIButton *)sender {

    NSArray *categorys = @[@"【分享】", @"【推荐】", @"【求助】", @"【注意】", @"【ＣＸ】", @"【高兴】", @"【难过】", @"【转帖】", @"【原创】", @"【讨论】"];
    [forumNames removeAllObjects];

    [forumNames addObjectsFromArray:categorys];

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择分类"
                                                                             message:@"\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];


    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {


        self.subject.text = [NSString stringWithFormat:@"%@%@", categorys[(NSUInteger) _pickerViewSelectRow], self.subject.text];

    }]];

    UIPickerView *pickerView = [self pickerView:alertController];
    [alertController.view addSubview:pickerView];

    UIPopoverPresentationController *popover = alertController.popoverPresentationController;

    if (popover) {
        popover.sourceView = self.view;
        popover.sourceRect = self.view.frame;
        popover.permittedArrowDirections = UIPopoverArrowDirectionDown;

        [self presentViewController:alertController animated:true completion:^{
            CGRect frame = pickerView.frame;
            CGRect controllerFrame = alertController.view.frame;
            CGRect newF = CGRectMake(controllerFrame.origin.x, controllerFrame.origin.y, controllerFrame.size.width, controllerFrame.size.height);
            pickerView.frame = newF;
        }];
    } else {
        [self presentViewController:alertController animated:true completion:nil];
    }


//    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择分类" rows:categorys
//            initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//
//        self.subject.text = [NSString stringWithFormat:@"%@%@", categorys[(NSUInteger) selectedIndex], self.subject.text];
//
//    }                                                                    cancelBlock:^(ActionSheetStringPicker *picker) {
//
//    }                                                                         origin:sender];
//
//    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] init];
//    cancelItem.title = @"取消";
//    [picker setCancelButton:cancelItem];
//
//    UIBarButtonItem *queding = [[UIBarButtonItem alloc] init];
//    queding.title = @"确定";
//    [picker setDoneButton:queding];
//
//
//    [picker showActionSheetPicker];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return forumNames.count;
}

@end
