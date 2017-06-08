//
//  BTCStateObject.h
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/4/26.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MJExtension.h"

@interface BTCBDCoordinate : NSObject
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat x;
@end



@interface BTCStateObject : NSObject
@property (nonatomic, copy) NSString *device;
@property (nonatomic, copy) NSString *lasttime;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *port;
@property (nonatomic, copy) NSString *case_lost;
@property (nonatomic, copy) NSString *latch_switch;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *createtime;
@property (nonatomic, strong) NSArray *bdcoordinate;
@end
