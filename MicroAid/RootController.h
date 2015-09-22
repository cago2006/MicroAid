//
//  RootController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RootController : UIViewController


-(void) switchToHomeViewFromLoginView;  //从login界面到homeview界面

-(void) switchToLoginViewFromHomeView;  //从homeview到login界面

-(void) switchToMainTabViewFromHomeView;  //从homeview到主界面

-(void) switchToLoginViewFromMainTab;  //从主界面到login界面

-(void) switchToHomeViewFromMainTab;  //从驻界面到homeview界面

@end
