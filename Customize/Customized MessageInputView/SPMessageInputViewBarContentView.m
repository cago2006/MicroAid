//
//  SPMessageInputViewBarContentView.m
//  testFreeOpenIM
//
//  Created by Jai Chen on 15/12/15.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "SPMessageInputViewBarContentView.h"

@implementation SPMessageInputViewBarContentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {

    self.textView.scrollsToTop = NO;

    self.textView.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.cornerRadius = 4.0;
}

#pragma mark - UIView overrides
- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.textView setNeedsDisplay];
}

@end
