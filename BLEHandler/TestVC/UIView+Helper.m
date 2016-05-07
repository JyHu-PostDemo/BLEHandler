//
//  UIView+Helper.m
//  BLEHandler
//
//  Created by 胡金友 on 16/5/2.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "UIView+Helper.h"

@implementation UIView (Helper)

- (void)roundCornerWithCornerRadius:(CGFloat)cr
{
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor greenColor].CGColor;
    self.layer.cornerRadius = cr;
}

@end
