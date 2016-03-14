//
//  LoginViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/26.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate>{
    __weak IBOutlet UITextField *usernameTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UIButton *checkBoxBtn;
    __weak IBOutlet UIButton *policyBtn;
    __weak IBOutlet UITextView *detailTextView;
    __weak IBOutlet UIButton *closePolicyBtn;
}

-(IBAction) loginButtonClicked:(id)sender;
-(IBAction) registerUser:(UIButton *)sender;
-(IBAction) forgetPassword:(UIButton *)sender;
-(IBAction) check:(UIButton *)sender;
-(IBAction) readPolicy:(UIButton *)sender;
-(IBAction) closePolicy:(UIButton *)sender;
-(IBAction) agreePolicy:(UIButton *)sender;
@property(nonatomic, assign) BOOL isAgree;
@property (strong, nonatomic) IBOutlet UIView *policyView;
@property (strong, nonatomic) IBOutlet UIView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *icView;
@property (strong, nonatomic) IBOutlet UIView *itemView;

@end
