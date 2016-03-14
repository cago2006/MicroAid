//
//  SPMessageInputView.m
//  testFreeOpenIM
//
//  Created by Jai Chen on 15/12/15.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "SPMessageInputView.h"
#import "SPMessageInputViewBarContentView.h"

#import <WXOpenIMSDKFMWK/YWFMWK.h>
#import <WXOUIModule/YWUIFMWK.h>
#import <WXOUIModule/YWRecordKit.h>
#import <WXOUIModule/YWInputViewPluginEmoticonPicker.h>
#import <WXOUIModule/YWInputViewPluginTakePhoto.h>
#import <WXOUIModule/YWInputViewPluginPhotoPicker.h>
#import <WXOUIModule/YWInputViewPluginLocationPicker.h>
#import <WXOUIModule/YWConversationViewController.h>

#define MORE_PANEL_HEIGHT   216
#define MESSAGE_WORD_LIMIT  140

@interface SPMessageInputView ()<UITextViewDelegate, YWRecordKitDelegate>

@property (assign, nonatomic) CGFloat barMinimumHeight;

@property (nonatomic, weak) SPMessageInputViewBarContentView *barContentView;   // 输入栏
@property (nonatomic, weak) UIView *panelContentView;      // 点击更多按钮后弹出的面板
@property (nonatomic, weak) UIView *inputControl;          // 输入控件，可以为文本框或语音输入按钮

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) UIViewAnimationOptions animationCurveOption;

@property (nonatomic, assign) CGFloat textViewMinimumHeight;

@property (nonatomic, assign) BOOL needHideMorePanel;

// Plugins
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *plugins;
@property (nonatomic, strong) YWRecordKit *recordKit;

@property (nonatomic, weak, readonly) YWConversationViewController *conversationViewController;

@end

@implementation SPMessageInputView
@dynamic conversationViewController;

- (instancetype)init {
    if (self = [super init]) {
        SPMessageInputViewBarContentView *barContentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SPMessageInputViewBarContentView class])
                                                                                         owner:nil
                                                                                       options:nil] firstObject];
        barContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        self.frame = barContentView.frame;

        [self addSubview:barContentView];
        _barContentView = barContentView;

        _textViewMinimumHeight = _barContentView.textView.frame.size.height;
        _barMinimumHeight = barContentView.frame.size.height;
        _barMaximumHeight = 120.0f;

        _inputTextView = _barContentView.textView;

        _inputControl = _inputTextView;

        // 录音控件
        _recordKit = [[YWRecordKit alloc] initWithRecordViewFrame:_barContentView.textView.frame
                                                         delegate:self
                                                         andImkit:nil];
        _recordKit.recordView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _recordKit.recordView.translatesAutoresizingMaskIntoConstraints = YES;
        _recordKit.recordView.hidden = YES;
        [_barContentView addSubview:_recordKit.recordView];
        UIImage *recordViewBackgroundImage = [[self colorizeImage:[UIImage imageNamed:@"pub_btn_blue_nor"] color:[UIColor colorWithRed:0 green:180./255 blue:255./255 alpha:1.0]] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 6)];
        [_recordKit setRecordViewImage:recordViewBackgroundImage forState:YWRecordViewStateNormal];
        [_recordKit setRecordViewImage:recordViewBackgroundImage forState:YWRecordViewStateTouchDown];


        [_barContentView.textView addObserver:self
                                   forKeyPath:NSStringFromSelector(@selector(contentSize))
                                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                      context:nil];

        _barContentView.textView.delegate = self;

        UIView *panelContentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - MORE_PANEL_HEIGHT, CGRectGetWidth(self.frame), MORE_PANEL_HEIGHT)];
        panelContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:panelContentView];
        panelContentView.hidden = YES;
        _panelContentView = panelContentView;
    }
    return self;
}

- (void)dealloc {
    [self.barContentView.textView removeObserver:self
                                      forKeyPath:NSStringFromSelector(@selector(contentSize))
                                         context:nil];
}

