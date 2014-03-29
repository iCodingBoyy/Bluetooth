//
//  MainViewController.m
//  BlueClient
//
//  Created by 马远征 on 14-2-27.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "MainViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const kServiceUUID = @"FC00";
static NSString * const kCharacteristicUUID = @"FC20";
static NSString * const kWrriteCharacteristicUUID = @"FC21";

@interface MainViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCharacteristic *writeCharacteristic;
}
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@end

@implementation MainViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
        {
            [self.manager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:kServiceUUID]]
                                                 options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        }
            break;
        default:
        {
            NSLog(@"Central Manager did change state");
        }
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSString *UUID = [peripheral.identifier UUIDString];
    NSString *UUID1 = CFBridgingRelease(CFUUIDCreateString(NULL, peripheral.UUID));
    NSLog(@"----发现外设----%@%@", UUID,UUID1);
    [self.manager stopScan];
    
    if (self.peripheral != peripheral)
    {
        self.peripheral = peripheral;
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"----成功连接外设----");
    [self.peripheral setDelegate:self];
    [self.peripheral discoverServices:@[ [CBUUID UUIDWithString:kServiceUUID]]];
}




- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"----连接外设失败----Error:%@",error);
    [self cleanup];
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"----didDiscoverServices----Error:%@",error);
    if (error)
    {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBService *service in aPeripheral.services)
    {
        NSLog(@"Service found with UUID: %@", service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]])
        {
            [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID],[CBUUID UUIDWithString:kWrriteCharacteristicUUID]] forService:service];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"-----外设断开连接------%@",error);
    self.peripheral = nil;
    [self cleanup];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            NSLog(@"----didDiscoverCharacteristicsForService---%@",characteristic);
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]])
            {
                [peripheral readValueForCharacteristic:characteristic];
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWrriteCharacteristicUUID]])
            {
                writeCharacteristic = characteristic;
            }
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exits if it's not the transfer characteristic
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]] )
    {
        // Notification has started
        if (characteristic.isNotifying)
        {
            NSLog(@"Notification began on %@", characteristic);
            [peripheral readValueForCharacteristic:characteristic];
        }
        else
        { // Notification has stopped
            // so disconnect from the peripheral
            NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
            [self.manager cancelPeripheralConnection:self.peripheral];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"----Value---%@",characteristic.value);
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]])
    {
//        NSData *valueData = [characteristic value];
//        Byte value[16] = {0};
//        [valueData getBytes:&value length:sizeof(value)];
//        for ( int istep1 = 0; istep1 < 16; istep1++ )
//        {
//            printf("%02x ",value[istep1]);
//            
//        }
//        printf("\n ");
//        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        if (writeCharacteristic)
        {
            Byte ACkValue[3] = {0};
            ACkValue[0] = 0xe0; ACkValue[1] = 0x00; ACkValue[2] = ACkValue[0] + ACkValue[1];
            NSData *data = [NSData dataWithBytes:&ACkValue length:sizeof(ACkValue)];
            [self.peripheral writeValue:data
                      forCharacteristic:writeCharacteristic
                                   type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"---didWriteValueForCharacteristic-----");
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWrriteCharacteristicUUID]])
    {
        NSLog(@"----value更新----");
//         [peripheral readValueForCharacteristic:characteristic];
        
//        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}


- (void)cleanup
{
    // Don't do anything if we're not connected
    if (!self.peripheral.isConnected)
    {
        return;
    }
    
    if (self.peripheral.services != nil)
    {
        for (CBService *service in self.peripheral.services)
        {
            if (service.characteristics != nil)
            {
                for (CBCharacteristic *characteristic in service.characteristics)
                {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]])
                    {
                        if (characteristic.isNotifying)
                        {
                            [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    [self.manager cancelPeripheralConnection:self.peripheral];
}
@end
