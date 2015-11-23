//
//  FilterViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/15.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "FilterViewController.h"
#import "DateTimeUtils.h"
#import "MicroAidAPI.h"
#import "RootController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"筛选任务"];
    //self.tabBarController.tabBar.hidden = YES;
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveFilter) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    //[saveBtn release];
    
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetFilter)];
    
    NSArray *itemArray=[[NSArray alloc]initWithObjects:saveItem,resetItem, nil];
    //[saveItem release];
    //[resetItem release];
    [self.navigationItem setRightBarButtonItems:itemArray];

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.pickerView setHidden:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.missionGroup = [userDefaults objectForKey:@"missionGroup"];
    self.missionDistance = [userDefaults doubleForKey:@"missionDistance"];
    self.missionBonus = [userDefaults objectForKey:@"missionBonus"];
    self.missionType = [userDefaults objectForKey:@"missionType"];
    self.missionEndTime = [userDefaults objectForKey:@"missionEndTime"];
    
    if(self.missionEndTime == nil || [self.missionEndTime isEqualToString:@""]){
        self.missionEndTime = @"全部";
    }
    [timeBtn setTitle:self.missionEndTime forState:UIControlStateNormal];
    if(self.missionDistance < 0.1){
        self.missionDistance = 1000.0;
    }
    distanceTextField.text = [NSString stringWithFormat:@"%.1f",self.missionDistance];
    if(self.missionGroup == nil || [self.missionGroup isEqualToString:@""]){
        self.missionGroup = @"全部";
    }
    [objectBtn setTitle:self.missionGroup forState:UIControlStateNormal];
    if(self.missionBonus == nil || [self.missionBonus isEqualToString:@""]){
        self.missionBonus = @"全部";
    }
    if([self.missionBonus isEqualToString:@"全部"]){
        [bonusBtn setTitle:self.missionBonus forState:UIControlStateNormal];
    }else{
        NSString *bonusAfterFomat = [NSString stringWithFormat:@"%@分",self.missionBonus];
        [bonusBtn setTitle:bonusAfterFomat forState:UIControlStateNormal];
    }
    if(self.missionType == nil || [self.missionType isEqualToString:@""]){
        self.missionType = @"全部";
    }
    typeBtn.titleLabel.text = self.missionType;
    [typeBtn setTitle:self.missionType forState:UIControlStateNormal];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
}

-(void) passFilterBonusValues:(NSString *)string{
    self.missionBonus = string;
    [bonusBtn setTitle:self.missionBonus forState:UIControlStateNormal];
}

-(void) passFilterTypeValues:(NSString *)string{
    self.missionType = string;
    [typeBtn setTitle:self.missionType forState:UIControlStateNormal];
}

