//
//  SPMessageInputViewBarContentView.h
//  testFreeOpenIM
//
//  Created by Jai Chen on 15/12/15.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPMessageInputViewBarContentView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *topSeparator;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainerView;

@end
