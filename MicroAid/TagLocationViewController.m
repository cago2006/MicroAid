//
//  TagLocationViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/2.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "TagLocationViewController.h"
#import "AddTagViewController.h"
#import "MicroAidAPI.h"
#import "FreeBarrierInfo.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@interface TagLocationViewController (){
    bool isGeoSearch;
    bool isSuccess;
    BMKPointAnnotation* pointAnnotation;
}

@end

@implementation TagLocationViewController

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
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,500,40,40)];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(returnToCreate) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
  
    _searchedPointAnnotations = [[BMKMapView alloc]init];
    
    _locationPointAnnotation = [[BMKPointAnnotation alloc] init];
    
    _searchBar.text = self.tagLocation;
    //开始定位
    isGeoSearch = false;
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.tagLatitude, self.tagLongitude};
        
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
    [self.navigationItem setTitle:@"任务定位"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geocodesearch.delegate = nil; // 不用时，置nil
    _mapView = nil;
    _geocodesearch = nil;
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
        
        AddTagViewController *addTagVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        addTagVC.locationString = self.tagLocation;
        addTagVC.latitude = self.tagLatitude;
        addTagVC.longitude = self.tagLongitude;
        [self.navigationController popToViewController:addTagVC animated:YES];
    }else{
        [ProgressHUD showError:@"请搜索成功后再保存!"];
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
        
        annotationView.image = [UIImage imageNamed:@"free_barrier_info.png"];   //把大头针换成别的图片
    }
    
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
//    annotationView.canShowCallout = TRUE;
//    [annotationView setSelected:YES animated:YES];
//    ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    CLLocationCoordinate2D viewLocation =[annotation coordinate];
    
    
    if (viewLocation.longitude == self.tagLongitude && viewLocation.latitude == self.tagLatitude) {//代表自己的位置
        annotationView.draggable = NO;
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
        _mapView.centerCoordinate = (CLLocationCoordinate2D){_tagLatitude, _tagLongitude};
        [annotationView setSelected:YES animated:YES];
        
        //自动搜索附近无障碍设施////////
        [self searchNearbyBarrierFree:2000 longitude:self.tagLongitude latitude:self.tagLatitude pageNo:1 pageSize:9999];
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
        isSuccess = YES;
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        
        self.tagLocation = result.address;
        self.tagLatitude = result.location.latitude;
        self.tagLongitude = result.location.longitude;
        
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
        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.tagLatitude, self.tagLongitude};
        item.coordinate = pt;
        item.title = result.address;
        _searchBar.text = result.address;
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = pt;
        
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


-(void)searchNearbyBarrierFree:(double)distance longitude:(double)longitude latitude:(double)latitude pageNo:(NSInteger)pageNo pageSize:(NSInteger)pageSize{
    
    _reverseGeoCodeType = SearchTagReverseGeoCode;
    //删除已经搜索到的标签
    NSArray* array = [NSArray arrayWithArray:_searchedPointAnnotations.annotations];
    [_searchedPointAnnotations removeAnnotations:array];
    [_mapView removeAnnotations:array];
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *nearbyFreeBarriers = [MicroAidAPI getFreeBarrierByDistance:distance longitude:longitude latitude:latitude pageNo:pageNo pageSize:pageSize];
        //NSDictionary *nearbyBarrierFrees = [ShareBarrierFreeAPIS SearchNearbyBarrierFree:110.9 latitude:23.89];
        
        if ([[nearbyFreeBarriers objectForKey:@"result"] isEqualToString:@"fail"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            _freeBarrierInfoArray = [FreeBarrierInfo getFreeBarrierInfos:[nearbyFreeBarriers objectForKey:@"barrierFree"]];
            for(int i = 0; i< _freeBarrierInfoArray.count;i++){
                    FreeBarrierInfo *temp = [_freeBarrierInfoArray objectAtIndex:i];
                    if(temp.latitude==self.tagLatitude && temp.longitude== self.tagLongitude && [temp.location isEqualToString:self.tagLocation] && [temp.title isEqualToString:self.tagTitle]){
                        [_freeBarrierInfoArray removeObjectAtIndex:i];
                    }
            }
            if ([_freeBarrierInfoArray count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMessage:@"附近没有无障碍设施"];
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
        
        NSUInteger len = [_freeBarrierInfoArray count];
        for (int i=0; i<len; i++) {
            FreeBarrierInfo *info = [_freeBarrierInfoArray objectAtIndex:i];
            CLLocationCoordinate2D coor;
            coor.latitude = info.latitude;
            coor.longitude = info.longitude;
            [self addPointAnnotation:coor title:info.title];
        }
        _mapView.centerCoordinate = (CLLocationCoordinate2D){_tagLatitude, _tagLongitude};
    }
}

//添加标注
- (void)addPointAnnotation:(CLLocationCoordinate2D)coordinate title:(NSString*)title
{
    pointAnnotation = [[BMKPointAnnotation alloc]init];
    
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.title = title;
    
    if(_tagLongitude != coordinate.longitude || _tagLatitude != coordinate.latitude){
        [_searchedPointAnnotations addAnnotation:pointAnnotation];
    }else{
        [_mapView removeAnnotation:_locationPointAnnotation];
        _locationPointAnnotation = pointAnnotation;
    }
    
    [_mapView addAnnotation:pointAnnotation];
    [_mapView setNeedsDisplay];
    NSLog(@"addPointAnnotation");
}

-(void)showMessage:(NSString *)message
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    showview.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - LabelSize.width - 20)/2, [[UIScreen mainScreen] bounds].size.height - 100, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:1.5 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}



@end
