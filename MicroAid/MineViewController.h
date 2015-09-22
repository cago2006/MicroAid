//
//  MineViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/29.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineViewController : UIViewController<UITableViewDelegate>{
}

@property (nonatomic, assign) NSString *userName;
@property (nonatomic, assign) NSString *nickName;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIImage *imageView;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;


@end
