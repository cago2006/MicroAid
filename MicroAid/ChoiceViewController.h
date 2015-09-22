//
//  ChoiceViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/27.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
@protocol ReturnValueDelegate

-(void) passChoiceValues:(NSString *)string;

@end

#import <UIKit/UIKit.h>
#import "RegisterViewController.h"

@interface ChoiceViewController : UITableViewController <PassValueDelegate>{
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (retain,nonatomic) id <ReturnValueDelegate> returnValueDelegate;

@end
