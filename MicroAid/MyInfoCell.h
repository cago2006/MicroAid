//
//  MyInfoCell.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/18.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyInfoCell : UITableViewCell{
    IBOutlet UIImageView *portrait;
    IBOutlet UILabel *userName;
    IBOutlet UILabel *nickName;
}
@property (retain,nonatomic) UIImageView *portrait;
@property (retain,nonatomic) UILabel *userName;
@property (retain,nonatomic) UILabel *nickName;

@end
