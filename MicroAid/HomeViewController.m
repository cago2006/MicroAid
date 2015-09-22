//
//  HomeViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/27.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "HomeViewController.h"
#import "RootController.h"
#import "MicroAidAPI.h"
#import "MissionInfo.h"
#import "CreateMissionViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface HomeViewController (){
    bool isGeoSearch;
    BMKPointAnnotation* pointAnnotation;
}

@end

@implementation HomeViewController

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
    [self.navigationItem setTitle:@"任务分布"];
    
    UIButton *logoutBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [logoutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(returnToLogin) forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn setBackgroundImage:[UIImage imageNamed:@"logout.png"] forState:UIControlStateNormal];
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc]initWithCustomView:logoutBtn];
    [logoutBtn release];
    
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(createMission) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithCustomView:addBtn];
    [addBtn release];
    
    UIButton *listBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [listBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [listBtn addTarget:self action:@selector(returnToMainTab) forControlEvents:UIControlEventTouchUpInside];
    [listBtn setBackgroundImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    UIBarButtonItem *listItem = [[UIBarButtonItem alloc]initWithCustomView:listBtn];
    [listBtn release];
    
    NSArray *itemArray=[[NSArray alloc]initWithObjects:logoutItem,addItem,listItem, nil];
    [logoutItem release];
    [addItem release];
    [listItem release];
    [self.navigationItem setRightBarButtonItems:itemArray];

    
    
    _searchedPointAnnotations =[[BMKMapView alloc] init];
    
    _locService = [[BMKLocationService alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    [_mapView setZoomLevel:14];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [self startLocation];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时，置nil
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)returnToLogin{
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController switchToLoginViewFromHomeView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
    for(NSString* key in [dictionary allKeys]){
        [userDefaults removeObjectForKey:key];
        [userDefaults synchronize];
    }
}

-(void)returnToMainTab{
    
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController switchToMainTabViewFromHomeView];
}

-(void)createMission{
    CreateMissionViewController *createMissionVC = [[CreateMissionViewController alloc] initWithNibName:@"CreateMissionViewController" bundle:nil];
    
    [self.navigationController pushViewController:createMissionVC animated:YES];
}

#pragma mark BMMapLocation

-(void) startLocation{
    NSLog(@"进入跟随态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    //停止跟随
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
    
    //将定位信息保存到偏好中
    self.latitude = userLocation.location.coordinate.latitude;
    self.longitude = userLocation.location.coordinate.longitude;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:self.latitude forKey:@"latitude"];
    [userDefaults setDouble:self.longitude forKey:@"longitude"];
    [userDefaults synchronize];

    
    //TODO将位置周围的任务标记出来
    
    isGeoSearch = false;
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    
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

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
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

/**
 *点中地图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    [self.view endEditing:YES];
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
    
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    CLLocationCoordinate2D viewLocation =[annotation coordinate];
    
    NSLog(@"%f=%f,%f=%f",viewLocation.longitude, self.longitude, viewLocation.latitude, self.latitude);
    
    if (viewLocation.longitude == self.longitude && viewLocation.latitude == self.latitude) {
        //annotationView.draggable = YES;
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
        _mapView.centerCoordinate = (CLLocationCoordinate2D){_latitude, _longitude};
        [annotationView setSelected:YES animated:YES];
        
        //自动搜索附近任务////////
        NSArray *statusArray = [NSArray arrayWithObjects:@"0", nil];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        double distance = [userDefaults doubleForKey:@"missionDistance"];
        if(distance < 0.1){
            distance = 1000;
        }
        double latitude = [userDefaults doubleForKey:@"latitude"];
        double longitude = [userDefaults doubleForKey:@"longitude"];
        NSString *endTime = [userDefaults objectForKey:@"missionEndTime"];
        NSString *group = [userDefaults objectForKey:@"missionGroup"];
        NSString *bonus = [userDefaults objectForKey:@"missionBonus"];
        NSString *type = [userDefaults objectForKey:@"missionType"];
        if(endTime==nil || [endTime isEqualToString:@""]){
            endTime = @"全部";
        }
        if(group==nil || [group isEqualToString:@""]){
            group = @"全部";
        }
        if(bonus==nil || [bonus isEqualToString:@""]){
            bonus = @"全部";
        }
        if(type==nil || [type isEqualToString:@""]){
            type = @"全部";
        }
        NSLog(@"distance:%f",distance);
        
        [self searchNearby:statusArray distance:distance type:type group:group bonus:bonus longitude:longitude latitude:latitude endTime:endTime];
    }
    
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
        
        //将地理位置信息保存到偏好中
        self.latitude = result.location.latitude;
        self.longitude = result.location.longitude;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setDouble:self.latitude forKey:@"latitude"];
        [userDefaults setDouble:self.longitude forKey:@"longitude"];
        [userDefaults synchronize];
        
        //TODO 将位置周围的任务标记出来
        /*
        item.title = result.address;
        
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;//地图中心*/
        
        CLLocationCoordinate2D userCurrentLocation = {self.latitude, self.longitude};
        [self addPointAnnotation:userCurrentLocation title:result.address];
        
    }else{
        [ProgressHUD showError:@"查询不到该地址"];
    }
}

//添加标注
- (void)addPointAnnotation:(CLLocationCoordinate2D)coordinate title:(NSString*)title
{
    pointAnnotation = [[BMKPointAnnotation alloc]init];
    
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.title = title;
    
    if(_longitude != coordinate.longitude || _latitude != coordinate.latitude){
        [_searchedPointAnnotations addAnnotation:pointAnnotation];
    }
    
    [_mapView addAnnotation:pointAnnotation];
    [_mapView setNeedsDisplay];
    NSLog(@"addPointAnnotation");
}


-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        self.location = result.address;
        
        //保存到偏好中
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.location forKey:@"location"];
        [userDefaults synchronize];
        
        CLLocationCoordinate2D userCurrentLocation = {self.latitude,self.longitude};
        [self addPointAnnotation:userCurrentLocation title:self.location];
    }
}


