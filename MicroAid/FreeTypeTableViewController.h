//
//  FreeTypeTableViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FreeTypeTableViewController : UITableViewController

@property(nonatomic, retain) NSString *typeString;
@property(nonatomic, retain) NSString *allTypes;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSIndexPath *choosedIndex;
@end