-(void) passFilterGroupValues:(NSString *)string{
    self.missionGroup = string;
    [objectBtn setTitle:self.missionGroup forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(IBAction) buttonClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
        {
            self.view.userInteractionEnabled = false;
            [self.navigationController.navigationBar setUserInteractionEnabled:false];
            [self.pickerView setHidden:YES];
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI fetchAllExcel];
                if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
                    NSArray *list = [resultDic objectForKey:@"excelList"];
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[list count]+1];
                    [array addObject:@"全部"];
                    for(int i =0; i<[list count]; i++){
                        NSDictionary *subList = [list objectAtIndex:i];
                        NSString *taskType =(NSString *)[subList objectForKey:@"taskType"];
                        [array addObject:taskType];
                    }
                    //显示
                    [self performSelectorOnMainThread:@selector(openTypeView:) withObject:array waitUntilDone:YES];
                    
                }else//获取失败
                {
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败！" waitUntilDone:YES];
                    return ;
                }
            });
            break;
        }
        case 1:
        {
            [self.pickerView setHidden:YES];
            FilterBonusTVC *bonusVC = [[FilterBonusTVC alloc] initWithNibName:@"FilterBonusTVC" bundle:nil];
            
            self.passFilterValuesDelegate = bonusVC;
            [self.passFilterValuesDelegate passBonusValues:self.missionBonus];

            [self.navigationController pushViewController:bonusVC animated:YES];
            break;
        }
        case 2:
        {
            self.view.userInteractionEnabled = false;
            [self.navigationController.navigationBar setUserInteractionEnabled:false];
            [self.pickerView setHidden:YES];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSInteger userID = [userDefaults integerForKey:@"userID"];
            
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI fetchAllGroup:userID pageNo:1 pageSize:10];
                if ([[resultDic objectForKey:@"onError"] boolValue]) {//获取成功
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败！" waitUntilDone:YES];
                    return ;
                }else//获取失败
                {
                    if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
                        NSArray *list = [resultDic objectForKey:@"groupInfoList"];
                        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[list count]];
                        [array addObject:@"全部"];
                        [array addObject:@"公开"];
                        for(int i =0; i<[list count]; i++){
                            NSString *groupName =(NSString *)[list objectAtIndex:i];
                            [array addObject:groupName];
                        }
                        //显示
                        [self performSelectorOnMainThread:@selector(openGroupView:) withObject:array waitUntilDone:YES];
                    }else{
                        NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
                        [array addObject:@"全部"];
                        [array addObject:@"公开"];
                        //显示
                        [self performSelectorOnMainThread:@selector(openGroupView:) withObject:array waitUntilDone:YES];
                    }
                }
            });
            break;
        }
        case 3:
        {
            NSDate *date ;
            if([timeBtn.titleLabel.text isEqualToString:@"全部"]){
                date = [DateTimeUtils getCurrentTime];
            }else{
                date = [DateTimeUtils changeStringIntoDate:timeBtn.titleLabel.text];
            }
            [self.datePickerView setDate:date animated:YES];
            [self.pickerView setHidden:NO];
            break;
        }
        case 4:
        {
            [self.pickerView setHidden:YES];
            NSDate *date = self.datePickerView.date;
            self.missionEndTime =[DateTimeUtils changeDateIntoString:date];
            [timeBtn setTitle:self.missionEndTime forState:UIControlStateNormal];
            break;
        }
        case 5:
        {
            [self.pickerView setHidden:YES];
            break;
        }
        default:
            break;
    }
}

-(void) resetFilter{
    [timeBtn setTitle:@"全部" forState:UIControlStateNormal];
    self.missionEndTime = @"全部";
    distanceTextField.text = @"1000.0";
    self.missionDistance = 1000.0;
    [objectBtn setTitle:@"全部" forState:UIControlStateNormal];
    self.missionGroup = @"全部";
    [bonusBtn setTitle:@"全部" forState:UIControlStateNormal];
    self.missionBonus = @"全部";
    [typeBtn setTitle:@"全部" forState:UIControlStateNormal];
    self.missionType = @"全部";
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

-(void) openTypeView:(NSMutableArray *)array{
    FilterTypeTVC *typeVC = [[FilterTypeTVC alloc] initWithNibName:@"FilterTypeTVC" bundle:nil];
    self.passFilterValuesDelegate = typeVC;
    [self.passFilterValuesDelegate passTypeValues:array choiceString:self.missionType];
    [self.navigationController pushViewController:typeVC animated:YES];
}

-(void) openGroupView:(NSMutableArray *)array{
    FilterGroupTVC *groupVC = [[FilterGroupTVC alloc] initWithNibName:@"FilterGroupTVC" bundle:nil];
    self.passFilterValuesDelegate = groupVC;
    [self.passFilterValuesDelegate passGroupValues:array choiceString:self.missionGroup];
    [self.navigationController pushViewController:groupVC animated:YES];
}

-(void) saveFilter{
    //保存
    [self.view endEditing:YES];
    self.missionDistance = [distanceTextField.text doubleValue];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.missionGroup forKey:@"missionGroup"];
    [userDefaults setDouble:self.missionDistance forKey:@"missionDistance"];
    [userDefaults setObject:[self formatBonus:self.missionBonus] forKey:@"missionBonus"];
    [userDefaults setObject:self.missionType forKey:@"missionType"];
    [userDefaults setObject:self.missionEndTime forKey:@"missionEndTime"];
    [userDefaults synchronize];
    
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController switchToMainTabViewFromHomeView];
}

-(NSString *)formatBonus:(NSString *)bonus{
    if([bonus isEqualToString:@"全部"]){
        return bonus;
    }
    return [bonus substringToIndex:1];
}



@end