- (void)setInputMode:(NSInteger)inputMode
{
    if (_inputMode != inputMode) {

        BOOL shouldUpdateMode = YES;
        BOOL shouldActiveTextView = NO;
        BOOL shouldSetPanelHidden = YES;

        if (inputMode == SPMessageInputViewInputModeNone) {
            self.inputControl = self.inputTextView;
        }
        else if (inputMode == SPMessageInputViewInputModeText) {
            self.inputControl = self.inputTextView;
            shouldActiveTextView = YES;
        }
        else if (inputMode == SPMessageInputViewInputModeVoice) {
            self.inputControl = self.recordKit.recordView;
        }
        else {
            id<YWInputViewPluginProtocol> plugin = [self pluginForInputStatus:inputMode];
            if (plugin) {
                if ([plugin isKindOfClass:[YWInputViewPluginEmoticonPicker class]]) {
                    self.inputControl = self.inputTextView;
                }

                [plugin pluginDidClicked];

                if ([plugin shouldOpenMorePanel] && [plugin pluginContentView]) {
                    shouldSetPanelHidden = NO;
                }
                else {
                    shouldUpdateMode = NO;
                }
            }
        }

        if (!shouldUpdateMode) {
            return;
        }

        _inputMode = inputMode;

        if (shouldActiveTextView) {
            [self.inputTextView becomeFirstResponder];
        }
        else {
            [self.inputTextView resignFirstResponder];
        }

        [self setPanelHidden:shouldSetPanelHidden animated:YES];

        for (NSInteger i = 0; i < self.buttons.count; i++) {
            UIButton *button = (UIButton *)self.buttons[i];
            button.selected = (button.tag == inputMode);
        }
    }
}

- (YWConversationViewController *)conversationViewController {
    if ([self.messageInputViewDelegate isKindOfClass:[YWConversationViewController class]]) {
        return (YWConversationViewController *)self.messageInputViewDelegate;
    }
    return nil;
}

- (void)setInputControl:(UIView *)inputControl {
    if (_inputControl != inputControl) {
        _inputControl.hidden = YES;
        inputControl.hidden = NO;

        _inputControl = inputControl;


        CGFloat heightOfControl;
        if ([inputControl isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)inputControl;
            heightOfControl = textView.contentSize.height;
        }
        else {
            heightOfControl = CGRectGetHeight(inputControl.frame);
        }
        CGFloat heightOfBar = [self heightOfBarThatFitsActiveInputControlHeight:heightOfControl];
        [self updateLayoutWithHeightOfBar:heightOfBar];
    }
}

#pragma mark - UIView Overrides
- (BOOL)becomeFirstResponder
{
    return [self.inputTextView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];

    self.inputMode = 0;
    return [super resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return [self.inputTextView isFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return [self.inputTextView canBecomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    return [self.inputTextView canResignFirstResponder];
}

#pragma mark - Layout
- (CGFloat)heightOfBarThatFitsActiveInputControlHeight:(CGFloat)height {
    return (height - self.textViewMinimumHeight) + self.barMinimumHeight;
}

- (void)updateLayoutWithHeightOfBar:(CGFloat)height
{
    CGFloat newHeightOfBar = (height < self.barMaximumHeight) ? height : self.barMaximumHeight;
    CGFloat oldHeightOfBar = CGRectGetHeight(self.barContentView.frame);

    if (oldHeightOfBar != newHeightOfBar) {
        CGFloat diff = newHeightOfBar - oldHeightOfBar;
        self.frame = ({
            CGRect frame = self.frame;
            frame.origin.y -= diff;
            frame.size.height += diff;
            frame;
        });

        self.barContentView.frame = ({
            CGRect barContentViewFrame = self.barContentView.frame;
            barContentViewFrame.size.height = newHeightOfBar;
            barContentViewFrame;
        });

        [self.barContentView setNeedsUpdateConstraints];
        [self.barContentView layoutIfNeeded];

        self.panelContentView.frame = CGRectMake(0, newHeightOfBar, self.frame.size.width, MORE_PANEL_HEIGHT);

        if ([self.messageInputViewDelegate respondsToSelector:@selector(messageInputView:heightOfBarDidChange:)]) {
            [self.messageInputViewDelegate messageInputView:self heightOfBarDidChange:newHeightOfBar];
        }
    }
}

- (void)updateLayoutWithHeightOfKeyboard:(CGFloat)height duration:(CGFloat)duration curveOption:(UIViewAnimationOptions)curveOption
{
    if (self.keyboardHeight != height) {
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewKeyframeAnimationOptionBeginFromCurrentState | curveOption
                         animations:^{
                             CGFloat originalHeight = self.frame.size.height;
                             self.frame = ({
                                 CGRect frame = self.frame;
                                 frame.size.height = CGRectGetHeight(self.barContentView.frame) + height;
                                 frame.origin.y -= (frame.size.height - originalHeight);
                                 frame;
                             });
                             self.keyboardHeight = height;

                             if ([self.messageInputViewDelegate respondsToSelector:@selector(messageInputView:heightOfKeyboardDidChange:)]) {
                                 [self.messageInputViewDelegate messageInputView:self heightOfKeyboardDidChange:height];
                             }
                         } completion:nil];
    }
}

- (void)setPanelHidden:(BOOL)hidden animated:(BOOL)animated {
    if (self.panelContentView.hidden == hidden) {
        return;
    }

    if (hidden == NO) {
        CGFloat duration = animated ? 0.25 : 0;
        UIViewAnimationOptions curveOption = UIViewAnimationOptionCurveEaseInOut;
        CGFloat height = MORE_PANEL_HEIGHT;
        [self updateLayoutWithHeightOfKeyboard:height duration:duration curveOption:curveOption];

        self.panelContentView.hidden = NO;
        self.needHideMorePanel = NO;
    }
    else {
        if (self.inputMode == SPMessageInputViewInputModeNone || self.inputMode == SPMessageInputViewInputModeVoice) {
            CGFloat duration = animated ? 0.25 : 0;
            UIViewAnimationOptions curveOption = UIViewAnimationOptionCurveEaseInOut;
            CGFloat height = 0;
            [self updateLayoutWithHeightOfKeyboard:height duration:duration curveOption:curveOption];
        }

        self.needHideMorePanel = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.needHideMorePanel) {
                self.panelContentView.hidden = YES;
            }
        });
    }
}