#pragma mark UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searching");
    
    [searchBar resignFirstResponder];
    NSLog(@"searchbar text = %@", searchBar.text);
    
    NSLog(@"searching");
    //搜索
    [self beginGeocode:@"" andAddress:searchBar.text];
    
    //保存到偏好中
    self.location = searchBar.text;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.location forKey:@"location"];
    [userDefaults synchronize];
    
}



-(void)searchNearby:(NSArray *)statusList distance:(double)distance type:(NSString *)type group:(NSString *)group bonus:(NSString *)bonus longitude:(double)longitude latitude:(double)latitude endTime:(NSString *)endTime{
    _reverseGeoCodeType = SearchTagReverseGeoCode;
    //删除已经搜索到的标签
    NSArray* array = [NSArray arrayWithArray:_searchedPointAnnotations.annotations];
    [_searchedPointAnnotations removeAnnotations:array];
    [_mapView removeAnnotations:array];
    
    
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *nearbyMissions = [MicroAidAPI getMissionList:statusList distance:distance type:type group:group bonus:bonus longitude:longitude latitude:latitude endTime:endTime pageNo:1 pageSize:100];
        //NSDictionary *nearbyBarrierFrees = [ShareBarrierFreeAPIS SearchNearbyBarrierFree:110.9 latitude:23.89];
        
        if ([[nearbyMissions objectForKey:@"result"] isEqualToString:@"fail"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            _missionInfoArray = [MissionInfo getMissionInfos:[nearbyMissions objectForKey:@"taskInfoList"]];
            if ([_missionInfoArray count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"附近无待接受任务" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addPointAnnotations];
            });
        }
    });
}

#pragma mark - 添加大头针
-(void) addPointAnnotations{
    if (_reverseGeoCodeType == SearchTagReverseGeoCode) {
        
        NSUInteger len = [_missionInfoArray count];
        for (int i=0; i<len; i++) {
            MissionInfo *info = [_missionInfoArray objectAtIndex:i];
            CLLocationCoordinate2D coor;
            coor.latitude = info.latitude;
            coor.longitude = info.longitude;
            [self addPointAnnotation:coor title:info.title];
        }
        _mapView.centerCoordinate = (CLLocationCoordinate2D){_latitude, _longitude};
    }
}


@end
