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
    bool isSuccess;
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
    
    if(!self.isView){
        UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,500,70,40)];
        [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(returnToCreate) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:Localized(@"确定") forState:UIControlStateNormal];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }else{
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        _searchBar.text = self.missionLocation;
        //开始定位
        isGeoSearch = false;
        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.missionLatitude, self.missionLongitude};
        
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
    [self.navigationItem setTitle:Localized(@"任务位置")];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
 
    [_mapView setZoomLevel:16];
    
    _searchController = [[SearchTableViewController alloc]initWithStyle:UITableViewStylePlain superView:self];
    NSInteger width = _searchBar.frame.size.width;
    [_searchController.view setFrame:CGRectMake(30, 36, width-40, 0)];
    [self.view addSubview:_searchController.view];
}

-(void) passItemValue:(NSString *)values{
    _searchBar.text = values;
    [self setSearchControllerHidden:YES];
    [_searchBar endEditing:YES];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _searchString = [userDefaults objectForKey:@"localCity"];
    NSRange range = [_searchBar.text rangeOfString:@"市"];
    if(range.location != NSNotFound){
        _searchString = _searchBar.text;
    }else{
        _searchString = [NSString stringWithFormat:@"%@%@",_searchString,_searchBar.text];
    }
    NSLog(@"searching");
    //搜索
    [self beginGeocode:@"" andAddress:_searchString];
    
    
    //将搜索过的地址保存
    [self saveRecord:_searchBar.text];
    [self.searchController.tableView reloadData];
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
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geocodesearch.delegate = nil; // 不用时，置nil
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
    //[super dealloc];
}

-(void) returnToCreate{
    if(isSuccess){
        CreateMissionViewController *cmVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        self.returnLocationDelegate = cmVC;
        cmVC.isEditMission = _isParentEditMission;
        cmVC.isFromHomeView = _isParentFromHomeView;
        cmVC.isFromMyMission = _isParentFromMyMission;
        [self.returnLocationDelegate passChoiceLocationValues:self.missionLocation latitude:self.missionLatitude longitude:self.missionLongitude];
        
        [self.navigationController popToViewController:cmVC animated:YES];
    }else{
        [ProgressHUD showError:Localized(@"请搜索成功后再保存!")];
    }
    
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
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:Localized(@"搜索发送失败") message:Localized(@"请检查您的网络并重试") delegate:self cancelButtonTitle:nil otherButtonTitles:Localized(@"确定"),nil];
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
        isSuccess = YES;
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        
        self.missionLocation = result.address;
        self.missionLatitude = result.location.latitude;
        self.missionLongitude = result.location.longitude;
        
        //TODO 将位置周围的任务标记出来
        
        item.title = result.address;
        
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;//地图中心
        
    }else{
        [ProgressHUD showError:Localized(@"查询不到该地址")];
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
        _searchBar.text = result.address;
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;
        
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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _searchString = [userDefaults objectForKey:@"localCity"];
    [searchBar resignFirstResponder];
    NSRange range = [searchBar.text rangeOfString:@"市"];
    if(range.location != NSNotFound){
        _searchString = searchBar.text;
    }else{
        _searchString = [NSString stringWithFormat:@"%@%@",_searchString,searchBar.text];
    }
    //搜索
    [self beginGeocode:@"" andAddress:_searchString];

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
    NSInteger width = _searchBar.frame.size.width;
    
    [_searchController.view setFrame:CGRectMake(30, 36, width-40, height)];
    [UIView commitAnimations];
}


@end
