//
//  AppDelegate.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BMKMapManager * _mapManager;
}

@property (strong, nonatomic) UIWindow *window;


@end

