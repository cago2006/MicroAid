//
//  SPUtil.h
//  WXOpenIMSampleDev
//
//  Created by huanglei on 15/4/12.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <WXOUIModule/YWUIFMWK.h>

/***********************************************
 ***********************************************
 ***********************************************
 
 SPUtil中包含的功能都是Demo中需要的辅助代码，在你的真实
 APP中一般都需要替换为你真实的实现!!!
 
 SPUtil中包含的功能都是Demo中需要的辅助代码，在你的真实
 APP中一般都需要替换为你真实的实现!!!

 SPUtil中包含的功能都是Demo中需要的辅助代码，在你的真实
 APP中一般都需要替换为你真实的实现!!!
 
 ***********************************************
 ***********************************************
 ***********************************************/





typedef NS_ENUM(NSInteger, SPMessageNotificationType) {
    SPMessageNotificationTypeMessage = 0,
    SPMessageNotificationTypeWarning,
    SPMessageNotificationTypeError,
    SPMessageNotificationTypeSuccess
};


@interface SPUtil : NSObject


+ (instancetype)sharedInstance;


/**
 *  显示提示信息
 */
- (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(SPMessageNotificationType)type;


/**
 *  获取用户的profile
 */
- (void)asyncGetProfileWithPerson:(YWPerson *)aPerson progress:(YWFetchProfileProgressBlock)aProgress completion:(YWFetchProfileCompletionBlock)aCompletion;

/**
 *  同步获取已缓存的用户 profile
 */
- (void)syncGetCachedProfileIfExists:(YWPerson *)person completion:(YWFetchProfileCompletionBlock)completionBlock;

/**
 *  等待提示
 */
- (void)setWaitingIndicatorShown:(BOOL)aShown withKey:(NSString *)aKey;

@end













/*****************************************************
 *  这些宏定义用以产生Demo中的联系人数据
 *****************************************************/

@interface SPUtil ()

- (void)_getPersonDisplayName:(NSString *__autoreleasing *)aName avatar:(UIImage *__autoreleasing *)aAvatar ofPerson:(YWPerson *)aPerson;

- (UIImage *)avatarForTribe:(YWTribe *)tribe;

@end

#define kSPProfileKeyPersonId   @"personId"
#define kSPProfileKeyNick       @"nick"
#define kSPProfileKeyAvatar     @"avatar"

/// 客服帐号
#define kSPEServicePersonProfiles \
@[\
@{kSPProfileKeyPersonId:@"openim官方客服", kSPProfileKeyNick:@"OpenIM官方客服", kSPProfileKeyAvatar:@"demo_customer_120"},\
]

#define kSPEServicePersonIds \
[kSPEServicePersonProfiles valueForKeyPath:kSPProfileKeyPersonId]

/// 官方小二
#define kSPWorkerPersonProfiles \
@[ \
@{kSPProfileKeyPersonId:@"百川开发者大会小秘书", kSPProfileKeyNick:@"百川开发者大会小秘书", kSPProfileKeyAvatar:@"demo_baichuan_120"},\
@{kSPProfileKeyPersonId:@"云大旺", kSPProfileKeyNick:@"云大旺", kSPProfileKeyAvatar:@"demo_yunwang_120"},\
@{kSPProfileKeyPersonId:@"云二旺", kSPProfileKeyNick:@"云二旺", kSPProfileKeyAvatar:@"demo_yunwang_120"},\
@{kSPProfileKeyPersonId:@"云三旺", kSPProfileKeyNick:@"云三旺", kSPProfileKeyAvatar:@"demo_yunwang_120"},\
@{kSPProfileKeyPersonId:@"云四旺", kSPProfileKeyNick:@"云四旺", kSPProfileKeyAvatar:@"demo_yunwang_120"},\
@{kSPProfileKeyPersonId:@"云小旺", kSPProfileKeyNick:@"云小旺", kSPProfileKeyAvatar:@"demo_yunwang_120"},\
]

#define kSPWorkerPersonIds \
[kSPWorkerPersonProfiles valueForKeyPath:kSPProfileKeyPersonId]

/// 官方试用
#define kSPTryPersonProfiles \
@[ \
@{kSPProfileKeyPersonId:@"uid1"},\
@{kSPProfileKeyPersonId:@"uid2"},\
@{kSPProfileKeyPersonId:@"uid3"},\
@{kSPProfileKeyPersonId:@"uid4"},\
@{kSPProfileKeyPersonId:@"uid5"},\
@{kSPProfileKeyPersonId:@"uid6"},\
@{kSPProfileKeyPersonId:@"uid7"},\
@{kSPProfileKeyPersonId:@"uid8"},\
@{kSPProfileKeyPersonId:@"uid9"},\
@{kSPProfileKeyPersonId:@"uid10"},\
]
#define kSPTryPersonIds \
[kSPTryPersonProfiles valueForKeyPath:kSPProfileKeyPersonId]

