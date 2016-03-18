//
//  TagLocationViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/2.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
#import "SearchTableViewController.h"

@interface TagLocationViewController: UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UISearchBarDelegate,passChoosedItemDelegate>{
    
    IBOutlet BMKMapView* _mapView;
    BMKGeoCodeSearch* _geocodesearch;
    __weak IBOutlet UISearchBar *_searchBar;
}

//当前经度
@property (nonatomic, assign) double tagLongitude;
//当前纬度
@property (nonatomic, assign) double tagLatitude;
//当前位置
@property (nonatomic, retain) NSString *tagLocation;
@property (nonatomic, strong) NSString *searchString;

@property (nonatomic, assign) NSString *tagTitle;

//用于存放当前位置的地址
@property(nonatomic,strong) BMKPointAnnotation *locationPointAnnotation;

//附近任务数组
@property(nonatomic,strong) NSMutableArray *freeBarrierInfoArray;
@property (nonatomic, strong) UITableViewController *searchController;
//用于存放搜索到的pointAnnotation数组(任务数组)
@property(nonatomic,strong) BMKMapView *searchedPointAnnotations;

@property (nonatomic, assign) ReverseGeoCodeType reverseGeoCodeType;

@end
