//
//  MissionListCell.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/7.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MissionListCell : UITableViewCell{
    IBOutlet UILabel *title;
    IBOutlet UILabel *distance;
    IBOutlet UILabel *group;
}
@property (retain,nonatomic) UILabel *title;
@property (retain,nonatomic) UILabel *distance;
@property (retain,nonatomic) UILabel *group;


@end
