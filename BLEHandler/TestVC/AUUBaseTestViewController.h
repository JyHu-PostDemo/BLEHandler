//
//  AUUBaseTestViewController.h
//  BLEHandler
//
//  Created by 胡金友 on 16/5/2.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUUUUIDs.h"

@interface AUUBaseTestViewController : UIViewController

@property (retain, nonatomic, readonly) NSString *testData;

@property (retain, nonatomic) UIButton *testButton;

@property (assign, nonatomic) BOOL buttonEnable;

- (void)sendTestData;

- (void)addLog:(id)fmt, ...;

- (void)logWithInfo:(NSString *)log;

- (void)logWithState:(NSUInteger)state;

- (BOOL)logWithError:(NSError *)error;

@end
