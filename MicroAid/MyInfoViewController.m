//
//  MyInfoViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/18.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "MyInfoViewController.h"
#import "MicroAidAPI.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MineViewController.h"
#import "GTMBase64.h"

@interface MyInfoViewController (){
    BOOL isPhotoChanged;
    BOOL isInfoChanged;
}

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:@"编辑信息"];
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveMyInfo) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    //[saveBtn release];
    self.navigationItem.rightBarButtonItem = saveItem;
    //[saveItem release];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    isPhotoChanged = NO;
    [self findUser];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) findUser{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI findUser:userID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//查找成功
            NSDictionary *user = [resultDic objectForKey:@"user"];
            [self performSelectorOnMainThread:@selector(showMyInfo:) withObject:user waitUntilDone:YES];
        }else if([[resultDic objectForKey:@"onError"] boolValue])//失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"信息查找失败,请检查网络!" waitUntilDone:YES];
            return ;
        }
    });
    
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchPicture:userID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
            NSData *picture = [resultDic objectForKey:@"picture"];
            [self performSelectorOnMainThread:@selector(showPicture:) withObject:picture waitUntilDone:YES];
        }else if([[resultDic objectForKey:@"onError"] boolValue])//创建失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"头像查找失败！" waitUntilDone:YES];
            return ;
        }else{
            [self performSelectorOnMainThread:@selector(showPicture:) withObject:nil waitUntilDone:YES];
        }
    });
}