- (void)setInputTextViewHidden:(BOOL)hidden {
    if (hidden) {
        self.barContentView.topSeparator.hidden = YES;
        self.barContentView.textView.hidden = YES;

        CGFloat heightOfBar = [self heightOfBarThatFitsActiveInputControlHeight:0];
        [self updateLayoutWithHeightOfBar:heightOfBar];
    }
    else {
        self.barContentView.topSeparator.hidden = NO;
        self.barContentView.textView.hidden = NO;

        CGFloat height = self.barContentView.textView.contentSize.height;
        CGFloat heightOfBar = [self heightOfBarThatFitsActiveInputControlHeight:height];
        [self updateLayoutWithHeightOfBar:heightOfBar];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.barContentView.textView
        && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {

        if (self.inputTextView != object) {
            return;
        }

        CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        CGFloat heightOfBar = [self heightOfBarThatFitsActiveInputControlHeight:newContentSize.height];
        [self updateLayoutWithHeightOfBar:heightOfBar];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    BOOL should = YES;
    id<YWMessageInputViewDelegate> delegate = self.messageInputViewDelegate;
    if( [delegate respondsToSelector:@selector(messageInputViewShouldBeginEditing:)] ) {
        should = [delegate messageInputViewShouldBeginEditing:self];
    }

    if (should) {
        self.inputMode = SPMessageInputViewInputModeText;
    }

    return should;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    BOOL should = YES;
    id<YWMessageInputViewDelegate> delegate = self.messageInputViewDelegate;
    if( [delegate respondsToSelector:@selector(messageInputViewShouldEndEditing:)] ) {
        should = [delegate messageInputViewShouldEndEditing:self];
    }

    return should;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"])
    {
        if ([self respondsToSelector:@selector(textViewShouldReturn:)])
        {
            if (![self performSelector:@selector(textViewShouldReturn:) withObject:self])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }

    BOOL should = YES;
    id<YWMessageInputViewDelegate> delegate = self.messageInputViewDelegate;
    if( [delegate respondsToSelector:@selector(messageInputView:shouldChangeTextInRange:replacementText:)] ) {
        should = [delegate messageInputView:self shouldChangeTextInRange:range replacementText:text];
    }

    return should;
}

- (void)textViewDidChange:(UITextView *)textView {
    id<YWMessageInputViewDelegate> delegate = self.messageInputViewDelegate;
    if ([delegate respondsToSelector:@selector(messageInputViewTextDidChange:)]) {
        [delegate messageInputViewTextDidChange:self];
    }
}


- (BOOL)textViewShouldReturn:(UITextView *)expandingTextView
{
    if( [self.inputTextView hasText] )
    {
        if( [self.inputTextView.text length] <= MESSAGE_WORD_LIMIT )
        {
            [self.conversationViewController sendTextMessage:self.inputTextView.text];
            self.inputTextView.text = @"";
        }
        else
        {
            //使用换行进行分段
            NSArray * textArray = [self.inputTextView.text componentsSeparatedByString:@"\n"];
            NSString* sendString = @"";
            int sendLength = 0;

            for( NSString* tempStr in textArray )
            {
                if( tempStr == nil )
                    continue;
                //若果段内超出长度范围，使用句号进行分割，并以超出结果输出
                if( sendLength + [tempStr length] > MESSAGE_WORD_LIMIT )
                {
                    int subLength = 0;
                    NSArray * tempStrArray = [tempStr componentsSeparatedByString:@"。"];
                    for( NSString* subTempStr in tempStrArray )
                    {
                        subLength += [subTempStr length];
                        sendString = [sendString stringByAppendingString:subTempStr];

                        if( subLength != [tempStr length] )
                        {
                            sendString = [sendString stringByAppendingString:@"。"];//补充截取的字符串
                            subLength ++;
                        }

                        if( sendLength + subLength > MESSAGE_WORD_LIMIT )
                        {
                            sendLength += subLength;
                            break;
                        }
                    }
                    break;
                }
                sendLength += [tempStr length];
                sendString = [sendString stringByAppendingString:tempStr];
                if( [sendString length] != [self.inputTextView.text length] )
                {
                    sendString = [sendString stringByAppendingString:@"\n"];//补充截取的字符串
                    sendLength ++;
                }
            }
            if (sendLength <= self.inputTextView.text.length) {
                self.inputTextView.text = [self.inputTextView.text substringFromIndex:sendLength];
            }else{
                self.inputTextView.text = nil;
            }

            [self.conversationViewController sendTextMessage:sendString];
        }
    }
    return YES;
}


#pragma mark - Paste Image

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL canPerform = [super canPerformAction:action withSender:sender];
    if (!canPerform && action == @selector(paste:)) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        UIImage *image = pasteBoard.image;
        canPerform = (image != nil);
    }

    return canPerform;
}

- (void)paste:(id)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    UIImage *image = pasteBoard.image;

    [self resignFirstResponder];
    [self.conversationViewController sendImageMessage:image shouldAskUserToConfirm:YES];
}

