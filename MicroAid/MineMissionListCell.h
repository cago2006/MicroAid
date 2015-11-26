//
//  MineMissionListCell.h
//  MicroAid
//
//  Created by jiahuaxu on 15/11/24.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineMissionListCell : UITableViewCell{
    IBOutlet UILabel *title;
    IBOutlet UILabel *distance;
    IBOutlet UILabel *group;
    IBOutlet UIImageView *statusView;
}
@property (retain,nonatomic) UILabel *title;
@property (retain,nonatomic) UILabel *distance;
@property (retain,nonatomic) UILabel *group;
@property (retain,nonatomic) UIImageView *statusView;

@end
