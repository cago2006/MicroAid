//
//  AddTagViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import "AddTagViewController.h"
#import "TagLocationViewController.h"
#import "DescriptTableViewController.h"
#import "FreeTypeTableViewController.h"
#import "MicroAidAPI.h"
#import "RootController.h"

@interface AddTagViewController ()

@end

@implementation AddTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"创建标签"];
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveTag) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    //[saveBtn release];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.isEdit){
        //处理resultDic;
        return;
    }
    if(self.locationString == nil){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *location = [userDefaults objectForKey:@"location"];
        if(!(location == nil||[location isEqualToString:@""])){
            [locationBtn setTitle:location forState:UIControlStateNormal];
            self.locationString = location;
            self.latitude = [userDefaults doubleForKey:@"latitude"];
            self.longitude = [userDefaults doubleForKey:@"longitude"];
        }
    }else{
        [locationBtn setTitle:self.locationString forState:UIControlStateNormal];
    }
    if(self.descriptString!=nil){
        [descripTextView setText:self.descriptString];
    }
    if(self.typeString!=nil){
        [typeBtn setTitle:self.typeString forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //视图返回原位
    CGRect frame = self.inputView.frame;
    frame.origin.y = 64;
    [UIView animateWithDuration:0.5f
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.1f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.inputView.frame = frame;}
                     completion:^(BOOL finished) {}];
    [self.view endEditing:YES];
}

-(IBAction) locationBtnClicked:(UIButton *)sender{
    
    TagLocationViewController *locationVC = [[TagLocationViewController alloc] initWithNibName:@"TagLocationViewController" bundle:nil];
    
    locationVC.tagLocation = self.locationString;
    locationVC.tagLatitude = self.latitude;
    locationVC.tagLongitude = self.longitude;
    
    [self.navigationController pushViewController:locationVC animated:YES];
}
-(IBAction) descripBtnClicked:(UIButton *)sender{
    DescriptTableViewController *desTVC = [[DescriptTableViewController alloc] initWithNibName:@"DescriptTableViewController" bundle:nil];
    if(self.descriptString!=nil){
        desTVC.hasFacilities = self.descriptString;
    }
    [self.navigationController pushViewController:desTVC animated:YES];
}

-(IBAction) typeBtnClicked:(UIButton *)sender{
    FreeTypeTableViewController *freeTypeTVC = [[FreeTypeTableViewController alloc]initWithNibName:@"FreeTypeTableViewController" bundle:nil];
    if(self.typeString != nil){
        freeTypeTVC.typeString = self.typeString;
    }
    [self.navigationController pushViewController:freeTypeTVC animated:YES];
}


-(void) textViewDidBeginEditing:(UITextView *)textView{
    CGRect frame = self.inputView.frame;
    frame.origin.y =64 - 200;
    [UIView animateWithDuration:0.5f
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.1f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.inputView.frame = frame;}
                     completion:^(BOOL finished) {}];
    
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    CGRect frame = self.inputView.frame;
    frame.origin.y =64 - 200;
    [UIView animateWithDuration:0.5f
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.1f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.inputView.frame = frame;}
                     completion:^(BOOL finished) {}];
}

-(void) saveTag{
    if(self.isEdit){
        //纠错，不一定马上改正
    }else{//添加无障碍设施
        if([self validateTag]){
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:[titleField text] forKey:@"name"];
            [dic setObject:self.descriptString forKey:@"description"];
            [dic setObject:[phoneField text] forKey:@"tel"];
            [dic setObject:self.locationString forKey:@"address"];
            [dic setObject:[NSString stringWithFormat:@"%f",self.latitude] forKey:@"latitude"];
            [dic setObject:[NSString stringWithFormat:@"%f",self.longitude] forKey:@"longitude"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSInteger userID = [[userDefaults objectForKey:@"userID"] integerValue];
            
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI createBarrierFree:userID dic:dic];
                if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
                    //显示
                    [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"任务创建成功!" waitUntilDone:YES];
                    [self performSelectorOnMainThread:@selector(returnToHome) withObject:nil waitUntilDone:YES];
                    
                }else//创建失败
                {
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"网络错误,任务创建失败!" waitUntilDone:YES];
                    return ;
                }
            });
        }
    }
}

-(BOOL) validateTag{
    if([[titleField text]isEqualToString:@""]){
        return NO;
    }
    if(self.locationString == nil||[self.locationString isEqualToString:@""]){
        return NO;
    }
    if(self.descriptString == nil || [self.descriptString isEqualToString:@""]){
        return NO;
    }
    return YES;
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

-(void)returnToHome{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
