//
//  UIImage+ZBAdd.m
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/5/5.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import "UIImage+ZBAdd.h"

@implementation UIImage (ZBAdd)
- (UIImage *)wzb_imageByResizeToSize:(CGSize)size {
    if (size.width <= 0 || size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
