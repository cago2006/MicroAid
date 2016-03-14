//
//  SPUtil.m
//  WXOpenIMSampleDev
//
//  Created by huanglei on 15/4/12.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "SPUtil.h"

#import <CommonCrypto/CommonDigest.h>

#import <WXOUIModule/YWIndicator.h>
#import "SPKitExample.h"

@interface SPUtil ()

@property (nonatomic, readonly) NSArray *arrayProfileDictionaries;

@property (nonatomic, strong) NSMutableSet *waitingIndicatorKeys;
@property (nonatomic, strong) UIControl *controlWaiting;

@property (nonatomic, strong) NSMutableDictionary *cachedPersonDisplayNames;
@property (nonatomic, strong) NSMutableDictionary *cachedPersonAvatars;

@end

@implementation SPUtil

#pragma mark - life

- (id)init
{
    self = [super init];
    
    if (self) {
        /// 初始化
        
        self.waitingIndicatorKeys = [NSMutableSet setWithCapacity:20];
        {
            self.controlWaiting = [[UIControl alloc] initWithFrame:[SPKitExample sharedInstance].rootWindow.frame];
            [self.controlWaiting setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
            [self.controlWaiting setBackgroundColor:[UIColor clearColor]];
            
            UIView *viewFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            [viewFrame setBackgroundColor:[UIColor colorWithWhite:0.f alpha:.8f]];
            [viewFrame.layer setMasksToBounds:YES];
            [viewFrame.layer setCornerRadius:3.f];
            [viewFrame setCenter:CGPointMake(self.controlWaiting.bounds.size.width/2, self.controlWaiting.bounds.size.height/2)];
            [viewFrame setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
            [self.controlWaiting addSubview:viewFrame];
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [indicator startAnimating];
            [indicator setCenter:CGPointMake(viewFrame.bounds.size.width/2, viewFrame.bounds.size.height/2)];
            [indicator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
            [viewFrame addSubview:indicator];
            
            [indicator setHidesWhenStopped:NO];

            self.cachedPersonDisplayNames = [NSMutableDictionary dictionary];
            self.cachedPersonAvatars = [NSMutableDictionary dictionary];
        }
    }
    
    return self;
}

#pragma mark - public

+ (instancetype)sharedInstance
{
    static SPUtil *sUtil = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sUtil = [[SPUtil alloc] init];
    });
    
    return sUtil;
}

- (void)showNotificationInViewController:(UIViewController *)viewController title:(NSString *)title subtitle:(NSString *)subtitle type:(SPMessageNotificationType)type
{
    /// 在这里使用了OpenIMSDK提供的默认样式显示提示信息
    /// 在您的app中，您也可以换成您app中已有的提示方式
    [YWIndicator showTopToastTitle:title content:subtitle userInfo:nil withTimeToDisplay:1.f andClickBlock:NULL];
}

/****************************************************************************
 *  获取用户的profile
 
 *  注意：这里使用了dispatch_after模拟网络延迟
 *  实际上，您需要修改为您自己获取用户profile的实现
 
 ****************************************************************************/
- (void)getProfileWithPerson:(YWPerson *)aPerson withExpire:(NSTimeInterval)expire progress:(YWProfileProgressBlock)aProgress completion:(YWProfileCompletionBlock)aCompletion
{
    [[[SPKitExample sharedInstance].ywIMKit.IMCore getContactService] getProfileForPerson:aPerson withTribe:nil expireInterval:expire withProgress:aProgress andCompletionBlock:aCompletion];
}

- (void)asyncGetProfileWithPerson:(YWPerson *)aPerson progress:(YWFetchProfileProgressBlock)aProgress completion:(YWFetchProfileCompletionBlock)aCompletion
{
#warning TODO: CHANGE TO YOUR ACTUAL Profile GETTING METHOD

    __weak __typeof(self) weakSelf = self;
    YWFetchProfileProgressBlock finalProgressBlock = ^(YWPerson *aPerson, NSString *aDisplayName, UIImage *aAvatarImage) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (aPerson.personId) {
                if (aDisplayName) {
                    weakSelf.cachedPersonDisplayNames[aPerson.personId] = aDisplayName;
                }
                if (aAvatarImage) {
                    weakSelf.cachedPersonAvatars[aPerson.personId] = aAvatarImage;
                }
            }
        });
        if (aProgress) {
            aProgress(aPerson, aDisplayName, aAvatarImage);
        }
    };

    YWFetchProfileCompletionBlock finalCompletionBlock = ^(BOOL aIsSuccess, YWPerson *aPerson, NSString *aDisplayName, UIImage *aAvatarImage) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (aPerson.personId) {
                if (aDisplayName) {
                    weakSelf.cachedPersonDisplayNames[aPerson.personId] = aDisplayName;
                }
                if (aAvatarImage) {
                    weakSelf.cachedPersonAvatars[aPerson.personId] = aAvatarImage;
                }
            }
        });
        if (aCompletion) {
            aCompletion(aIsSuccess, aPerson, aDisplayName, aAvatarImage);
        }
    };


    if (![aPerson.appKey isEqualToString:YWSDKAppKey]) {
        /// 非客服帐号，我们已经为Demo中的账号导入了Profile，因此可以直接调用SDK的接口获取Profile
        
        [self getProfileWithPerson:aPerson withExpire:60*60*24 progress:^(YWProfileItem *item) {
            finalProgressBlock(item.person, item.displayName, item.avatar);
        } completion:^(BOOL aIsSuccess, YWProfileItem *item) {
            finalCompletionBlock(aIsSuccess, item.person, item.displayName, item.avatar);
        }];
    }
    else {
        /// 客服帐号，模拟从开发者自己的服务器获取
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            /// 模拟一秒的网络延迟，从服务器获取到昵称以及头像的url
            NSString *name = nil;
            [self _getPersonDisplayName:&name avatar:NULL ofPerson:aPerson];
            if (finalProgressBlock) {
                finalProgressBlock(aPerson, name, nil); /// 这个block允许你在拿到部分profile信息时就回调给IMSDK，用于更及时的更新界面显示
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /// 再模拟一秒的网络延迟，从服务器下载到头像的image数据
                UIImage *avatar = nil;
                [self _getPersonDisplayName:NULL avatar:&avatar ofPerson:aPerson];
                
                if (finalCompletionBlock) {
                    finalCompletionBlock(YES, aPerson, name, avatar); /// 这个block用于在你拿到完整profile时调用，IMSDK内部会将此数据进行缓存，节省后面的流量开销
                }
            });
        });
    }
}

