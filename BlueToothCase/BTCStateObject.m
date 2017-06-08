//
//  BTCStateObject.m
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/4/26.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import "BTCStateObject.h"
@implementation BTCBDCoordinate
@end

@implementation BTCStateObject
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"bdcoordinate": [BTCBDCoordinate class]};
}
@end
