//
//  ViewTagViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import "ViewTagViewController.h"
#import "AddTagViewController.h"
#import "FreeBarrierInfo.h"
#import "MicroAidAPI.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@interface ViewTagViewController (){
    bool isGeoSearch;
    bool isSuccess;
    BMKPointAnnotation* pointAnnotation;
}

@end

@implementation ViewTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"无障碍设施信息"];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.tagLocation = self.info.title;
    self.tagLatitude = self.info.latitude;
    self.tagLongitude = self.info.longitude;
    
    rectifyBtn.layer.cornerRadius = rectifyBtn.frame.size.width/2.0;
    rectifyBtn.layer.masksToBounds = rectifyBtn.frame.size.width/2.0;
    _searchedPointAnnotations =[[BMKMapView alloc] init];
    
    [self searchNearbyBarrierFree:20000 longitude:self.info.longitude latitude:self.info.latitude pageNo:1 pageSize:9999];
//    if(_geocodesearch == nil){
//        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
//    }
//    isGeoSearch = false;
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.tagLatitude, self.tagLongitude};
//    
//    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
//    reverseGeocodeSearchOption.reverseGeoPoint = pt;
//    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
//    if(flag)
//    {
//        NSLog(@"反geo检索发送成功");
//    }
//    else
//    {
//        NSLog(@"反geo检索发送失败");
//    }
    [_mapView setZoomLevel:16];
    
    
    //[self findTag:self.info.infoID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [super viewWillAppear:animated];
    [self showInfo:self.info];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        //搜索附近的无障碍设施
//        [self searchNearbyBarrierFree:20000 longitude:self.info.longitude latitude:self.info.latitude pageNo:1 pageSize:9999];
    }
    
    return annotationView;
}



-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    /*
     NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
     [_mapView removeAnnotations:array];
     array = [NSArray arrayWithArray:_mapView.overlays];
     [_mapView removeOverlays:array];*/
    if (error == 0) {
//        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
//        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.tagLatitude, self.tagLongitude};
//        item.coordinate = pt;
//        item.title = self.tagLocation;
//        [_mapView addAnnotation:item];
//        _mapView.centerCoordinate = pt;
        [self searchNearbyBarrierFree:20000 longitude:self.info.longitude latitude:self.info.latitude pageNo:1 pageSize:9999];
    }
}


/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    //[_mapView removeAnnotation:_locationPointAnnotation];
    CLLocationCoordinate2D viewLocation =[view.annotation coordinate];
    NSUInteger len = [self.freeBarrierInfoArray count];
    for (int i=0; i<len; i++) {
        
         FreeBarrierInfo *info = [self.freeBarrierInfoArray objectAtIndex:i];
//        //NSLog(@"%f=%f,%f=%f",info.latitude, viewLocation.latitude, info.longtitude, viewLocation.longitude);
        if (info.latitude == viewLocation.latitude && info.longitude == viewLocation.longitude && [info.title isEqualToString:view.annotation.title]) {
            [self showInfo:info];
            [self searchNearbyBarrierFree:20000 longitude:self.info.longitude latitude:self.info.latitude pageNo:1 pageSize:9999];
            break;
        }
    }
}


-(IBAction)rectifyBtnClicked:(UIButton *)sender{
    AddTagViewController *modTag = [[AddTagViewController alloc]initWithNibName:@"AddTagViewController" bundle:nil];
    modTag.isEdit = YES;
    modTag.resultDic = self.resultDic;
    [self.navigationController pushViewController:modTag animated:YES];
}

-(void) findTag:(NSInteger)tagID{
//    dispatch_async(serverQueue, ^{
//        self.resultDic = [MicroAidAPI :tagID];
//        if ([[self.resultDic objectForKey:@"flg"] boolValue]) {//获取成功
//            //显示
//            [self performSelectorOnMainThread:@selector(showInfo) withObject:nil waitUntilDone:YES];
//            
//        }else if ([[self.resultDic objectForKey:@"onError"] boolValue])//获取失败
//        {
//            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"信息获取失败,请检查网络!" waitUntilDone:YES];
//            return ;
//        }
//    });
}

-(void)showInfo:(FreeBarrierInfo *)info{
    self.tagLongitude = info.longitude;
    self.tagLocation = info.title;
    self.tagLatitude = info.latitude;
    [descriptTextView setText:info.infoDescription];
    [locationLabel setText:info.location];
    [titleLabel setText:info.title];
    [phoneLebel setText:info.tel];
    [timeLebel setText:[NSString stringWithFormat:@"%@创建于%@",info.userName,info.time]];
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
//            for(int i = 0; i< _freeBarrierInfoArray.count;i++){
//                FreeBarrierInfo *temp = [_freeBarrierInfoArray objectAtIndex:i];
//                if(temp.latitude==self.tagLatitude && temp.longitude== self.tagLongitude){
//                    [_freeBarrierInfoArray removeObjectAtIndex:i];
//                }
//            }
            if ([_freeBarrierInfoArray count] == 0) {
                //                dispatch_async(dispatch_get_main_queue(), ^{
                //
                //                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"附近无待认领任务" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                //                    [alertView show];
                //                });
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

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.view endEditing:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
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
