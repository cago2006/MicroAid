//
//  SettingTypeTVC.h
//  MicroAid
//
//  Created by jiahuaxu on 15/12/3.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTypeTVC : UITableViewController

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *typeString;
@property (nonatomic, strong) NSIndexPath *choosedIndex;

@end
