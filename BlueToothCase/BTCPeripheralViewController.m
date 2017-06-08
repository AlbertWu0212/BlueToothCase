//
//  BTCPeripheralViewController.m
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/4/12.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import "BTCPeripheralViewController.h"
#import "SVProgressHUD.h"
#import "PureLayout.h"
#import "BTCSwitchTableViewCell.h"
#import "BTCInfoTableViewCell.h"
#import "XMNetworking.h"
#import "BTCStateObject.h"
#import "UIImage+ZBAdd.h"
#import <AVFoundation/AVFoundation.h>
#import "BTCMapViewController.h"

static NSInteger const SECTION_SWITCH = 1;

static NSInteger const ROW_SWITCH = 0;
static NSInteger const ROW_ALERT = 1;

@interface BTCPeripheralViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *servicesArray;
@property (nonatomic, strong) NSMutableDictionary *serviceDictionary;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *writableServicesArray;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) BTCStateObject *stateObject;
@end

@interface CBCharacteristic (Stringify)
- (NSString *)stringFromCharacterValue;
@end

@implementation CBCharacteristic (Stringify)
- (NSString *)stringFromCharacterValue {
    return [[NSString alloc] initWithData:self.value encoding:NSUTF8StringEncoding];
}
@end

@implementation BTCPeripheralViewController {
    BOOL isSyncByBlueTooth;
    BOOL isProtectionEnabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isSyncByBlueTooth = NO;
    // Do any additional setup after loading the view.
//    [self performSelector:@selector(loadData) withObject:nil afterDelay:2];
    [SVProgressHUD showInfoWithStatus:@"准备连接设备"];
    
    self.params = [NSMutableDictionary dictionary];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.servicesArray = [NSMutableArray array];
    self.writableServicesArray = [NSMutableArray array];
    
    self.serviceDictionary = [NSMutableDictionary dictionary];
    
    [self.baby AutoReconnect:self.currentPeripheral];
    [self babyDelegate];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
    
    
    [self setupImageView];
    // 界面
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
//    self.tableView.alpha = 0;
    [self.tableView registerClass:[BTCSwitchTableViewCell class] forCellReuseIdentifier:@"switch"];
    [self.tableView registerClass:[BTCInfoTableViewCell class] forCellReuseIdentifier:@"info"];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView];
    
    
}

- (void)showMap {
    [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
        request.api = @"app/getlaststate/";
        request.httpMethod = kXMHTTPMethodGET;
        request.parameters = @{@"device":[_params objectForKey:@"device"]};
    } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        self.stateObject = [BTCStateObject mj_objectWithKeyValues:responseObject[@"data"]];
        BTCMapViewController *vc = [[BTCMapViewController alloc] initWithObject:self.stateObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });

        NSLog(@"获取最后一条消息: %@", responseObject);
    }];

    

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.baby = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    });
}


-(void)loadData{
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    self.baby.having(self.currentPeripheral).and.channel(@"channel").then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    //    baby.connectToPeripheral(self.currPeripheral).begin();
}

