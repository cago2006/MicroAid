//
//  ViewGroupViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/17.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewGroupViewController : UIViewController<UIAlertViewDelegate>{
    __weak IBOutlet UILabel *groupNameLabel;
    __weak IBOutlet UILabel *creatorLabel;
    __weak IBOutlet UILabel *groupMembersLabel;
    __weak IBOutlet UILabel *createTimeLabel;
}

-(IBAction) joinGroup:(UIButton *)sender;
-(IBAction) exitGroup:(UIButton *)sender;
@property (nonatomic, assign) NSString *groupName;
@property (nonatomic, assign) NSString *groupCreator;
@property (nonatomic, assign) NSInteger groupMembers;
@property (nonatomic, assign) NSString *groupCreateTime;
@property (nonatomic, assign) NSString *groupCreatorNickName;
@property (nonatomic, assign) NSInteger groupID;

@end
