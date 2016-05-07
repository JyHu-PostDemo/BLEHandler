//
//  AUUBaseTestViewController.m
//  BLEHandler
//
//  Created by 胡金友 on 16/5/2.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUBaseTestViewController.h"
#import "UIView+Helper.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface AUUBaseTestViewController ()

@property (retain, nonatomic) UITextField *dataTextfield;

@property (retain, nonatomic) UITextView *logTextView;

@property (assign, nonatomic) NSInteger logCount;

@end

@implementation AUUBaseTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.logCount = 0;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setup];
}

- (void)setup
{
    self.dataTextfield = [[UITextField alloc] init];
    self.dataTextfield.textColor = [UIColor greenColor];
    self.dataTextfield.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dataTextfield roundCornerWithCornerRadius:5];
    [self.view addSubview:self.dataTextfield];
    
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.backgroundColor = [UIColor clearColor];
    self.logTextView.textColor = [UIColor greenColor];
    self.logTextView.editable = NO;
    self.logTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.logTextView roundCornerWithCornerRadius:0];
    [self.view addSubview:self.logTextView];
    
    self.testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.testButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.testButton roundCornerWithCornerRadius:22];
    [self.testButton setTitle:@"发送测试数据" forState:UIControlStateNormal];
    [self.testButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.testButton addTarget:self action:@selector(sendTestData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.testButton];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(_dataTextfield, _logTextView, _testButton);
    
    NSString *DHVFL = @"H:|-20-[_dataTextfield]-20-|";
    NSString *LHVFL = @"H:|-20-[_logTextView]-20-|";
    NSString *THVFL = @"H:|-20-[_testButton]-20-|";
    NSString *VVFL = @"V:|-84-[_dataTextfield(30)]-20-[_testButton(44)]-20-[_logTextView]-20-|";
    
    for (NSString *vfl in @[DHVFL, LHVFL, THVFL, VVFL])
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:NSLayoutFormatDirectionMask metrics:nil views:dict]];
    }
}

- (void)addLog:(id)fmt, ...
{
    va_list sptr;
    va_start(sptr, fmt);
    NSString *log = [[NSString alloc] initWithFormat:fmt arguments:sptr];
    va_end(sptr);
    
    [self logWithInfo:log];
}

- (void)logWithInfo:(NSString *)log
{
    self.logCount ++;
    
    self.logTextView.text = [NSString stringWithFormat:@"%zd:%@\n%@", self.logCount, log, self.logTextView.text];
}

- (void)logWithState:(NSUInteger)state
{
    switch (state) {
        case CBCentralManagerStateUnknown:
            [self logWithInfo:@"设备状态未知，请稍后再试"];
            break;
            
        case CBCentralManagerStateResetting:
            [self logWithInfo:@"设备正在重置，请稍后再试"];
            break;
            
        case CBCentralManagerStateUnsupported:
            [self logWithInfo:@"您的设备不支持蓝牙功能，请换台设备使用"];
            break;
            
        case CBCentralManagerStateUnauthorized:
            [self logWithInfo:@"您没有同意使用蓝牙的权限，如需使用，请到设置中打开"];
            break;
            
        case CBCentralManagerStatePoweredOff:
            [self logWithInfo:@"您的蓝牙已关闭，请打开后使用"];
            break;
            
        default:
            break;
    }
}

- (BOOL)logWithError:(NSError *)error
{
    if (!error)
    {
        return NO;
    }
    
    [self addLog:@"不好，出现错误了\n%@", [error userInfo]];
    
    return YES;
}

- (NSString *)testData
{
    return self.dataTextfield.text;
}

- (void)sendTestData
{
    [self.dataTextfield resignFirstResponder];
}

- (void)setButtonEnable:(BOOL)buttonEnable
{
    self.testButton.enabled = buttonEnable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