-(void) showPicture:(NSString *)picture{
    if(picture == nil){
        [photoBtn setBackgroundImage:[UIImage imageNamed:@"default_pic"] forState:UIControlStateNormal];
    }else{
        //需要转换了才能用
        NSString *formatedString = [picture stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSData *imageData = [GTMBase64 decodeString:formatedString];
        [photoBtn setBackgroundImage:[UIImage imageWithData:imageData scale:0.0] forState:UIControlStateNormal];
    }
}

-(void) showMyInfo:(NSDictionary *)dic{
    self.nickName =[dic objectForKey:@"nickName"];
    [nickNameBtn setTitle:self.nickName forState:UIControlStateNormal];
    self.gender = [dic objectForKey:@"gender"];
    if(![self.gender isKindOfClass:[NSString class]] || [self.gender isEqualToString:@""]){
        self.gender = @"点击修改";
    }
    [genderBtn setTitle:self.gender forState:UIControlStateNormal];
    self.address = [dic objectForKey:@"address"];
    if(![self.address isKindOfClass:[NSString class]] || [self.address isEqualToString:@""]){
        self.address = @"点击修改";
    }
    [addressBtn setTitle:self.address forState:UIControlStateNormal];
    self.score = [[dic objectForKey:@"scores"]integerValue];
    [scoreBtn setTitle:[NSString stringWithFormat:@"%ld",(long)self.score] forState:UIControlStateNormal];
    self.email = [dic objectForKey:@"email"];
    if(![self.email isKindOfClass:[NSString class]] || [self.email isEqualToString:@""]){
        self.email = @"点击修改";
    }
    [emailBtn setTitle:self.email forState:UIControlStateNormal];
    
}

-(IBAction) choosePhoto:(UIButton *)sender{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.view endEditing:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
}

-(IBAction)modeInfo:(UIButton *)sender{
    switch(sender.tag){
        case 0:{
            UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"请输入昵称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [dialog textFieldAtIndex:0].text = nickNameBtn.titleLabel.text;
            [dialog setTag:0];
            [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
            [dialog show];
            break;
        }
        case 1:{
            UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"请选择性别" message:nil delegate:self cancelButtonTitle:@"男" otherButtonTitles:@"女",nil];
            [dialog setAlertViewStyle:UIAlertViewStyleDefault];
            [dialog setTag:1];
            [dialog show];
            break;
        }
        case 2:{
            UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"请输入邮箱" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
            if(![emailBtn.titleLabel.text isEqualToString:@"点击修改"]){
                [dialog textFieldAtIndex:0].text = emailBtn.titleLabel.text;
            }
            [dialog setTag:2];
            [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
            [dialog show];
            break;
        }
        case 3:{
            UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"请输入住址" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
            if(![addressBtn.titleLabel.text isEqualToString:@"点击修改"]){
                [dialog textFieldAtIndex:0].text = addressBtn.titleLabel.text;
            }
            [dialog setTag:3];
            [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
            [dialog show];
            break;
        }
        default:
            break;
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){//按下确定
        if(alertView.tag == 0){
            NSString *nickName = [alertView textFieldAtIndex:0].text;
            if(![nickName isEqualToString:@""]){
                //self.nickName = nickName;
                [nickNameBtn setTitle:nickName forState:UIControlStateNormal];
            }else{
                [self errorWithMessage:@"请输入昵称"];
            }
        }
        if(alertView.tag == 1){
            //self.gender = @"女";
            [genderBtn setTitle:@"女" forState:UIControlStateNormal];
        }
        if(alertView.tag == 2){
            NSString *email = [alertView textFieldAtIndex:0].text;
            if([self validateEmail:email]){
                //self.email = email;
                [emailBtn setTitle:email forState:UIControlStateNormal];
            }else{
                [self errorWithMessage:@"请输入正确的邮箱地址"];
            }
        }
        if(alertView.tag == 3){
            NSString *address = [alertView textFieldAtIndex:0].text;
            if(![address isEqualToString:@""]){
                //self.address = address;
                [addressBtn setTitle:address forState:UIControlStateNormal];
            }else{
                [self errorWithMessage:@"请输入地址"];
            }
        }
    }else if(buttonIndex == 0){
        if(alertView.tag == 1){
            //self.gender = @"男";
            [genderBtn setTitle:@"男" forState:UIControlStateNormal];
        }
    }
    
}

-(BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void) saveMyInfo{
    //首先保存信息，在保存图片
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
//    [userDefaults setObject:nickNameBtn.titleLabel.text forKey:@"nickName"];
//    [userDefaults synchronize];
    [ProgressHUD show:@"正在上传"];
    self.view.userInteractionEnabled = NO;
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    
    isInfoChanged = [self testChange];
    if(isInfoChanged || isPhotoChanged){
        dispatch_async(serverQueue, ^{
            BOOL isPhotoSuccess = NO;
            BOOL isInfoSuccess = NO;
            if(isInfoChanged){
                NSString *tempNickName = [nickNameBtn.titleLabel.text isEqualToString:@"点击修改"]? @"" : nickNameBtn.titleLabel.text;
                NSString *tempGender = [genderBtn.titleLabel.text isEqualToString:@"点击修改"]? @"" : genderBtn.titleLabel.text;
                NSString *tempAddress = [addressBtn.titleLabel.text isEqualToString:@"点击修改"]? @"" : addressBtn.titleLabel.text;
                NSString *tempEmail = [emailBtn.titleLabel.text isEqualToString:@"点击修改"]? @"" : emailBtn.titleLabel.text;
                NSDictionary *resultDic = [MicroAidAPI updateUser:userID nickName:tempNickName gender:tempGender message:@"" address:tempAddress email:tempEmail];
                if ([[resultDic objectForKey:@"flg"] boolValue]) {//查找成功
                    isInfoSuccess = YES;
                }
            }
            if(isPhotoChanged){
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                NSString *picture =[self compressPicture];
                
                [dic setObject:picture forKey:@"picture"];
                [dic setObject:[NSString stringWithFormat:@"%ld",(long)userID] forKey:@"userID"];
                
                NSDictionary *resultDic = [MicroAidAPI savePicture:dic];
                if ([[resultDic objectForKey:@"flg"] boolValue]) {
                    isPhotoSuccess = YES;
                }
            }
            
            if(((isInfoChanged && isInfoSuccess)||!isInfoChanged) && ((isPhotoChanged && isPhotoSuccess)||!isPhotoChanged)){
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"信息修改成功!" waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(returnToMine) withObject:nil waitUntilDone:YES];
            }else if((isInfoChanged && isInfoSuccess)||!isInfoChanged){
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"头像修改失败,请检查网络!" waitUntilDone:YES];
            }else if((isPhotoChanged && isPhotoSuccess)||!isPhotoChanged){
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"基本信息修改失败,请检查网络!" waitUntilDone:YES];
            }else{
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"信息修改失败,请检查网络!" waitUntilDone:YES];
                return ;
            }
            
        });
    }else{
        [ProgressHUD dismiss];
        [self returnToMine];
    }
    
}

-(void)returnToMine{
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nickNameBtn.titleLabel.text forKey:@"nickName"];
    [userDefaults synchronize];
    MineViewController *mineVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    [self.navigationController popToViewController:mineVC animated:YES];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}


#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        self.portait = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        isPhotoChanged = YES;
        [photoBtn setBackgroundImage:self.portait forState:UIControlStateNormal];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}


#pragma mark - picture compress
-(NSString*) compressPicture{
    NSData *imageData = UIImageJPEGRepresentation(self.portait,0.1);
    
    NSString *str =[GTMBase64 stringByEncodingData:imageData];
    
    return str;
}

-(BOOL) testChange{
    if(![self.address isEqualToString:addressBtn.titleLabel.text]){
        return YES;
    }
    if(![self.nickName isEqualToString:nickNameBtn.titleLabel.text]){
        return YES;
    }
    if(![self.gender isEqualToString:genderBtn.titleLabel.text]){
        return YES;
    }
    if(![self.email isEqualToString:emailBtn.titleLabel.text]){
        return YES;
    }
    return NO;
}

@end
