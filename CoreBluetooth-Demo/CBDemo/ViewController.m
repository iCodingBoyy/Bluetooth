//
//  ViewController.m
//  CBDemo
//
//  Created by Sergio on 25/01/12.
//  Copyright (c) 2012 Sergio. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BlueToothMe *instance = [BlueToothMe shared];
    [instance setDelegate:self];
    
    NSArray *characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"2A1E"], 
                                                         [CBUUID UUIDWithString:@"2A1C"],
                                                         [CBUUID UUIDWithString:@"2A21"], nil];
    
    [instance setCharacteristics:characteristics forServiceCBUUID:@"1809"];
    [instance setLetWriteDataCBUUID:[NSArray arrayWithObject:@"1809"]];
    
    characteristics = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A29"]];
                       
    [instance setCharacteristics:characteristics forServiceCBUUID:@"180A"];
    
    [instance hardwareResponse:^(CBPeripheral *peripheral, BLUETOOTH_STATUS status, NSError *error) {
        
        if (status == BLUETOOTH_STATUS_CONNECTED)
        {
            NSLog(@"connected!");
        }
        else if (status == BLUETOOTH_STATUS_FAIL_TO_CONNECT)
        {
            NSLog(@"fail to connect!");
        }
        else
        {
            NSLog(@"disconnected!");
        }
        
        NSLog(@"CBUUID: %@, ERROR: %@", (NSString *)peripheral.UUID, error.localizedDescription);
    }];
    
    [instance startScan];
}

- (void)hardwareDidNotifyBehaviourOnCharacteristic:(CBCharacteristic *)characteristic
                                    withPeripheral:(CBPeripheral *)peripheral
                                             error:(NSError *)error
{
    
}

- (void)peripheralDidWriteChracteristic:(CBCharacteristic *)characteristic 
                         withPeripheral:(CBPeripheral *)peripheral 
                              withError:(NSError *)error
{
    
}

- (void)peripheralDidReadChracteristic:(CBCharacteristic *)characteristic 
                        withPeripheral:(CBPeripheral *)peripheral 
                             withError:(NSError *)error
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
