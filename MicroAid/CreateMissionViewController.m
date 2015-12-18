//
//  CreateMissionViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/30.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "CreateMissionViewController.h"
#import "MicroAidAPI.h"
#import "BonusTableViewController.h"
#import "DateTimeUtils.h"
#import "TypeTableViewController.h"
#import "GroupTableViewController.h"
#import "LocationViewController.h"
#import "MyMissionsViewController.h"
#import "RootController.h"
#import "MainTabBarController.h"

@interface CreateMissionViewController (){
    bool isStartTime;
    bool isEndTime;
}

@end

@implementation CreateMissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:@"创建任务"];
    
    self.mission= [[Mission alloc] init];
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveMission) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    //[saveBtn release];
    self.navigationItem.rightBarButtonItem = saveItem;
    //[saveItem release];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.pickerView setHidden:YES];
    
    [self getLeftBobus];
    
    if(_isEditMission){
        [self getMission];
    }else{
        NSDate *date = [DateTimeUtils getCurrentTime];
        [startTimeBtn setTitle:[DateTimeUtils changeDateIntoString:date] forState:UIControlStateNormal];
        date = [DateTimeUtils getCurrentTimeAfterAnHour];
        [endTimeBtn setTitle:[DateTimeUtils changeDateIntoString:date] forState:UIControlStateNormal];
        
        
        //self.tabBarController.tabBar.hidden = YES;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *location = [userDefaults objectForKey:@"location"];
        if(!(location == nil||[location isEqualToString:@""])){
            [addressBtn setTitle:location forState:UIControlStateNormal];
            self.locationString = location;
            self.missionLatitude = [userDefaults doubleForKey:@"latitude"];
            self.missionLongitude = [userDefaults doubleForKey:@"longitude"];
        }
        
        self.groupString = [userDefaults objectForKey:@"defaultMissionGroup"];
        if(self.groupString == nil || [self.groupString isEqualToString:@""]){
            self.groupString = @"公开";
        }
        [objectBtn setTitle:self.groupString forState:UIControlStateNormal];
        self.bonusString = [userDefaults objectForKey:@"defaultMissionBonus"];
        if(self.bonusString == nil || [self.bonusString isEqualToString:@""]){
            self.bonusString = @"0分";
        }
        [bonusBtn setTitle:self.bonusString forState:UIControlStateNormal];
        self.typeString = [userDefaults objectForKey:@"defaultMissionType"];
        if(self.typeString == nil || [self.typeString isEqualToString:@""]){
            self.typeString = @"拿快递";
        }
        [typeBtn setTitle:self.typeString forState:UIControlStateNormal];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ProgressHUD dismiss];
    self.tabBarController.tabBar.hidden = YES;
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
}

-(void) getMission{
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchMission:self.missionID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
            NSMutableDictionary *dic = [resultDic objectForKey:@"task"];
            //显示
            [self performSelectorOnMainThread:@selector(showMissionInfo:) withObject:dic waitUntilDone:YES];
            
        }else//获取失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败,请检查网络!" waitUntilDone:YES];
            return ;
        }
    });
}

-(void) getLeftBobus{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI findUser:userID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
            NSMutableDictionary *dic = [resultDic objectForKey:@"user"];
            //显示
            [self performSelectorOnMainThread:@selector(showLeftBonus:) withObject:dic waitUntilDone:YES];
            
        }else//获取失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"余额获取失败,请检查网络!" waitUntilDone:YES];
            return ;
        }
    });
}

-(void) showLeftBonus:(NSMutableDictionary *)dic{
    self.leftBonus = [[dic objectForKey:@"scores"]integerValue];
    [leftBonusLabel setText:[NSString stringWithFormat:@"%li分",(long)self.leftBonus]];
}