#pragma mark - KeyBoard Notifications
- (void)registerForNotifications
{
    [self unregisterForNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardEndRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions curveOption = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;

    if (self.inputMode == SPMessageInputViewInputModeNone ||
        self.inputMode == SPMessageInputViewInputModeVoice ||
        self.inputMode == SPMessageInputViewInputModeText) {
        [self updateLayoutWithHeightOfKeyboard:keyboardEndRect.size.height duration:duration curveOption:curveOption];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.inputMode == SPMessageInputViewInputModeNone ||
        self.inputMode == SPMessageInputViewInputModeVoice ||
        self.inputMode == SPMessageInputViewInputModeText) {
        NSDictionary *userInfo = [notification userInfo];
        CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        UIViewAnimationOptions curveOption = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
        CGFloat height = 0;
        [self updateLayoutWithHeightOfKeyboard:height duration:duration curveOption:curveOption];
    }
}

#pragma mark - Utility
- (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor
{
    if (!baseImage) {
        return nil;
    }
    if (!theColor) {
        return baseImage;
    }
    UIGraphicsBeginImageContextWithOptions(baseImage.size, false, baseImage.scale);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);

    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    [theColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeDestinationIn);
    CGContextDrawImage(ctx, area, baseImage.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - IYWMessageInputView
- (NSString *)text {
    return self.inputTextView.text;
}

- (void)setText:(NSString *)text {
    self.inputTextView.text = text;
}

- (NSRange)selectedRange {
    return self.inputTextView.selectedRange;
}

- (void)setSelectedRange:(NSRange)selectedRange {
    self.inputTextView.selectedRange = selectedRange;
}

- (void)beginListeningForKeyboard {
    [self registerForNotifications];
}

- (void)endListeningForKeyboard {
    [self unregisterForNotifications];
}

@synthesize messageInputViewDelegate = _messageInputViewDelegate;

- (void)setMessageInputViewDelegate:(id<YWMessageInputViewDelegate>)messageInputViewDelegate {
    _messageInputViewDelegate = messageInputViewDelegate;

    [self configurePlugins];

    if ([messageInputViewDelegate respondsToSelector:@selector(kitRef)]) {
        id imkit = [messageInputViewDelegate performSelector:@selector(kitRef)];
        self.recordKit.imkit = imkit;
    }
}

#pragma mark - RecordKitDelegate
- (void)recordKitWillStartRecord:(YWRecordKit *)aRecordKit {
    [self.conversationViewController sendInputStatus:YWConversationRecordingStatus];
}

- (void)recordKit:(YWRecordKit *)aRecordKit didEndRecordWithData:(NSData *)aData duration:(NSTimeInterval)aDuration
{
    [self.conversationViewController sendVoiceMessage:aData andTime:aDuration];
    [self.conversationViewController sendInputStatus:YWConversationStopInputStatus];
}

- (void)recordKitDidCancel:(YWRecordKit *)aRecordKit
{
    [self.conversationViewController sendInputStatus:YWConversationStopInputStatus];
}

#pragma mark - Plugins
- (void)configurePlugins {
    NSArray *buttonImageNames = @[@"input_ico_keyb_nor",
                                  @"ios7-mic-outline",
                                  @"input_ico_face_nor",
                                  @"ios7-camera-outline",
                                  @"ios7-photos-outline",
                                  @"location"];
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:buttonImageNames.count];

    CGRect buttonFrame = CGRectMake(9, 0, 35, 35);
    for (NSInteger i = 0; i < buttonImageNames.count; i++) {
        UIImage *image = [UIImage imageNamed:buttonImageNames[i]];
        UIImage *normalImage = [self colorizeImage:image
                                             color:[UIColor grayColor]];
        UIImage *hilightedImage = [self colorizeImage:image
                                                color:[UIColor colorWithRed:0 green:180./255 blue:255./255 alpha:1.0]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:normalImage forState:UIControlStateNormal];
        [button setImage:hilightedImage forState:UIControlStateHighlighted];
        [button setImage:hilightedImage forState:UIControlStateSelected];
        button.tag = (i + 1);

        button.frame = buttonFrame;
        [_barContentView.buttonsContainerView addSubview:button];
        buttonFrame.origin.x += (35 + 5);

        [button addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
    }
    self.buttons = buttons;


    __weak YWConversationViewController *weakController = nil;
    if ([self.messageInputViewDelegate isKindOfClass:[YWConversationViewController class]]) {
        weakController = (YWConversationViewController *)self.messageInputViewDelegate;
    }

    YWInputViewPluginImageBlock imgblk = ^(id plugin, UIImage *image) {
        [weakController sendImageMessage:image];
    };

    YWInputViewPluginMultiImageSelectBlock multiImageBlk = ^(id<YWInputViewPluginProtocol> plugin, NSArray *imageDatas, BOOL sendOriginImage) {
        for (NSData *imageData in imageDatas) {
            if (!sendOriginImage) {
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [weakController sendImageMessage:image];
            } else {
                [weakController sendImageMessageData:imageData];
            }
        }
    };

    YWInputViewPluginLocationBlock lctblk = ^(id plugin, CLLocationCoordinate2D location, NSString *name) {
        YWMessageBodyLocation *messageBody = [[YWMessageBodyLocation alloc] initWithMessageLocation:location locationName:name];
        if (messageBody) {
            [weakController.conversation asyncSendMessageBody:messageBody progress:nil completion:^(NSError *error, NSString *messageID) {
                if (error) {
                    if (weakController.kitRef.showNotificationBlock) {
                        weakController.kitRef.showNotificationBlock(weakController, @"消息发送失败", error.userInfo[YWErrorUserInfoKeyDescription], YWMessageNotificationTypeError);
                    }
                }
            }];
        }
    };

    YWInputViewPluginEmoticonPickBlock emtblk = ^(id<YWInputViewPluginProtocol> plugin, YWEmoticon *emoticon, YWEmoticonType type){
        // 没有表情对应的文本则直接发送
        if( type == YWEmoticonTypeGifAnimateImage || type == YWEmoticonTypeStaticImage ) {
            if (emoticon.emoticon.length > 0) {
                // 用普通文本发送表情的文本符号
                return ;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfFile:emoticon.fileName];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakController sendImageMessageData:imageData];
                });
            });
        }
    };

    YWInputViewPluginEmoticonSendBlock emtsendblk = ^(id<YWInputViewPluginProtocol> plugin, NSString *sendText){

        // 其它表情或文字
        if (sendText.length > 0) {
            YWMessageBodyText *textMessageBody = [[YWMessageBodyText alloc] initWithMessageText:sendText];
            [weakController.conversation asyncSendMessageBody:textMessageBody progress:nil completion:^(NSError *error, NSString *messageID) {
                if (error) {
                    if (weakController.kitRef.showNotificationBlock) {
                        weakController.kitRef.showNotificationBlock(weakController, @"消息发送失败", error.userInfo[YWErrorUserInfoKeyDescription], YWMessageNotificationTypeError);
                    }
                }
            }];
        }
    };


    self.plugins = [NSMutableArray array];
    [self addPluginsObject:[[YWInputViewPluginPhotoPicker alloc] initWithMultiPickeroverBlock:multiImageBlk]];
    [self addPluginsObject:[[YWInputViewPluginTakePhoto alloc] initWithPickerOverBlock:imgblk]];
    [self addPluginsObject:[[YWInputViewPluginLocationPicker alloc] initWithPickerOverBlock:lctblk]];
    [self addPluginsObject:[[YWInputViewPluginEmoticonPicker alloc] initWithPickerOverBlock:emtblk sendBlock:emtsendblk]];
}

