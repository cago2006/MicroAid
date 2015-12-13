//
//  ViewMissionViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/23.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewMissionViewController : UIViewController<UIAlertViewDelegate>{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *startTimeLabel;
    __weak IBOutlet UILabel *endTimeLabel;
    __weak IBOutlet UILabel *typeLabel;
    __weak IBOutlet UILabel *groupLabel;
    __weak IBOutlet UILabel *bonusLabel;
    __weak IBOutlet UILabel *addressLabel;
    __weak IBOutlet UILabel *statusLabel;
    __weak IBOutlet UITextView *desTextView;
    __weak IBOutlet UIButton *fromView;
    __weak IBOutlet UIButton *toView;
    __weak IBOutlet UILabel *toNickNameView;
    __weak IBOutlet UILabel *fromNickNameView;
}

@property (nonatomic, assign) bool isAccepted;
@property (assign, nonatomic) double missionDistance;
@property (strong, nonatomic) NSString *missionAddress;
@property (assign, nonatomic) double missionLatitude;
@property (assign, nonatomic) double missionLongitude;
@property (assign, nonatomic) NSInteger missionID;
@property (assign, nonatomic) NSInteger fromID;
@property (assign, nonatomic) NSInteger toID;
@property (assign, nonatomic) bool isSelf;//用于判断是否显示“据您xxx米”
-(IBAction)fromBtnClicked:(UIButton *)sender;
-(IBAction)toBtnClicked:(UIButton *)sender;
-(IBAction)addressBtnClicked:(UIButton *)sender;

@end
