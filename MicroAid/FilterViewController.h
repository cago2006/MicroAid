//
//  FilterViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/15.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
@protocol PassFilterValuesDelegate

-(void) passBonusValues:(NSString *)string; //传递bonus信息
-(void) passTypeValues:(NSMutableArray *)array choiceString:(NSString *)string; //传递type信息
-(void) passGroupValues:(NSMutableArray *)array choiceString:(NSString *)string; //传递群组信息

@end

#import <UIKit/UIKit.h>
#import "FilterBonusTVC.h"
#import "FilterTypeTVC.h"
#import "FilterGroupTVC.h"

@interface FilterViewController : UIViewController<ReturnFilterBonusDelegate,ReturnFilterTypeDelegate,ReturnFilterGroupDelegate>{
    __weak IBOutlet UIButton *timeBtn;
    __weak IBOutlet UIButton *typeBtn;
    __weak IBOutlet UIButton *objectBtn;
    __weak IBOutlet UIButton *bonusBtn;
    __weak IBOutlet UITextField *distanceTextField;
}

-(IBAction) buttonClicked:(UIButton *)sender;

@property (retain, nonatomic) IBOutlet UIView *pickerView;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (retain, nonatomic) id <PassFilterValuesDelegate> passFilterValuesDelegate;

@property (retain, nonatomic) NSString *missionBonus;
@property (retain, nonatomic) NSString *missionGroup;
@property (retain, nonatomic) NSString *missionType;
@property (retain, nonatomic) NSString *missionEndTime;
@property (assign, nonatomic) double missionDistance;

@end
