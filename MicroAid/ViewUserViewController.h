//
//  ViewUserViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewUserViewController : UIViewController{
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *genderLabel;
    __weak IBOutlet UILabel *emailLabel;
    __weak IBOutlet UIButton *phoneBtn;
    __weak IBOutlet UIButton *bubbleBtn;
    __weak IBOutlet UIButton *photoBtn;
    __weak IBOutlet UILabel *nameLabel1;
    __weak IBOutlet UILabel *genderLabel1;
    __weak IBOutlet UILabel *emailLabel1;
}

@property(nonatomic,assign) NSInteger userID;
@property(nonatomic,strong) NSString *phoneNumber;
-(IBAction)phoneBtnClicked:(UIButton *)sender;
-(IBAction)bubbleBtnClicked:(UIButton *)sender;

@end
