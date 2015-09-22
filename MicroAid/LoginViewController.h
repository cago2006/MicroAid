//
//  LoginViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/26.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController{
    __weak IBOutlet UITextField *usernameTextField;
    __weak IBOutlet UITextField *passwordTextField;
}

-(IBAction) loginButtonClicked:(id)sender;
-(IBAction) registerUser:(UIButton *)sender;

@end
