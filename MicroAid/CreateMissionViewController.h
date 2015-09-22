//
//  CreateMissionViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/30.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

@protocol PassMultiValuesDelegate

-(void) passBonusValues:(NSString *)string; //传递bonus信息
-(void) passTypeValues:(NSMutableArray *)array choiceString:(NSString *)string; //传递type信息
-(void) passGroupValues:(NSMutableArray *)array choiceString:(NSString *)string; //传递群组信息
-(void) passLocationValues:(NSString *)location latitude:(double)latitude longitude:(double)longitude;//传递地址信息

@end



#import <UIKit/UIKit.h>
#import "BonusTableViewController.h"
#import "TypeTableViewController.h"
#import "GroupTableViewController.h"
#import "LocationViewController.h"
#import "Mission.h"


@interface CreateMissionViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate,ReturnBonusDelegate,ReturnTypeDelegate,ReturnGroupDelegate,ReturnLocationDelegate>{
    __weak IBOutlet UIButton *startTimeBtn;
    __weak IBOutlet UIButton *endTimeBtn;
    __weak IBOutlet UIButton *typeBtn;
    __weak IBOutlet UIButton *objectBtn;
    __weak IBOutlet UIButton *bonusBtn;
    __weak IBOutlet UIButton *addressBtn;
    __weak IBOutlet UITextField *titleTextField;
    __weak IBOutlet UITextView *descriptionTextView;
}

-(IBAction) buttonClicked:(UIButton *)sender;
//@property(nonatomic,strong) IBOutlet UITextView *descriptionView;

@property (retain, nonatomic) IBOutlet UIView *pickerView;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) Mission *mission;
@property (retain, nonatomic) id <PassMultiValuesDelegate> passMultiValuesDelegate;
@property (retain, nonatomic) NSString *bonusString;
@property (retain, nonatomic) NSString *typeString;
@property (retain, nonatomic) NSString *groupString;
@property (assign, nonatomic) double missionLongitude;

@property (assign, nonatomic) double missionLatitude;
@property (retain, nonatomic) NSString *locationString;

@end
