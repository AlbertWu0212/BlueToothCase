//
//  BTCPeripheralViewController.h
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/4/12.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BabyBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTCPeripheralViewController : UIViewController
@property (nonatomic, strong) BabyBluetooth *baby;
@property (nonatomic, strong) CBPeripheral *currentPeripheral;
@end
