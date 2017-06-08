//
//  BTCSwitchTableViewCell.h
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/4/14.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SwitchType) {
    SwitchTypeStatus = 0,
    SwitchTypeProtect = 1,
};

typedef void (^CellSwitchBlock)(UISwitch *theSwitch);

@interface BTCSwitchTableViewCell : UITableViewCell
@property (nonatomic, assign) SwitchType type;
- (void)configureSwitchEnabled:(BOOL)isOn;
- (void)configureSwitchMode:(BOOL)isOn;
- (void)addSwitchHandler:(CellSwitchBlock)handler;
@end