- (void)syncGetCachedProfileIfExists:(YWPerson *)person completion:(YWFetchProfileCompletionBlock)completionBlock {

    YWProfileItem *item = [[[SPKitExample sharedInstance].ywIMKit.IMCore getContactService] getProfileForPerson:person withTribe:nil];
    NSString *displayName = item.displayName;
    UIImage *avatar = item.avatar;

    if (displayName || avatar) {
        completionBlock(YES, person, displayName, avatar);
    }
    else {
        completionBlock(NO, person, nil, nil);
    }
}

- (void)setWaitingIndicatorShown:(BOOL)aShown withKey:(NSString *)aKey
{
    if (!aKey) {
        return;
    }
    
    if (aShown) {
        [self.waitingIndicatorKeys addObject:aKey];
    } else {
        [self.waitingIndicatorKeys removeObject:aKey];
    }
    
    if (self.waitingIndicatorKeys.count > 0) {
        [self.controlWaiting setFrame:[SPKitExample sharedInstance].appDelegate.window.bounds];
        [[SPKitExample sharedInstance].appDelegate.window addSubview:self.controlWaiting];
    } else {
        [self.controlWaiting removeFromSuperview];
    }
}


#pragma mark - private

@synthesize arrayProfileDictionaries = _arrayProfileDictionaries;

