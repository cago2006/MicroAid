//
//  MyInfoCell.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/18.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "MyInfoCell.h"

@implementation MyInfoCell
@synthesize portrait,userName,nickName;

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
//    [portrait release];
//    [userName release];
//    [nickName release];
//    [super dealloc];
}

@end
