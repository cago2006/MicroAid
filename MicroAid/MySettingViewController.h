//
//  MySettingViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/12/3.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySettingViewController : UIViewController{
    __weak IBOutlet UIButton *typeBtn;
    __weak IBOutlet UIButton *objectBtn;
    __weak IBOutlet UIButton *bonusBtn;
    __weak IBOutlet UITextField *recIntervalField;
    __weak IBOutlet UILabel *typeLabel;
    __weak IBOutlet UILabel *objectLabel;
    __weak IBOutlet UILabel *bonusLabel;
    __weak IBOutlet UILabel *recIntervalLabel;
    __weak IBOutlet UILabel *secondLabel;
    __weak IBOutlet UIButton *languageBtn;
    __weak IBOutlet UILabel *languageLabel;
}

-(IBAction) buttonClicked:(UIButton *)sender;

@property (retain, nonatomic) NSString *missionBonus;
@property (retain, nonatomic) NSString *missionGroup;
@property (retain, nonatomic) NSString *missionType;
@property (assign, nonatomic) NSInteger recInterval;

@end
