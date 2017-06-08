//
//  BTCMapViewController.m
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/5/3.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import "BTCMapViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface BTCMapViewController ()<BMKMapViewDelegate, BMKGeoCodeSearchDelegate> {
    BMKMapManager *_manager;
    BMKMapView *_mapView;
    BMKGeoCodeSearch *_geocodeSearch;
}
@property (nonatomic, strong) BTCStateObject *object;
@end

@implementation BTCMapViewController

- (id)initWithObject:(BTCStateObject *)object {
    if (self = [super init]) {
        _object = object;
//        if (_object.longitude.length == 0 || _object.latitude.length == 0 ) {
//            _object.latitude = @"31.242380286725";
//            _object.longitude = @"121.37418940456";
//        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"地图"];
    // Do any additional setup after loading the view.
        BMKMapView *view = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    view.zoomLevel = 20;
//    view.mapType = BMKMapTypeSatellite;
//    view.logoPosition = BMKLogoPositionLeftTop;
//    [view setTrafficEnabled:YES];
    self.view = view;
    _mapView = view;
    
    
    _geocodeSearch = [[BMKGeoCodeSearch alloc] init];
    BTCBDCoordinate *coordinate = [self.object.bdcoordinate firstObject];
    NSLog(@"坐标:%f: %f", coordinate.x, coordinate.y);
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){coordinate.y, coordinate.x};
    BMKReverseGeoCodeOption *reverse = [[BMKReverseGeoCodeOption alloc] init];
    reverse.reverseGeoPoint = pt;
    BOOL flag = [_geocodeSearch reverseGeoCode:reverse];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

- (void)setObject:(BTCStateObject *)object {
    _object = object;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _mapView.delegate = self;
    _geocodeSearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geocodeSearch.delegate = nil; // 不用时，置nil
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
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;
        NSString* titleStr;
        NSString* showmeg;
        titleStr = @"反向地理编码";
        showmeg = [NSString stringWithFormat:@"%@",item.title];
    }
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    NSString *AnnotationViewID = @"annotationViewID";
    //根据指定标识查找一个可被复用的标注View，一般在delegate中使用，用此函数来代替新申请一个View
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    annotationView.canShowCallout = YES;
    return annotationView;

}
@end
