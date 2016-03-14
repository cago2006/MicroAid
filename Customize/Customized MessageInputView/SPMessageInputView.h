//
//  SPMessageInputView.h
//  testFreeOpenIM
//
//  Created by Jai Chen on 15/12/15.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <WXOUIModule/IYWMessageInputView.h>
#import <WXOUIModule/YWInputViewPlugin.h>


#define SPMessageInputViewInputModeNone        0
#define SPMessageInputViewInputModeText        1
#define SPMessageInputViewInputModeVoice       2

@interface SPMessageInputView : UIView
<IYWMessageInputView,
YWInputViewPluginDelegate>

@property (nonatomic, readonly, strong) UITextView *inputTextView;

@property (nonatomic, assign) NSInteger inputMode;

/**
 *  输入栏的高度最小值
 */
@property (assign, nonatomic) CGFloat barMaximumHeight;

/**
 *  开始监听系统键盘通知
 */
- (void)registerForNotifications;

/**
 *  结束监听系统键盘通知
 */
- (void)unregisterForNotifications;

@end
