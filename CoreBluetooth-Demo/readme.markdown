CoreBluetooth Demo
------------------

This a blocks-delegation code wrapper for CoreBluetooth framework. It simplifies the way you connect with Low-Energy devices. This framework is available on iOS5 an higher OS versions.

Instance the simpleton object and set UIDs from your LE devices, you can set characteristics from a device (or several devices). Also you must set an UIDs array to perform data savings.


On hardware response block, you will be notified about divide status (connected/disconnect/fail to connect).

<pre>

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

</pre>

Delegate methods:

<pre>

- (void)peripheralDidWriteChracteristic:(CBCharacteristic *)characteristic 
                         withPeripheral:(CBPeripheral *)peripheral 
                              withError:(NSError *)error;

- (void)peripheralDidReadChracteristic:(CBCharacteristic *)characteristic 
                        withPeripheral:(CBPeripheral *)peripheral 
                             withError:(NSError *)error;

- (void)hardwareDidNotifyBehaviourOnCharacteristic:(CBCharacteristic *)characteristic
                                    withPeripheral:(CBPeripheral *)peripheral
                                             error:(NSError *)error;

</pre>

These delegate methods retrieve the result from write/read/notify a value from one or more devices.