-(void) showMissionInfo:(NSMutableDictionary *)dic{
    [startTimeBtn setTitle:[dic objectForKey:@"startTime"] forState:UIControlStateNormal];
    [endTimeBtn setTitle:[dic objectForKey:@"endTime"] forState:UIControlStateNormal];
    
    self.groupString = [dic objectForKey:@"publicity"];
    [objectBtn setTitle:self.groupString forState:UIControlStateNormal];
    
    self.typeString = [dic objectForKey:@"taskType"];
    [typeBtn setTitle:self.typeString forState:UIControlStateNormal];
    
    descriptionTextView.text =[dic objectForKey:@"description"];
    
    titleTextField.text = [dic objectForKey:@"title"];
    
    self.bonusString = [NSString stringWithFormat:@"%ld分",(long)[[dic objectForKey:@"taskScores"]integerValue]];
    [bonusBtn setTitle:self.bonusString forState:UIControlStateNormal];
    
    self.locationString = [dic objectForKey:@"address"];
    [addressBtn setTitle:self.locationString forState:UIControlStateNormal];
    self.missionLatitude = [[dic objectForKey:@"latitude"]doubleValue];
    self.missionLongitude = [[dic objectForKey:@"longitude"]doubleValue];
    
    self.mission.status = [[dic objectForKey:@"status"]integerValue];
}



#pragma --bonus delegate
-(void) passChoiceBonusValues:(NSString *)string{
    self.bonusString = string;
    
    [bonusBtn setTitle:string forState:UIControlStateNormal];
    [self.view endEditing:YES];
}

#pragma --type delegate
-(void) passChoiceTypeValues:(NSString *)string{
    self.typeString = string;
    
    [typeBtn setTitle:string forState:UIControlStateNormal];
    [self.view endEditing:YES];
}

#pragma --group delegate
-(void) passChoiceGroupValues:(NSString *)string{
    self.groupString = string;
    
    [objectBtn setTitle:string forState:UIControlStateNormal];
    [self.view endEditing:YES];
}

#pragma --location delegate
-(void) passChoiceLocationValues:(NSString *)string latitude:(double)latitude longitude:(double)longitude{
    self.missionLongitude = longitude;
    self.missionLatitude = latitude;
    self.locationString = string;
    [addressBtn setTitle:string forState:UIControlStateNormal];
    [self.view endEditing:YES];
}



-(void) textViewDidBeginEditing:(UITextView *)textView{
    CGRect frame = self.inputView.frame;
    frame.origin.y =64 - 230;
        [UIView animateWithDuration:0.5f
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0.1f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.inputView.frame = frame;}
                         completion:^(BOOL finished) {}];
    
    if ([textView.text isEqualToString:@"请在此输入任务描述"]) {
        textView.text = @"";
    }
}

-(void) textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"请在此输入任务描述";
    }
}

