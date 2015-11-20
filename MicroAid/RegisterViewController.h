//
//  RegisterViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

@protocol PassValueDelegate

-(void) passAllChoiceValues:(NSMutableArray *)array choiceStrings:(NSString *)strings;

@end

#import <UIKit/UIKit.h>
#import "User.h"
#import "ChoiceViewController.h"

@interface RegisterViewController : UIViewController <ReturnValueDelegate>{
    __weak IBOutlet UITextField *usernameTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UITextField *passwordTextField2;
    __weak IBOutlet UITextField *nickNameTextField;
}

@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) User *user;
@property (retain, nonatomic) id <PassValueDelegate> passValueDelegate;
@property (strong, nonatomic) NSString *choiceStrings;
@property (strong, nonatomic) NSString *choiceIDStrings;
@property (strong, nonatomic) NSMutableDictionary *choiceDic;

-(IBAction) registerButtonClicked:(UIButton *)sender;
-(IBAction) choiceButtonClicked:(UIButton *)sender;
@end
