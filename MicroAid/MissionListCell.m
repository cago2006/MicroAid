//
//  MissionListCell.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/7.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "MissionListCell.h"

@implementation MissionListCell

@synthesize distance,title,group;

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

-(void)dealloc{
    [title release];
    [distance release];
    [group release];
    [super dealloc];
}


@end