-(IBAction) buttonClicked:(UIButton *)sender{
    [self.view endEditing:YES];
    switch (sender.tag) {
        case 0:
        {
            NSDate *date;
            if([startTimeBtn.titleLabel.text isEqualToString:@"点击选择"]){
                date = [DateTimeUtils getCurrentTime];
            }else{
                date = [DateTimeUtils changeStringIntoDate:startTimeBtn.titleLabel.text];
            }
            [self.datePickerView setDate:date animated:YES];
            [self.pickerView setHidden:NO];
            isStartTime = YES;
            isEndTime = NO;
            break;
        }
        case 1:
        {
            NSDate *date;
            if([endTimeBtn.titleLabel.text isEqualToString:@"点击选择"]){
                date = [DateTimeUtils getCurrentTimeAfterAnHour];
            }else{
                date = [DateTimeUtils changeStringIntoDate:endTimeBtn.titleLabel.text];
            }
            [self.datePickerView setDate:date animated:YES];
            [self.pickerView setHidden:NO];
            isStartTime = NO;
            isEndTime = YES;
            break;
        }
            
        case 2:
        {
            self.view.userInteractionEnabled = false;
            [self.navigationController.navigationBar setUserInteractionEnabled:false];
            [self.pickerView setHidden:YES];
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI fetchAllExcel];
                if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
                    NSArray *list = [resultDic objectForKey:@"excelList"];
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[list count]];
                    for(int i =0; i<[list count]; i++){
                        NSDictionary *subList = [list objectAtIndex:i];
                        //NSString *index = (NSString *)[subList objectForKey:@"id"];
                        NSString *taskType =(NSString *)[subList objectForKey:@"taskType"];
                        [array addObject:taskType];
                    }
                    //显示
                    [self performSelectorOnMainThread:@selector(openTypeView:) withObject:array waitUntilDone:YES];
                    
                }else//获取失败
                {
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败,请检查网络!" waitUntilDone:YES];
                    return ;
                }
            });
            break;
        }
        case 3:
        {
            self.view.userInteractionEnabled = false;
            [self.navigationController.navigationBar setUserInteractionEnabled:false];
            [self.pickerView setHidden:YES];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSInteger userID = [userDefaults integerForKey:@"userID"];
            
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI fetchAllGroup:userID pageNo:1 pageSize:10];
                if ([[resultDic objectForKey:@"onError"] boolValue]) {//获取成功
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败,请检查网络!" waitUntilDone:YES];
                    return ;
                }else//获取失败
                {
                    if ([[resultDic objectForKey:@"flg"] boolValue]) {//有值
                        NSArray *list = [resultDic objectForKey:@"groupInfoList"];
                        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[list count]];
                        [array addObject:@"公开"];
                        for(int i =0; i<[list count]; i++){
                            NSString *groupName =(NSString *)[list objectAtIndex:i];
                            [array addObject:groupName];
                        }
                        //显示
                        [self performSelectorOnMainThread:@selector(openGroupView:) withObject:array waitUntilDone:YES];
                    }else{
                        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
                        [array addObject:@"公开"];
                        //显示
                        [self performSelectorOnMainThread:@selector(openGroupView:) withObject:array waitUntilDone:YES];
                    }
                }
            });
            break;
        }
        case 4:
        {
            [self.pickerView setHidden:YES];
            BonusTableViewController *bonusVC = [[BonusTableViewController alloc] initWithNibName:@"BonusTableViewController" bundle:nil];
            
            self.passMultiValuesDelegate = bonusVC;
            [self.passMultiValuesDelegate passBonusValues:self.bonusString];
            
            
            [self.navigationController pushViewController:bonusVC animated:YES];
            break;
        }
        case 5:
        {
            [self.pickerView setHidden:YES];
            LocationViewController *locationVC = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
            
            self.passMultiValuesDelegate = locationVC;
            [self.passMultiValuesDelegate passLocationValues:self.locationString latitude:self.missionLatitude longitude:self.missionLongitude];
            
            
            [self.navigationController pushViewController:locationVC animated:YES];
            break;
        }
        case 6:
        {
            [self.pickerView setHidden:YES];
            NSDate *date = self.datePickerView.date;
            if(isStartTime){
                [startTimeBtn setTitle:[DateTimeUtils changeDateIntoString:date] forState:UIControlStateNormal];
            }else{
                [endTimeBtn setTitle:[DateTimeUtils changeDateIntoString:date] forState:UIControlStateNormal];
            }
            break;
        }
        case 7:
        {
            [self.pickerView setHidden:YES];
            break;
        }
        default:
            break;
    }
}


//点击空白区域，键盘收起
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
    [self.pickerView setHidden:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) openTypeView:(NSMutableArray *)array{
    TypeTableViewController *typeVC = [[TypeTableViewController alloc] initWithNibName:@"TypeTableViewController" bundle:nil];
    self.passMultiValuesDelegate = typeVC;
    [self.passMultiValuesDelegate passTypeValues:array choiceString:self.typeString];
    [self.navigationController pushViewController:typeVC animated:YES];
}

-(void) openGroupView:(NSMutableArray *)array{
    GroupTableViewController *groupVC = [[GroupTableViewController alloc] initWithNibName:@"GroupTableViewController" bundle:nil];
    self.passMultiValuesDelegate = groupVC;
    [self.passMultiValuesDelegate passGroupValues:array choiceString:self.groupString];
    [self.navigationController pushViewController:groupVC animated:YES];
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void) successWithMessage:(NSString *)message {
    [self.view endEditing:YES];
    [ProgressHUD showSuccess:message];
}

-(void) switchNextViewController{
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    if(self.isFromMyMission){
        
        MyMissionsViewController *myMissionVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        [self.navigationController popToViewController:myMissionVC animated:YES];
    }else{
        if(self.isFromHomeView){
            RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
            [rootController switchToMainTabViewFromHomeView];
        }else{
            MainTabBarController *mainTBC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            
            [self.navigationController popToViewController:mainTBC animated:YES];
        }
    }
}

-(NSString *)formatBonus:(NSString *)bonus{
    if([bonus isEqualToString:@"点击选择"]){
        return bonus;
    }
    return [bonus substringToIndex:1];
}