- (void)timerTask {
    
    if (isSyncByBlueTooth == YES) {
        [self.currentPeripheral readRSSI];
    } else {

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)babyDelegate {
    __weak __typeof(self)weakSelf = self;
    
    [self.baby setBlockOnConnectedAtChannel:@"channel" block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
//        [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.navigationItem setTitle:@"NB-IOT 美纳途箱包"];
        weakSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"地图" style:UIBarButtonItemStylePlain target:weakSelf action:@selector(showMap)];
        isSyncByBlueTooth = YES;
        BTCInfoTableViewCell *deviceStatusCell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [deviceStatusCell setRightString:@"正常"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
                if ([[[weakSelf.serviceDictionary objectForKey:@"device id"] stringFromCharacterValue] length] != 0) {
                NSMutableString *mutableString = [[NSMutableString alloc] init];
                CBCharacteristic *switchStatus = [weakSelf.serviceDictionary objectForKey:@"switch"];
                [mutableString appendFormat:@"%@", switchStatus.value];
                
                [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
                    request.api = @"app/state/";
                    request.httpMethod = kXMHTTPMethodPOST;
                    request.parameters = @{@"device":[[weakSelf.serviceDictionary objectForKey:@"device id"] stringFromCharacterValue],
                                           @"longitude":[[weakSelf.serviceDictionary objectForKey:@"longitude"] stringFromCharacterValue],
                                           @"latitude":[[weakSelf.serviceDictionary objectForKey:@"latitude"] stringFromCharacterValue],
                                           @"latch_switch":[mutableString containsString:@"01"] ? @"true" : @"false",
                                           @"case_lost":@"false"};
                } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
                    NSLog(@"%@", responseObject);
                    NSLog(@"%@", error.localizedDescription);
                }];
            }

        });
    }];
    
    [self.baby setBlockOnDisconnectAtChannel:@"channel" block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [weakSelf.navigationItem setTitle:@"蓝牙连接已断开"];
        //声音
        
        [weakSelf.baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
            [weakSelf.baby.centralManager connectPeripheral:peripheral options:nil];
        }];

        // 蓝牙丢失连接上报一次消息
        BTCInfoTableViewCell *deviceStatusCell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        BTCSwitchTableViewCell *protectionCell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        BTCSwitchTableViewCell *switchCell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        NSMutableString *mutableString = [[NSMutableString alloc] init];
        CBCharacteristic *switchStatus = [weakSelf.serviceDictionary objectForKey:@"switch"];
        [mutableString appendFormat:@"%@", switchStatus.value];
        
        if ([[[weakSelf.serviceDictionary objectForKey:@"device id"] stringFromCharacterValue] length] == 0) {
            return;
        }
            [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
                request.api = @"app/state/";
                request.httpMethod = kXMHTTPMethodPOST;
                request.parameters = @{@"device":[[weakSelf.serviceDictionary objectForKey:@"device id"] stringFromCharacterValue],
                                       @"longitude":[[weakSelf.serviceDictionary objectForKey:@"longitude"] stringFromCharacterValue],
                                       @"latitude":[[weakSelf.serviceDictionary objectForKey:@"latitude"] stringFromCharacterValue],
                                       @"latch_switch":[mutableString containsString:@"01"] ? @"true" : @"false",
                                       @"case_lost":@"false"};
            } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
                NSLog(@"%@", responseObject);
                NSLog(@"%@", error.localizedDescription);
            }];
        [UIView animateWithDuration:0.5 animations:^{
//            weakSelf.tableView.alpha = 0.3;
//            weakSelf.tableView.userInteractionEnabled = NO;
            [SVProgressHUD showInfoWithStatus:@"蓝牙连接已经断开"];
            isSyncByBlueTooth = NO;
            
//            BTCSwitchTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
//            [cell configureSwitchEnabled:NO];
        }];
        
        // 蓝牙断开后判断布防是否开启

        if (isProtectionEnabled == YES) {
            [deviceStatusCell setRightString:@"丢失"];
            [switchCell configureSwitchMode:NO];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"warning" ofType:@"mp3"];
            NSURL *url = [NSURL fileURLWithPath:filePath];
            SystemSoundID soundID;
            //注册声音文件，并且将ID保存
            AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
            AudioServicesPlaySystemSound(soundID);
        } else {
            [deviceStatusCell setRightString:@"正常"];
            [switchCell configureSwitchMode:YES];
        }
    }];
    

    [self.baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        
    }];
    [self.baby setBlockOnReadValueForCharacteristicAtChannel:@"channel" block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@ property is:%lu",characteristics.UUID, [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding], (unsigned long)characteristics.properties);
 
        NSString *keyFromValue = [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding];
//        [weakSelf.servicesArray addObject:@{keyFromValue: characteristics}];
        if ([keyFromValue isEqualToString:@"switch"]) {
            [weakSelf.serviceDictionary setObject:characteristics forKey:@"switch"];

        }
        
        if ([keyFromValue isEqualToString:@"alert"]) {
            [weakSelf.serviceDictionary setObject:characteristics forKey:@"alert"];
        }
        
        if ([characteristics.UUID.UUIDString containsString:@"FE7A"]) {
            [weakSelf.serviceDictionary setObject:characteristics forKey:@"switch_status"];
            NSMutableString *mutableString = [[NSMutableString alloc] init];
            [mutableString appendFormat:@"%@", characteristics.value];
            BTCSwitchTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SECTION_SWITCH]];
            [cell configureSwitchMode:[mutableString containsString:@"01"]?YES:NO];
            
            [weakSelf.baby notify:peripheral characteristic:characteristics block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                [weakSelf.params setObject:[NSNumber numberWithBool:[mutableString containsString:@"01"]?YES:NO] forKey:@"latch_switch"];
            }];
        }
        
        if ([characteristics.UUID.UUIDString containsString:@"FE75"]) {
            [weakSelf.serviceDictionary setObject:characteristics forKey:@"longitude"];
            [weakSelf.baby notify:peripheral characteristic:characteristics block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSLog(@"longitude: %@", [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding]);
                BTCInfoTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1+1 inSection:0]];
                cell.rightString = [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding];
                [weakSelf.params setObject:cell.rightString forKey:@"longitude"];
            }];
        } else if ([characteristics.UUID.UUIDString containsString:@"FE77"]) {
            [weakSelf.serviceDictionary setObject:characteristics forKey:@"latitude"];
            [weakSelf.baby notify:peripheral characteristic:characteristics block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSLog(@"latitude: %@", [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding]);
                BTCInfoTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2+1 inSection:0]];
                cell.rightString = [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding];
                [weakSelf.params setObject:cell.rightString forKey:@"latitude"];
            }];
        } else if ([characteristics.UUID.UUIDString containsString:@"FE7F"]){
            [weakSelf.serviceDictionary setObject:characteristics forKey:@"device id"];
            [weakSelf.baby notify:peripheral characteristic:characteristics block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSLog(@"deviceID: %@", [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding]);
                BTCInfoTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0+1 inSection:0]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.rightString = [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding];
                    [weakSelf.params setObject:cell.rightString forKey:@"device"];

                });
                
            }];
        }

    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == SECTION_SWITCH ? 2 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_SWITCH) {
        BTCSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"switch"];
        cell.type = indexPath.row == 0 ? SwitchTypeStatus : SwitchTypeProtect;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSwitchHandler:^(UISwitch *theSwitch) {
            if (indexPath.row == ROW_SWITCH) {
                [self changeStatusOnSwitch:theSwitch atCharacteristic:[self.serviceDictionary objectForKey:@"switch"]];
            } else if (indexPath.row == ROW_ALERT){
                if (isSyncByBlueTooth == NO) {
                    [SVProgressHUD showErrorWithStatus:@"蓝牙断开的情况下无法操作"];
//                    [theSwitch setUserInteractionEnabled:NO];
                } else {
//                    [theSwitch setUserInteractionEnabled:YES];
                }
                [self changeStatusOnSwitch:theSwitch atCharacteristic:[self.serviceDictionary objectForKey:@"alert"]];
                
            }
        }];
        if (indexPath.row == 1) {
            [cell configureSwitchMode:[[NSUserDefaults standardUserDefaults] boolForKey:@"protect"]];
        }
        return cell;
    } else {
        BTCInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"info"];
        if (indexPath.row == 1) {
            cell.leftString = @"设备ID";
//            cell.rightString = self.stateObject.device;
            
        } else if (indexPath.row == 2) {
            cell.leftString = @"经度";
//            cell.rightString = [self.serviceDictionary[@"longitude"] stringFromCharacterValue];
            cell.rightString = self.stateObject.longitude;
        } else  if (indexPath.row == 3){
            cell.leftString = @"纬度";
            cell.rightString = self.stateObject.latitude;
        } else {
            cell.leftString = @"设备状态";
            cell.rightString = [self.stateObject.case_lost isEqualToString:@"1"] ? @"丢失" : @"正常";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;  
        return cell;
    }
    return nil;
}

