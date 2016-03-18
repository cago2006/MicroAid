//
//  ViewTagViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
#import "HomeViewController.h"
#import "FreeBarrierInfo.h"

@interface ViewTagViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>{
    __weak IBOutlet UITextView *descriptTextView;
    __weak IBOutlet UILabel *typeLabel;
    __weak IBOutlet UILabel *locationLabel;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *timeLebel;
    __weak IBOutlet UILabel *phoneLebel;
    __weak IBOutlet UITextView *remarkTextView;
    __weak IBOutlet UIButton *rectifyBtn;
    
    IBOutlet BMKMapView* _mapView;
    BMKGeoCodeSearch* _geocodesearch;
}

@property (nonatomic,assign) NSInteger tagID;
@property (nonatomic,retain) NSDictionary *resultDic;
@property (nonatomic,retain) FreeBarrierInfo *info;
-(IBAction)rectifyBtnClicked:(UIButton *)sender;


@property (nonatomic, assign) double tagLongitude;
//当前纬度
@property (nonatomic, assign) double tagLatitude;
//当前位置
@property (nonatomic, retain) NSString *tagLocation;
//用于存放当前位置的地址
@property(nonatomic,strong) BMKPointAnnotation *locationPointAnnotation;

//附近任务数组
@property(nonatomic,strong) NSMutableArray *freeBarrierInfoArray;
@property (nonatomic, strong) UITableViewController *searchController;
//用于存放搜索到的pointAnnotation数组(任务数组)
@property(nonatomic,strong) BMKMapView *searchedPointAnnotations;

@property (nonatomic, assign) ReverseGeoCodeType reverseGeoCodeType;

@end
