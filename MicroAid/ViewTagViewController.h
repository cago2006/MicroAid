//
//  ViewTagViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewTagViewController : UIViewController{
    __weak IBOutlet UITextView *descriptTextView;
    __weak IBOutlet UILabel *typeLabel;
    __weak IBOutlet UILabel *locationLabel;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *timeLebel;
    __weak IBOutlet UITextView *remarkTextView;
    __weak IBOutlet UIButton *rectifyBtn;
}

@property (nonatomic,assign) NSInteger tagID;
@property (nonatomic,retain) NSDictionary *resultDic;
-(IBAction)rectifyBtnClicked:(UIButton *)sender;

@end
