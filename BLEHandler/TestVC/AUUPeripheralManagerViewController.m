//
//  AUUPeripheralManagerViewController.m
//  BLEHandler
//
//  Created by 胡金友 on 16/5/2.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUPeripheralManagerViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface AUUPeripheralManagerViewController () <CBPeripheralManagerDelegate>

@property (retain, nonatomic) CBPeripheralManager *peripheralManager;

@property (retain, nonatomic) CBMutableCharacteristic *characteristic;

@end

@implementation AUUPeripheralManagerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)sendTestData
{
    [super sendTestData];
    
    [self write];
}

- (void)write
{
    if (self.testData && self.testData.length > 0)
    {
        [self.peripheralManager updateValue:[self.testData dataUsingEncoding:NSUTF8StringEncoding]
                          forCharacteristic:self.characteristic
                       onSubscribedCentrals:self.characteristic.subscribedCentrals];
    }
}

- (void)addMeService
{
    CBCharacteristicProperties properties = CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyWrite |
    CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead;
    CBAttributePermissions permissions =    CBAttributePermissionsReadable | CBCharacteristicPropertyWrite;
    self.characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kTestCharacteristicUUIDString]
                                                                                 properties:properties value:nil permissions:permissions];
    
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kTestServiceUUIDString] primary:YES];
    [service setCharacteristics:@[self.characteristic]];
    
    [self.peripheralManager addService:service];
}

#pragma mark - Peripheral manager delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        [self addLog:@"蓝牙状态正常，开始添加服务"];
        
        [self addMeService];
    }
    else
    {
        [self logWithState:peripheral.state];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    [self addLog:@"添加服务：%@", [service.UUID UUIDString]];
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"Service",
                                               CBAdvertisementDataServiceUUIDsKey : @[service.UUID] }];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    [self addLog:@"成功开始广播了"];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    [self addLog:@"有设备订阅了:  central:%@, characteristic:%@", [central.identifier UUIDString], [characteristic.UUID UUIDString]];
    self.buttonEnable = YES;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    self.buttonEnable = NO;
    
    [self addLog:@"有设备取消了订阅:    central:%@, characteristic: %@", [central.identifier UUIDString], [characteristic.UUID UUIDString]];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    [self write];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    for (CBATTRequest *request in requests)
    {
        [self addLog:@"收到写入到特征<%@>的数据<%@>", [request.characteristic.UUID UUIDString], [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding]];
        
        if (request.characteristic.properties & CBCharacteristicWriteWithResponse)
        {
            [self addLog:@"回复"];
            [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        }
    }
}

@end
