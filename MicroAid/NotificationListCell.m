//
//  NotificationListCell.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/28.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "NotificationListCell.h"

@implementation NotificationListCell

@synthesize taskGroup,taskName,time,statusView;

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
    //[title release];
//    [statusView release];
//    [taskGroup release];
//    [taskName release];
//    [time release];
//    [super dealloc];
}

@end
