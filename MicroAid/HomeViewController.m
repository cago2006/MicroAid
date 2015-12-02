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
#import "ViewMissionViewController.h"
#import "CreateMissionViewController.h"
#import "SearchTableViewController.h"

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
        //self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:@"任务分布"];
    
    UIButton *logoutBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [logoutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(returnToLogin) forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn setBackgroundImage:[UIImage imageNamed:@"logout.png"] forState:UIControlStateNormal];
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc]initWithCustomView:logoutBtn];
    //[logoutBtn release];
    
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(createMission) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithCustomView:addBtn];
    //[addBtn release];
    
    UIButton *listBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [listBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [listBtn addTarget:self action:@selector(returnToMainTab) forControlEvents:UIControlEventTouchUpInside];
    [listBtn setBackgroundImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    UIBarButtonItem *listItem = [[UIBarButtonItem alloc]initWithCustomView:listBtn];
    //[listBtn release];
    
    NSArray *itemArray=[[NSArray alloc]initWithObjects:logoutItem,addItem,listItem, nil];
    //[logoutItem release];
    //[addItem release];
    //[listItem release];
    [self.navigationItem setRightBarButtonItems:itemArray];

    
    
    _searchedPointAnnotations =[[BMKMapView alloc] init];
    
    _locationPointAnnotation = [[BMKPointAnnotation alloc] init];
    
    _locService = [[BMKLocationService alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    [_mapView setZoomLevel:16];
    
    
    //_searchController = [[SearchTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _searchController = [[SearchTableViewController alloc]initWithStyle:UITableViewStylePlain superView:self];
    NSInteger width = self.mySearchBar.frame.size.width;
    [_searchController.view setFrame:CGRectMake(30, 36, width-40, 0)];
    [self.view addSubview:_searchController.view];
}

-(void) passItemValue:(NSString *)values{
    self.mySearchBar.text = values;
    [self setSearchControllerHidden:YES];
    [self.mySearchBar endEditing:YES];

    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _searchString = [userDefaults objectForKey:@"localCity"];
    NSRange range = [self.mySearchBar.text rangeOfString:@"市"];
    if(range.location != NSNotFound){
        _searchString = self.mySearchBar.text;
    }else{
        _searchString = [NSString stringWithFormat:@"%@%@",_searchString,self.mySearchBar.text];
    }
    NSLog(@"searching");
    //搜索
    [self beginGeocode:@"" andAddress:_searchString];
    
    //保存到偏好中
    self.location = self.mySearchBar.text;
    
    [userDefaults setObject:self.location forKey:@"location"];
    [userDefaults synchronize];
    
    
    //将搜索过的地址保存
    [self saveRecord:self.mySearchBar.text];
    [self.searchController.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [self startLocation];
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时，置nil
}

- (void)dealloc {

    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
    //[super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.searchController = nil;
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
    for(NSString* key in [dictionary allKeys]){
        [userDefaults removeObjectForKey:key];
        [userDefaults synchronize];
    }
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController switchToLoginViewFromHomeView];
}

-(void)returnToMainTab{
    
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController switchToMainTabViewFromHomeView];
}

-(void)createMission{
    self.view.userInteractionEnabled = false;
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    CreateMissionViewController *createMissionVC = [[CreateMissionViewController alloc] initWithNibName:@"CreateMissionViewController" bundle:nil];
    createMissionVC.isEditMission = NO;
    createMissionVC.isFromHomeView = YES;
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


/**
 *点中地图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    [self.view endEditing:YES];
}

#pragma mark BMMapGeoSearch


/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    CLLocationCoordinate2D viewLocation =[view.annotation coordinate];
    NSUInteger len = [self.missionInfoArray count];
    for (int i=0; i<len; i++) {
        
        MissionInfo *info = [self.missionInfoArray objectAtIndex:i];
        //NSLog(@"%f=%f,%f=%f",info.latitude, viewLocation.latitude, info.longtitude, viewLocation.longitude);
        if (info.latitude == viewLocation.latitude && info.longitude == viewLocation.longitude && [info.title isEqualToString:view.annotation.title]) {
            [self switchToTagDetailVC:info];
            break;
        }
    }
}


-(void) switchToTagDetailVC:(MissionInfo *)info{
    [ProgressHUD show:@"正在获取详细信息"];
    self.view.userInteractionEnabled = false;
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    if(info.userId == userID){
        CreateMissionViewController *cmVC = [[CreateMissionViewController alloc]initWithNibName:@"CreateMissionViewController" bundle:nil];
        
        self.tabBarController.tabBar.hidden = YES;
        cmVC.isEditMission = YES;
        cmVC.missionID = info.missionId;
        [self.navigationController pushViewController:cmVC animated:YES];
    }else{
        ViewMissionViewController *viewMissionVC =[[ViewMissionViewController alloc]initWithNibName:@"ViewMissionViewController" bundle:nil];
        if(([info.statusInfo isEqualToString:@"未接受"] || [info.statusInfo isEqualToString:@"未认领"])){
            viewMissionVC.isAccepted = NO;
        }else{
            viewMissionVC.isAccepted = YES;
        }
        viewMissionVC.missionID = info.missionId;
        viewMissionVC.missionDistance = info.distance;
        self.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:viewMissionVC animated:YES];
    }
}



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
        
        annotationView.image = [UIImage imageNamed:@"sun.png"];   //把大头针换成别的图片
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
//        double distance = [userDefaults doubleForKey:@"missionDistance"];
//        if(distance < 0.1){
//            distance = 1000;
//        }
        double latitude = [userDefaults doubleForKey:@"latitude"];
        double longitude = [userDefaults doubleForKey:@"longitude"];
//        NSString *endTime = [userDefaults objectForKey:@"missionEndTime"];
//        NSString *group = [userDefaults objectForKey:@"missionGroup"];
//        NSString *bonus = [userDefaults objectForKey:@"missionBonus"];
//        NSString *type = [userDefaults objectForKey:@"missionType"];
//        if(endTime==nil || [endTime isEqualToString:@""]){
//            endTime = @"全部";
//        }
//        if(group==nil || [group isEqualToString:@""]){
//            group = @"全部";
//        }
//        if(bonus==nil || [bonus isEqualToString:@""]){
//            bonus = @"全部";
//        }
//        if(type==nil || [type isEqualToString:@""]){
//            type = @"全部";
//        }
//        NSLog(@"distance:%f",distance);
        
        [self searchNearby:statusArray distance:999999999 type:@"全部" group:@"全部" bonus:@"全部" longitude:longitude latitude:latitude endTime:@"全部"];
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
    }else{
        [_mapView removeAnnotation:_locationPointAnnotation];
        _locationPointAnnotation = pointAnnotation;
    }
    
    [_mapView addAnnotation:pointAnnotation];
    [_mapView setNeedsDisplay];
    NSLog(@"addPointAnnotation");
}


-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        self.location = result.address;
        
        NSString *localCity = @"";
        NSRange range = [self.location rangeOfString:@"市"];
        if(range.location != NSNotFound){
            localCity = [self.location substringToIndex:range.location+range.length];
        }
        //保存到偏好中
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.location forKey:@"location"];
        [userDefaults setObject:localCity forKey:@"localCity"];
        [userDefaults synchronize];
        
        CLLocationCoordinate2D userCurrentLocation = {self.latitude, self.longitude};
        [self addPointAnnotation:userCurrentLocation title:self.location];
    }
}


#pragma mark UISearchBarDelegate

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self setSearchControllerHidden:NO];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self setSearchControllerHidden:YES];
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searching");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _searchString = [userDefaults objectForKey:@"localCity"];
    [searchBar resignFirstResponder];
    NSLog(@"searchbar text = %@", searchBar.text);
    NSRange range = [searchBar.text rangeOfString:@"市"];
    if(range.location != NSNotFound){
        _searchString = searchBar.text;
    }else{
        _searchString = [NSString stringWithFormat:@"%@%@",_searchString,searchBar.text];
    }
    NSLog(@"searching");
    //搜索
    [self beginGeocode:@"" andAddress:_searchString];
    
    //保存到偏好中
    self.location = searchBar.text;
    
    [userDefaults setObject:self.location forKey:@"location"];
    [userDefaults synchronize];
    //将搜索过的地址保存
    [self saveRecord:searchBar.text];
    [self.searchController.tableView reloadData];
}

-(void)saveRecord:(NSString *)string{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recordArray = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:@"recordArray"]];
    BOOL isFind = NO;
    int i = 0;
    for(i = 0; i<[recordArray count]; i++){
        if([self testSameAddress:string address2:[recordArray objectAtIndex:i]]){
            isFind = YES;
            break;
        }
    }
    //如果找到，调整顺序，否则加入
    if(isFind){
        [recordArray removeObject:string];
        [recordArray insertObject:string atIndex:0];
    }else{
        [recordArray insertObject:string atIndex:0];
    }
    [userDefaults setObject:recordArray forKey:@"recordArray"];
    [userDefaults synchronize];
}

-(BOOL) testSameAddress:(NSString *)address1 address2:(NSString *)address2{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *localCity = [userDefaults objectForKey:@"localCity"];
    if([address1 isEqualToString:address2]){
        return YES;
    }
    if([address1 isEqualToString:[NSString stringWithFormat:@"%@%@",localCity,address2]]){
        return YES;
    }
    if([address2 isEqualToString:[NSString stringWithFormat:@"%@%@",localCity,address1]]){
        return YES;
    }
    return NO;
}


- (void) setSearchControllerHidden:(BOOL)hidden {
    NSInteger height = hidden ? 0: 130;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *recordArray = [userDefaults arrayForKey:@"recordArray"];
    NSInteger size = recordArray.count;
    if(height!=0){
        if(size == 0){
            height = 0;
        }else if(size == 1){
            height = 45;
        }else if(size == 2){
            height = 90;
        }
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    NSInteger width = self.mySearchBar.frame.size.width;
    
    [_searchController.view setFrame:CGRectMake(30, 36, width-40, height)];
    [UIView commitAnimations];
}



-(void)searchNearby:(NSArray *)statusList distance:(double)distance type:(NSString *)type group:(NSString *)group bonus:(NSString *)bonus longitude:(double)longitude latitude:(double)latitude endTime:(NSString *)endTime{
    _reverseGeoCodeType = SearchTagReverseGeoCode;
    //删除已经搜索到的标签
    NSArray* array = [NSArray arrayWithArray:_searchedPointAnnotations.annotations];
    [_searchedPointAnnotations removeAnnotations:array];
    [_mapView removeAnnotations:array];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *nearbyMissions = [MicroAidAPI getMissionList:statusList distance:distance type:type group:group bonus:bonus longitude:longitude latitude:latitude endTime:endTime pageNo:1 pageSize:999 userID:userID];
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
                    
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"附近无待认领任务" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
