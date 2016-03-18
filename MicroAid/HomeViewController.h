//
//  HomeViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/27.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
#import <StoreKit/StoreKit.h>
#import "SearchTableViewController.h"

@interface HomeViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UISearchBarDelegate,passChoosedItemDelegate,UIAlertViewDelegate,SKStoreProductViewControllerDelegate>{
    
    IBOutlet BMKMapView* _mapView;
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _geocodesearch;
    //IBOutlet UISearchBar *mySearchBar;
}

//当前经度
@property (nonatomic, assign) double longitude;

@property (nonatomic, strong) IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, strong) UITableViewController *searchController;
@property (nonatomic, strong) NSString *searchString;

//当前纬度
@property (nonatomic, assign) double latitude;
//当前位置
@property (nonatomic, strong) NSString *location;

//附近任务数组
@property(nonatomic,strong) NSArray *missionInfoArray;

//附近任务数组
@property(nonatomic,strong) NSArray *barrierFreeInfoArray;

//用于存放搜索到的pointAnnotation数组(任务数组)
@property(nonatomic,strong) BMKMapView *searchedPointAnnotations;

//用于存放当前位置的地址
@property(nonatomic,strong) BMKPointAnnotation *locationPointAnnotation;

typedef enum {
    AddTagReverseGeoCode,
    SearchTagReverseGeoCode
}ReverseGeoCodeType;
@property (nonatomic, assign) ReverseGeoCodeType reverseGeoCodeType;

- (void) openAppStore : (NSString *)appId;


@end
