//
//  NotificationListCell.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/28.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationListCell : UITableViewCell{
    IBOutlet UILabel *title;
    IBOutlet UILabel *taskName;
    IBOutlet UILabel *taskGroup;
    IBOutlet UILabel *time;
}
@property (retain,nonatomic) UILabel *title;
@property (retain,nonatomic) UILabel *taskName;
@property (retain,nonatomic) UILabel *taskGroup;
@property (retain,nonatomic) UILabel *time;

@end