- (NSArray *)arrayProfileDictionaries
{
    if (_arrayProfileDictionaries == nil) {
        NSData *profileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"json"]];
        _arrayProfileDictionaries = [NSJSONSerialization JSONObjectWithData:profileData options:NSJSONReadingAllowFragments error:NULL];
    }
    
    return _arrayProfileDictionaries;
}

- (NSInteger)_profileIndexOfPerson:(YWPerson *)aPerson
{
    NSString *numberString = nil;
    @try {
        NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"[1-9]\\d*" options:NSRegularExpressionCaseInsensitive error:NULL];
        NSTextCheckingResult *lastCheck = [exp matchesInString:aPerson.personId options:0 range:NSMakeRange(0, aPerson.personId.length)].lastObject;
        numberString = [aPerson.personId substringWithRange:lastCheck.range];
    }
    @catch (NSException *exception) {
        ;
    }
    @finally {
        return numberString.integerValue % self.arrayProfileDictionaries.count;
    }
}

- (NSString *)_md5OfString:(NSString *)aOriginal
{
    const char *cStr = [aOriginal UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, (CC_LONG)(strlen(cStr)), result );
    
    return [NSString
             stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1],
             result[2], result[3],
             result[4], result[5],
             result[6], result[7],
             result[8], result[9],
             result[10], result[11],
             result[12], result[13],
             result[14], result[15]
             ];
}

- (void)_getPersonDisplayName:(NSString *__autoreleasing *)aName avatar:(UIImage *__autoreleasing *)aAvatar ofPerson:(YWPerson *)aPerson
{
    __block BOOL got = NO;
    __block NSString *name = nil;
    __block NSString *avatar = nil;
    
    if (aPerson.personId.length <= 0) {
        return;
    }
    
    do {
        /// 官方客服
        {
            [kSPEServicePersonIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([aPerson.personId isEqualToString:obj] || [aPerson.personId hasPrefix:[obj stringByAppendingString:@":"]]) {
                    name = [aPerson.personId stringByReplacingOccurrencesOfString:obj withString:kSPEServicePersonProfiles[idx][kSPProfileKeyNick]];
                    avatar = kSPEServicePersonProfiles[idx][kSPProfileKeyAvatar];
                    got = YES;
                }
            }];
        }
        
        if (got) {
            break;
        }
        
        /// 官方小二
        {
            [kSPWorkerPersonIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([aPerson.personId isEqualToString:obj]) {
                    name = kSPWorkerPersonProfiles[idx][kSPProfileKeyNick];
                    avatar = kSPWorkerPersonProfiles[idx][kSPProfileKeyAvatar];
                    got = YES;
                }
            }];
        }
        if (got) {
            break;
        }
        
        /// 其他账号
        
        @try {
            NSDictionary *dic = [self.arrayProfileDictionaries objectAtIndex:[self _profileIndexOfPerson:aPerson]];
            
            NSString *md5 = [self _md5OfString:aPerson.personId];
            /// 规则：随机hash的昵称_md5后两位_PersonId
            name = [[dic objectForKey:@"name"] stringByAppendingFormat:@"_%@_%@", [md5 substringFromIndex:md5.length - 2], aPerson.personId];
            
            avatar = dic[@"avatar"];
        }
        @catch (NSException *exception) {
            ;
        }
        @finally {
            ;
        }

        break;
        
    } while (NO);
    
    if (aName) {
        *aName = name;
    }
    
    if (aAvatar) {
        *aAvatar = [UIImage imageNamed:avatar];
    }
    
    return;
}

- (UIImage *)avatarForTribe:(YWTribe *)tribe {
    if (tribe.tribeType == YWTribeTypeMultipleChat) {
        return [UIImage imageNamed:@"demo_discussion"];
    }
    return [UIImage imageNamed:@"demo_group_120"];
}

@end
