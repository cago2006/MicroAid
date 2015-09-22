//
//  MyInfoViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/18.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyInfoViewController : UIViewController<UIAlertViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate>{
    __weak IBOutlet UIButton *nickNameBtn;
    __weak IBOutlet UIButton *genderBtn;
    __weak IBOutlet UIButton *emailBtn;
    __weak IBOutlet UIButton *addressBtn;
    __weak IBOutlet UIButton *scoreBtn;
    __weak IBOutlet UIButton *photoBtn;
}
-(IBAction) modeInfo:(UIButton *)sender;
-(IBAction) choosePhoto:(UIButton *)sender;
@property(nonatomic,strong) NSString *nickName;
@property(nonatomic,strong) UIImage *portait;
@property(nonatomic,strong) NSString *gender;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *address;
@property(nonatomic,assign) NSInteger score;

@end
