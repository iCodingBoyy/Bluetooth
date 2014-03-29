//
//  MainViewController.m
//  BlueServer
//
//  Created by 马远征 on 14-2-27.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "MainViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const kServiceUUID = @"1C85D7B7-17FA-4362-82CF-85DD0B76A9A5";
static NSString * const kCharacteristicUUID = @"7E887E40-95DE-40D6-9AA0-36EDE2BAE253";

@interface MainViewController () <CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *customCharacteristic;
@property (nonatomic, strong) CBMutableService *customService;
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

- (void)loadView
{
    [super loadView];
    
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
}

- (void)setupService
{
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    
    self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    
    self.customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    [self.customService setCharacteristics:@[self.customCharacteristic]];
    [self.peripheralManager addService:self.customService];
}

#pragma mark -CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state)
    {
        case CBPeripheralManagerStatePoweredOn:
        {
            [self setupService];
        }
            break;
            
        default:
        {
            NSLog(@"Peripheral Manager did change state");
        }
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error == nil)
    {
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey : @"ICServer", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServiceUUID]] }];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    
}

@end
