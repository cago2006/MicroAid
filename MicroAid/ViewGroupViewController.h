//
//  ViewGroupViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/17.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewGroupViewController : UIViewController<UITableViewDelegate,UIAlertViewDelegate>{

}

@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupCreator;
@property (nonatomic, assign) NSInteger groupMembers;
@property (nonatomic, strong) NSString *groupCreateTime;
@property (nonatomic, strong) NSString *groupCreatorNickName;
@property (nonatomic, assign) NSInteger groupID;

@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
//加入群组的人（每次从服务器获取)
@property(nonatomic,strong) NSArray *userInfoArray;

@end
