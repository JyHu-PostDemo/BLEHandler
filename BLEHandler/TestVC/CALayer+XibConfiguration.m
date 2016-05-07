//
//  CALayer+XibConfiguration.m
//  BLEHandler
//
//  Created by 胡金友 on 16/5/2.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer (XibConfiguration)

- (void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

- (UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