//去掉空格
-(NSString *)formatString:(NSString *)string{
    return nil;
}

-(void) saveMission{
    if(_isEditMission){
        [ProgressHUD show:@"任务保存中..."];
    }else{
        [ProgressHUD show:@"任务创建中..."];
    }
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    [self.view setUserInteractionEnabled:false];
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
    [self.pickerView setHidden:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:[NSString stringWithString:titleTextField.text] forKey:@"title"];
    [self.mission setTitle:[NSString stringWithString:titleTextField.text]];
    [dic setObject:[NSString stringWithFormat:@"%li",(long)userID] forKey:@"userID"];
    [self.mission setUserID:userID];
    [dic setObject:typeBtn.titleLabel.text forKey:@"taskType"];
    [self.mission setType:typeBtn.titleLabel.text];
    [dic setObject:[self formatBonus:bonusBtn.titleLabel.text] forKey:@"taskScores"];
    [self.mission setBonus:[self formatBonus:bonusBtn.titleLabel.text]];
    [dic setObject:startTimeBtn.titleLabel.text forKey:@"startTime"];
    [self.mission setStartTime:startTimeBtn.titleLabel.text];
    [dic setObject:endTimeBtn.titleLabel.text forKey:@"endTime"];
    [self.mission setEndTime:endTimeBtn.titleLabel.text];
    
    [dic setObject:descriptionTextView.text forKey:@"description"];
    
    
    NSLog(@"des:%@",[NSString stringWithString:descriptionTextView.text]);
    [self.mission setDescript:descriptionTextView.text];
    if([[NSString stringWithString:descriptionTextView.text] isEqualToString:@"请在此输入任务描述"]){
        [self.mission setDescript:[NSString stringWithString:titleTextField.text]];
        [dic setObject:[NSString stringWithString:titleTextField.text] forKey:@"description"];
    }
    [dic setObject:addressBtn.titleLabel.text forKey:@"address"];
    [self.mission setAddress:addressBtn.titleLabel.text];
    [dic setObject:objectBtn.titleLabel.text forKey:@"publicity"];
    [self.mission setGroup:objectBtn.titleLabel.text];
    [dic setObject:[NSString stringWithFormat:@"%f",self.missionLatitude] forKey:@"latitude"];
    [self.mission setLatitude:self.missionLatitude];
    [dic setObject:[NSString stringWithFormat:@"%f",self.missionLongitude] forKey:@"longitude"];
    [self.mission setLongitude:self.missionLongitude];
    [dic setObject:@"0" forKey:@"status"];
    
    
    if([self.mission verifyInfo] && [self isLeftBonusEnough]){
        if(_isEditMission){
            [self.mission setMissionID:self.missionID];
            [dic setObject:[NSString stringWithFormat:@"%li",(long)self.missionID] forKey:@"id"];
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI updateMission:dic];
                if ([[resultDic objectForKey:@"flg"] boolValue]) {//修改成功
                    //显示
                    [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"任务修改成功!" waitUntilDone:YES];
                    [self performSelectorOnMainThread:@selector(switchNextViewController) withObject:nil waitUntilDone:YES];
                    return;
                }else//修改失败
                {
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"任务修改失败,请检查网络!" waitUntilDone:YES];
                    return ;
                }
            });
            
        }else{
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI createMission:dic];
                if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
                    //显示
                    [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"任务创建成功!" waitUntilDone:YES];
                    [self performSelectorOnMainThread:@selector(switchNextViewController) withObject:nil waitUntilDone:YES];
                    
                }else//创建失败
                {
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"网络错误,任务创建失败!" waitUntilDone:YES];
                    return ;
                }
            });
        }
    }else{
        [ProgressHUD dismiss];
        [self.navigationController.navigationBar setUserInteractionEnabled:true];
        [self.view setUserInteractionEnabled:true];
    }
}

-(BOOL) isLeftBonusEnough{
    NSInteger bonus = [[self formatBonus:bonusBtn.titleLabel.text]integerValue];
    if(bonus < self.leftBonus || bonus == self.leftBonus){
        return true;
    }else{
        [ProgressHUD showError:@"余额不足！"];
        return false;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