- (void)changeStatusOnSwitch:(UISwitch *)theSwitch atCharacteristic:(CBCharacteristic *)character {
    if (isSyncByBlueTooth == YES) {
        Byte b = theSwitch.isOn != YES ? 0X00 : 0X01;
        NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
        [self.currentPeripheral writeValue:data forCharacteristic:character type:CBCharacteristicWriteWithResponse];
        
        if ([character isEqual:[self.serviceDictionary objectForKey:@"switch"]]) {
            [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
                request.api = @"app/state/";
                request.httpMethod = kXMHTTPMethodPOST;
                request.parameters = @{@"device":[[self.serviceDictionary objectForKey:@"device id"] stringFromCharacterValue],
                                       @"longitude":[[self.serviceDictionary objectForKey:@"longitude"] stringFromCharacterValue],
                                       @"latitude":[[self.serviceDictionary objectForKey:@"latitude"] stringFromCharacterValue],
                                       @"latch_switch":theSwitch.isOn ? @"true" : @"false",
                                       @"case_lost":@"false"};
            } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
                NSLog(@"%@", responseObject);
                NSLog(@"%@", error.localizedDescription);
            }];
        } else {
            //
            isProtectionEnabled = theSwitch.isOn;
            [[NSUserDefaults standardUserDefaults] setBool:theSwitch.isOn forKey:@"protect"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
    } else {
        if (isProtectionEnabled) {
            //不允许开锁
            BOOL flag = theSwitch.on;
            [SVProgressHUD showErrorWithStatus:@"布防开启，无法远程解锁"];
            [theSwitch setOn:!flag animated:YES];
            return;
        }
        if ([character isEqual:[self.serviceDictionary objectForKey:@"switch"]]) {
            NSLog(@"蓝牙断开下的箱包开关应该走云端指令");
            [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
                request.api = @"app/sendcommand/";
                request.httpMethod = kXMHTTPMethodPOST;
                request.parameters = @{@"device":[_params objectForKey:@"device"],
                                       @"latch_switch": theSwitch.isOn != YES ? @"false": @"true"};
            } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
                NSLog(@"发送指令:%@", responseObject);
                NSLog(@"发送指令失败: %@", error.localizedDescription);
            }];
        } else {
            BOOL flag = theSwitch.on;
            [SVProgressHUD showErrorWithStatus:@"蓝牙断开，无法操作"];
            [theSwitch setOn:!flag animated:YES];
            
            isProtectionEnabled = theSwitch.isOn;
            [[NSUserDefaults standardUserDefaults] setBool:theSwitch.isOn forKey:@"protect"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)setupImageView {
    self.imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Package"] wzb_imageByResizeToSize:CGSizeMake(160, 200)]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    [_imageView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_imageView autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [_imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Package"] wzb_imageByResizeToSize:CGSizeMake(160 , 200)]];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    return imageView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 200.0f;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
