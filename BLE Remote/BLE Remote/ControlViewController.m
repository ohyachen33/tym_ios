//
//  ControlViewController.m
//  BLE Remote
//
//  Created by Lam Yick Hong on 9/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "ControlViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ControlViewController ()

@property (strong, nonatomic) TABluetoothLowEnergyCentral *bleCentral;
@property (strong, nonatomic) TASystemService *systemService;
@property (strong, nonatomic) TADigitalSignalProcessingService *dspService;
@property (strong, nonatomic) NSMutableArray *discoveredPeripherals;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;

@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UILabel *lblBattery;
@property (strong, nonatomic) IBOutlet UILabel *lblVersion;

@property BOOL connected;

@end

@implementation ControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    self.bleCentral = [[TABluetoothLowEnergyCentral alloc] initWithDelegate:self serviceInfo:nil scanMode:TABluetoothLowEnergyCentralScanModeManual connectMode:TABluetoothLowEnergyCentralConnectModeManual]; //Use auto mode for both scan and connect, to make it easy and simple
    
    self.systemService = [[TASystemService alloc] initWithProtocol:self.bleCentral delegate:self];
    //self.dspService = [[TADigitalSignalProcessingService alloc] initWithProtocol:self.bleCentral];
    
    self.connected = NO;
    
    self.discoveredPeripherals = [[NSMutableArray alloc] init];
}

- (IBAction)onPlayButtonTapped:(id)sender
{
    //NSData* input = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    
    //[self.bleCentral writeData:input forCharacteristic:TABluetoothLowEnergyCharacteristicTypePlayControl device:[self.discoveredPeripherals objectAtIndex:0]];
}

- (IBAction)onPauseButtonTapped:(id)sender
{
    //NSData* input = [@"0" dataUsingEncoding:NSUTF8StringEncoding];
    
    //[self.bleCentral writeData:input forCharacteristic:TABluetoothLowEnergyCharacteristicTypePlayControl device:[self.discoveredPeripherals objectAtIndex:0]];
}

- (IBAction)onUpButtonTapped:(id)sender
{
    //NSData* input = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    
    [//self.bleCentral writeData:input forCharacteristic:TABluetoothLowEnergyCharacteristicTypeVolumeControl device:[self.discoveredPeripherals objectAtIndex:0]];
}

- (IBAction)onDownButtonTapped:(id)sender
{
    //NSData* input = [@"-1" dataUsingEncoding:NSUTF8StringEncoding];
    
    //[self.bleCentral writeData:input forCharacteristic:TABluetoothLowEnergyCharacteristicTypeVolumeControl device:[self.discoveredPeripherals objectAtIndex:0]];
}

- (void)startControl:(CBPeripheral*)device
{
    /*[self.systemService system:device softwareVersion:^(NSString* version){
        self.lblVersion.text = [NSString stringWithFormat:@"Software Version: %@", version];
    }];
    
    [self.systemService system:device batteryLevel:^(NSString* batteryLevel){
        
        float level = [batteryLevel floatValue];
        NSString* string = [NSString stringWithFormat:@"%f%%", level * 100.0];
        
        NSLog(@"Battery: %@", string);
        
        self.lblBattery.text = [NSString stringWithFormat:@"Battery Level: %@", string];
    }];
    
    [self.systemService startMonitorBatteryStatusOfSystem:device];*/
}


#pragma mark - TABluetoothLowEnergyCentralDelegate

- (void) bluetoothLowEnergyCentralDidConnectToDevice:(CBPeripheral *)device
{
    
}

- (void)bluetoothLowEnergyCentralDidDiscoverDevice:(CBPeripheral *)device RSSI:(NSNumber *)RSSI
{
    NSLog(@" Discovered device: %@ at %ld", device.name, (long)[RSSI integerValue]);
    [self.discoveredPeripherals addObject:device];
    
    self.lblStatus.text = [NSString stringWithFormat:@"Discovered %@", device.name];
}

- (void)bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:(TABluetoothLowEnergyCharacteristic *)characteristic error:(NSError *)error
{
    }

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    NSLog(@"Did write");
}

- (void) bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:(TABluetoothLowEnergyCharacteristic *)characteristic error:(NSError *)error{
    
    /*if(characteristic.type == TABluetoothLowEnergyCharacteristicTypeBatteryStatus){
        
        NSString* string = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        if([string length] > 0)
        {
            float level = [string floatValue];
            string = [NSString stringWithFormat:@"%f%%", level * 100.0];
            
            NSLog(@"Battery: %@", string);
            
            self.lblBattery.text = [NSString stringWithFormat:@"Battery Level: %@", string];
            
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
    }*/
    
}


- (void)bluetoothLowEnergyCentralDidConnectDevice:(CBPeripheral *)device didDiscoverCharacteristicsForService:(NSArray *)characteristics
{
    //TODO: signal connected
    self.lblStatus.text = [NSString stringWithFormat:@"Connected to %@", device.name];
    
    self.connected = YES;
    
    [self startControl:device];
}

- (void)bluetoothLowEnergyCentralDidFailToConnectDevice:(CBPeripheral *)device error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", device, [error localizedDescription]);
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Failed to Connect" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
    self.lblStatus.text = [NSString stringWithFormat:@"Connection failed to %@", device.name];
}

- (void) bluetoothLowEnergyCentralDidUpdateState: (TABluetoothLowEnergyCentralState)state
{
    NSLog(@"bluetoothLowEnergyCentralDidUpdateState: %ld", state);
    
    if(state == TABluetoothLowEnergyCentralStatePowerOn)
    {
        if([self.discoveredPeripherals count] == 0){
         
            [self.bleCentral startScan];
            
            self.lblStatus.text = @"Scanning...";
        }
    }
}

- (void) bluetoothLowEnergyCentralDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.lblStatus.text = [NSString stringWithFormat:@"Disconnected from %@", peripheral.name];
    self.lblVersion.text = [NSString stringWithFormat:@"Software Version: %@", @"N/A"];
    self.lblBattery.text = [NSString stringWithFormat:@"Battery Level: %@", @"N/A"];
    self.connected = NO;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
