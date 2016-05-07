//
//  AUUCentralManagerViewController.m
//  BLEHandler
//
//  Created by 胡金友 on 16/5/2.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "AUUCentralManagerViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface AUUCentralManagerViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (retain, nonatomic) CBCentralManager *centralManager;     // 中央设备管理中心

@property (retain, nonatomic) CBPeripheral *destPeripheral;         // 记录用来测试的外设

@property (retain, nonatomic) CBCharacteristic *destCharacteristic; // 记录用来发送测试数据的特征

@property (retain, nonatomic) NSMutableDictionary *cachedPeripherals;   // 持久化所有的外设

@end

@implementation AUUCentralManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cachedPeripherals = [[NSMutableDictionary alloc] init];
    
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)sendTestData
{
    [super sendTestData];
    
    [self.destPeripheral writeValue:[self.testData dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.destCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - Central Manger delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [self addLog:@"蓝牙状态正常，已经开始扫描了"];
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kTestServiceUUIDString]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(NO)}];
    }
    else
    {
        [self logWithState:central.state];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self.cachedPeripherals setObject:peripheral forKey:[peripheral.identifier UUIDString]];
    [self.centralManager connectPeripheral:peripheral options:nil];
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self addLog:@"已经成功连接到设备 : %@", [peripheral.identifier UUIDString]];
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self addLog:@"连接失败 %@", [peripheral.identifier UUIDString]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self addLog:@"失去连接： %@", [peripheral.identifier UUIDString]];
    
    if (self.destPeripheral)
    {
        if ([[self.destPeripheral.identifier UUIDString] isEqualToString:[peripheral.identifier UUIDString]])
        {
            [self addLog:@"测试设备断开连接了，正在紧急重连，请稍后在进行测试"];
            self.buttonEnable = NO;
            
            [self.centralManager connectPeripheral:self.destPeripheral options:nil];
        }
    }
}

#pragma mark - Peripheral Manager delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if ([self logWithError:error]) { return; }
    
    for (CBService *service in peripheral.services)
    {
        if ([[service.UUID UUIDString] isEqualToString:kTestServiceUUIDString])
        {
            if (!self.destPeripheral)
            {
                self.destPeripheral = peripheral;
            }
            
            [self addLog:@"发现目标设备，可以发送测试数据了"];
            
            self.buttonEnable = YES;
        }
        
        [self addLog:@"发现服务：%@", [service.UUID UUIDString]];
        
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([self logWithError:error]) { return; }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        [self addLog:@"发现特征：%@", [characteristic.UUID UUIDString]];
        
        if ([[characteristic.UUID UUIDString] isEqualToString:kTestCharacteristicUUIDString])
        {
            self.destCharacteristic = characteristic;
        }
        
        if (characteristic.properties & CBCharacteristicPropertyRead)
        {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        if (characteristic.properties & CBCharacteristicPropertyNotify)
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        if (characteristic.properties & CBCharacteristicPropertyWrite)
        {
            [peripheral writeValue:[@"写给你的数据" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self logWithError:error]) { return; }
    
    [peripheral readValueForCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self logWithError:error]) { return; }
    
    [self addLog:@"读取到特征<%@>的数据：%@", [characteristic.UUID UUIDString], [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]];
}

@end
