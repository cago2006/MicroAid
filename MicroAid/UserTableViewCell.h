//
//  UserTableViewCell.h
//  MicroAid
//
//  Created by jiahuaxu on 15/12/3.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell{
    IBOutlet UILabel *textLabel;
    IBOutlet UIImageView *creatorTag;
}

@property (retain,nonatomic) UILabel *textLabel;
@property (retain,nonatomic) UIImageView *creatorTag;

@end