- (void)addPluginsObject:(id<YWInputViewPluginProtocol>)object {
    object.inputViewRef = self;
    [self.plugins addObject:object];
}

- (id<YWInputViewPluginProtocol>)pluginForInputStatus:(NSInteger)inputMode {
    NSString *pluginName = nil;
    switch (inputMode) {
        case 3:
            pluginName = @"表情";
            break;
        case 4:
            pluginName = @"拍照";
            break;
        case 5:
            pluginName = @"选择照片";
            break;
        case 6:
            pluginName = @"位置";
            break;
        default:
            break;
    }

    id<YWInputViewPluginProtocol> plugin = nil;
    if (pluginName) {
        for (id<YWInputViewPluginProtocol> aPlugin in self.plugins) {
            if ([aPlugin.pluginName isEqualToString:pluginName]) {
                plugin = aPlugin;
                break;
            }
        }
    }
    return plugin;
}

- (void)actionButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    self.inputMode = button.tag;
}

#pragma mark - YWInputViewPluginDelegate
- (void)pluginWillBeginEdit:(id<YWInputViewPluginProtocol>)plugin {
    YWConversationInputStatus status = YWConversationStopInputStatus;
    switch (plugin.pluginType) {
        case YWInputViewPluginTypeText:
            status = YWConversationInputTextStatus;
            break;
        case YWInputViewPluginTypeVoice:
            status = YWConversationRecordingStatus;
            break;
        case YWInputViewPluginTypeTakePhoto:
            status = YWConversationTakePictureStatus;
            break;
        case YWInputViewPluginTypePickImage:
            status = YWConversationSelectImageStatus;
            break;
        case YWInputViewPluginTypeDefault:
        case YWInputViewPluginTypeLocation:
        default:
            break;
    }

    if( status != YWConversationStopInputStatus) {
        [self.conversationViewController sendInputStatus:status];
    }
}

- (void)pluginDidEndEdit:(id<YWInputViewPluginProtocol>)plugin {
    [self.conversationViewController sendInputStatus:YWConversationStopInputStatus];
}

- (void)pushContentViewOfPlugin:(id<YWInputViewPluginProtocol>)plugin {
    UIView *pluginView = plugin.pluginContentView;
    if (pluginView != nil && pluginView.superview != self.panelContentView) {
        pluginView.frame = self.panelContentView.bounds;
        pluginView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        for (UIView *subview in self.panelContentView.subviews) {
            [subview removeFromSuperview];
        }
        [self.panelContentView addSubview:pluginView];
    }
}

- (void)popContentViewOfPlugin:(id<YWInputViewPluginProtocol>)plugin {
    UIView *pluginView = plugin.pluginContentView;
    if (pluginView.superview == self.panelContentView) {
        [pluginView removeFromSuperview];
    }
}

@end
