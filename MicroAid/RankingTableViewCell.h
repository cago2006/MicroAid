//
//  RankingTableViewCell.h
//  MicroAid
//
//  Created by jiahuaxu on 15/12/5.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankingTableViewCell : UITableViewCell{
    IBOutlet UILabel *nickName;
    IBOutlet UIButton *rankNum;
    IBOutlet UILabel *score;
}

@property (retain,nonatomic) UILabel *nickName;
@property (retain,nonatomic) UILabel *score;
@property (retain,nonatomic) UIButton *rankNum;

@end
