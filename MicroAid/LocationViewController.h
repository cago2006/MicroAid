//
//  LocationViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/2.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
@protocol ReturnLocationDelegate

-(void) passChoiceLocationValues:(NSString *)string latitude:(double)latitude longitude:(double)longitude;

@end

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
#import "CreateMissionViewController.h"

@interface LocationViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UISearchBarDelegate,PassMultiValuesDelegate>{
    
    IBOutlet BMKMapView* _mapView;
    BMKGeoCodeSearch* _geocodesearch;
    __weak IBOutlet UISearchBar *_searchBar;
}

@property (retain,nonatomic) id <ReturnLocationDelegate> returnLocationDelegate;

//当前经度
@property (nonatomic, assign) double missionLongitude;
//当前纬度
@property (nonatomic, assign) double missionLatitude;
//当前位置
@property (nonatomic, retain) NSString *missionLocation;

@property (nonatomic, assign) bool isView;

@end
