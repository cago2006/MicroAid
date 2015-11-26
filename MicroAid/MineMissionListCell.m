//
//  MineMissionListCell.m
//  MicroAid
//
//  Created by jiahuaxu on 15/11/24.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import "MineMissionListCell.h"

@implementation MineMissionListCell

@synthesize distance,title,group,statusView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
    }
    return self;
}


@end
