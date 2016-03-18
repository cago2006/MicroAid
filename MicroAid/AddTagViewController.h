//
//  AddTagViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagLocationViewController.h"

@interface AddTagViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>{
    __weak IBOutlet UIButton *descriptBtn;
    __weak IBOutlet UIButton *locationBtn;
    __weak IBOutlet UIButton *typeBtn;
    __weak IBOutlet UITextView *descripTextView;
    __weak IBOutlet UITextView *supplementTextView;
    __weak IBOutlet UITextField *titleField;
    __weak IBOutlet UITextField *phoneField;
}
@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (retain, nonatomic) NSString *descriptString;
@property (retain, nonatomic) NSString *supplementString;
@property (retain, nonatomic) NSString *locationString;
@property (retain, nonatomic) NSString *typeString;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) BOOL isEdit;
@property (nonatomic,retain) NSDictionary *resultDic;

-(IBAction) locationBtnClicked:(UIButton *)sender;
-(IBAction) descripBtnClicked:(UIButton *)sender;
-(IBAction) typeBtnClicked:(UIButton *)sender;

@end
