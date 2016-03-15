//
//  DescriptTableViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptTableViewController : UITableViewController

@property(nonatomic, retain) NSString *hasFacilities;
@property(nonatomic, retain) NSString *allFacilities;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end
