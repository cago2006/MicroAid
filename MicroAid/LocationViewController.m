//
//  LocationViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/2.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "LocationViewController.h"


@interface LocationViewController (){
    bool isGeoSearch;
}

@end

@implementation LocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,500,40,40)];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(returnToCreate) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationItem setTitle:@"任务定位"];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
 
    NSLog(@"load");
    [_mapView setZoomLevel:14];
}
-(void) passTypeValues:(NSMutableArray *)array choiceString:(NSString *)string{
    
}
-(void) passGroupValues:(NSMutableArray *)array choiceString:(NSString *)string{
    
}
-(void) passBonusValues:(NSString *)string{
    
}

-(void) passLocationValues:(NSString *)location latitude:(double)latitude longitude:(double)longitude{
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    self.missionLocation = location;
    self.missionLatitude = latitude;
    self.missionLongitude = longitude;
    
    //开始定位
    isGeoSearch = false;
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){latitude, longitude};
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    NSLog(@"appear");
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geocodesearch.delegate = nil; // 不用时，置nil
    
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
    [super dealloc];
}

-(void) returnToCreate{
    CreateMissionViewController *cmVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    self.returnLocationDelegate = cmVC;
    [self.returnLocationDelegate passChoiceLocationValues:self.missionLocation latitude:self.missionLatitude longitude:self.missionLongitude];
    
    
    
    [self.navigationController popToViewController:cmVC animated:YES];
}


#pragma mark BMMapGeoSearch


//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    NSString *AnnotationViewID = @"annotationViewID";
    //根据指定标识查找一个可被复用的标注View，一般在delegate中使用，用此函数来代替新申请一个View
    BMKAnnotationView *annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    annotationView.canShowCallout = TRUE;
    [annotationView setSelected:YES animated:YES];
    ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
    
    
    return annotationView;
}

-(BOOL)beginGeocode:(NSString*)cityText andAddress:(NSString*) addrText
{
    isGeoSearch = true;
    
    BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geocodeSearchOption.address = addrText;
    BOOL flag = [_geocodesearch geoCode:geocodeSearchOption];
    
    if(flag)
    {
        NSLog(@"geo检索发送成功");
        return true;
    }
    else
    {
        NSLog(@"geo检索发送失败");
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"搜索发送失败" message:@"请检查您的网络，重试" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [myAlertView show];
        return false;
    }
    
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    //移除地图上的标注
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    
    if (error == 0) {//搜索成功
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        
        self.missionLatitude = result.location.latitude;
        self.missionLongitude = result.location.longitude;
        
        //TODO 将位置周围的任务标记出来
        
        item.title = result.address;
        
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;//地图中心
        
    }else{
        [ProgressHUD showError:@"查询不到该地址"];
    }
}


-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    /*
     NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
     [_mapView removeAnnotations:array];
     array = [NSArray arrayWithArray:_mapView.overlays];
     [_mapView removeOverlays:array];*/
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;
        
    }
}


#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    
    self.missionLocation = searchBar.text;
    
    //搜索
    [self beginGeocode:@"" andAddress:searchBar.text];
    
    //保存到偏好中
    /*self.location = searchBar.text;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.location forKey:@"location"];
    [userDefaults synchronize];*/
    
}

@end
