//
//  ConnectionTestTableViewController.m
//  BLE Remote
//
//  Created by Lam Yick Hong on 12/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "ConnectionTestTableViewController.h"

@interface ConnectionTestTableViewController ()

@property (strong, nonatomic) TABluetoothLowEnergyCentral *bleCentral;
@property (strong, nonatomic) NSMutableArray *discoveredPeripherals;
@property (strong, nonatomic) NSMutableArray *connectedPeripherals;

@property NSInteger disconnectCounter;
@property NSInteger nextIndex;

@end

@implementation ConnectionTestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.bleCentral = [[TABluetoothLowEnergyCentral alloc] initWithDelegate:self serviceInfo:nil scanMode:TABluetoothLowEnergyCentralScanModeManual connectMode:TABluetoothLowEnergyCentralConnectModeManual];

    self.discoveredPeripherals = [[NSMutableArray alloc] init];
    self.connectedPeripherals = [[NSMutableArray alloc] init];
    
    self.navigationController.toolbarHidden = NO;
    self.disconnectCounter = -1;
    self.nextIndex = -1;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for(CBPeripheral* connectedPeripheral in self.connectedPeripherals)
    {
        [self.bleCentral disconnectDevice:connectedPeripheral];
    }
    
    self.navigationController.toolbarHidden = YES;
}

- (IBAction)onAction:(id)sender
{
    if([self.connectedPeripherals count] == 0){
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No connected device" message:@"Please first connected to one or more devices" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

        [alertView show];
        
    }else{
        
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Which one you wanna action against?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        
        for(CBPeripheral* peripheral in self.connectedPeripherals)
        {
            [actionSheet addButtonWithTitle:peripheral.name];
        }
        
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (IBAction)onPlay:(id)sender
{
    [self disconnectAllPeripherals];
}

- (IBAction)onFastForward:(id)sender
{
    //write to all connected devices
    /*for(CBPeripheral* peripheral in self.connectedPeripherals)
    {
        NSData* input = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
        
        [self.bleCentral writeData:input forCharacteristic:TABluetoothLowEnergyCharacteristicTypeVolumeControl device:peripheral];
        
    }*/
    
    NSData* input = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.bleCentral writeData:input forCharacteristic:TABluetoothLowEnergyCharacteristicTypeVolumeControl];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        return;
    }
    
    NSInteger index = buttonIndex - 1;
    
    [self writeString:@"1" peripherals:self.connectedPeripherals index:index];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.discoveredPeripherals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectionTestTableCell" forIndexPath:indexPath];
    
    // Configure the cell...
    CBPeripheral* peripheral = [self.discoveredPeripherals objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", peripheral.name];
    cell.detailTextLabel.text = @"Not Connected";
    
    if([self.connectedPeripherals indexOfObject:peripheral] != NSNotFound)
    {
        cell.detailTextLabel.text = @"Connected";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral* peripheral = [self.discoveredPeripherals objectAtIndex:[indexPath row]];
    
    //check if peripheral connected
    
    BOOL isConnected = NO;
    
    for(CBPeripheral* connectedPeripheral in self.connectedPeripherals)
    {
        if([connectedPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
        {
            isConnected = YES;
            break;
        }
    }
    
    //if found as connected, try to disconnect it, connect otherwise
    if(isConnected)
    {
        [self.connectedPeripherals removeObject:peripheral];
        
        [self.bleCentral disconnectDevice:peripheral];
        
    }else{
        [self.bleCentral connectDevice:peripheral];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - TABluetoothLowEnergyCentralDelegate

- (void)bluetoothLowEnergyCentralDidDiscoverDevice:(CBPeripheral *)device RSSI:(NSNumber *)RSSI
{
    NSLog(@" Discovered device: %@ at %ld", device.name, (long)[RSSI integerValue]);
    
    BOOL exist = [self existPeripheral:device devices:self.discoveredPeripherals];
    
    if(!exist)
    {
        [self.discoveredPeripherals addObject:device];
    }
    
    [self.tableView reloadData];
}

- (void)bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:(TABluetoothLowEnergyCharacteristic *)characteristic error:(NSError *)error
{

}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    NSLog(@"Did write");
    
    /*if(self.nextIndex >= 0)
    {
        NSLog(@"testing - disconnect after written");
        [self.bleCentral disconnectDevice:peripheral];
        
        self.nextIndex++;
        
        if(self.nextIndex < [self.connectedPeripherals count])
        {
            NSLog(@"testing - connect next one");
            
            CBPeripheral* target = [self.discoveredPeripherals objectAtIndex:self.nextIndex];
            [self.bleCentral connectDevice:target];
            
        }else{
            
            NSLog(@"testing - connect next one");
            
            self.nextIndex = -1;
        }
    }*/
}

- (void) bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:(TABluetoothLowEnergyCharacteristic *)characteristic error:(NSError *)error{
    
}

- (void) bluetoothLowEnergyCentralDidConnectToDevice:(CBPeripheral *)device
{
    NSLog(@"Connected to device: %@ at %ld", device.name);
}


- (void)bluetoothLowEnergyCentralDidConnectDevice:(CBPeripheral *)device didDiscoverCharacteristicsForService:(NSArray *)characteristics
{
    BOOL exist = [self existPeripheral:device devices:self.connectedPeripherals];
    
    if(!exist)
    {
        [self.connectedPeripherals addObject:device];
    }
    
    for(int i = 0; i < [self.discoveredPeripherals count]; i++)
    {
        CBPeripheral* peripheral = [self.discoveredPeripherals objectAtIndex:i];
        
        if([peripheral.identifier.UUIDString isEqualToString:device.identifier.UUIDString])
        {
            [self.discoveredPeripherals replaceObjectAtIndex:i withObject:device];
            break;
        }
    }
    
    if(self.nextIndex >= 0)
    {
        NSData* input = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
        
        //CBPeripheral* targetDevice = [self peripheralByUUIDString:device.identifier.UUIDString devices:self.discoveredPeripherals];
        
        //CBPeripheral* targetDevice = [self.bleCentral retreivePeripheral:device.identifier.UUIDString];
        
        CBPeripheral* targetDevice = device;
        
        [self.bleCentral writeData:input forCharacteristic:TABluetoothLowEnergyCharacteristicTypeVolumeControl device:targetDevice];
        
        if(self.nextIndex >= 0)
        {
            NSLog(@"testing - disconnect after written");
            [self.bleCentral disconnectDevice:device];
            
            self.nextIndex++;
            
            if(self.nextIndex < [self.discoveredPeripherals count])
            {
                NSLog(@"testing - connect next one");
                
                CBPeripheral* target = [self.discoveredPeripherals objectAtIndex:self.nextIndex];
                [self.bleCentral connectDevice:target];
                
            }else{
                
                NSLog(@"testing - completed");
                
                self.nextIndex = -1;
            }
        }
        
    }
    
    [self.tableView reloadData];
}

- (void)bluetoothLowEnergyCentralDidFailToConnectDevice:(CBPeripheral *)device error:(NSError *)error
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Failed to connect device" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void) bluetoothLowEnergyCentralDidUpdateState: (TABluetoothLowEnergyCentralState)state
{
    if(state == TABluetoothLowEnergyCentralStatePowerOn)
    {
        if([self.discoveredPeripherals count] == 0){
            
            [self.bleCentral startScan];
        }
    }
}

- (void) bluetoothLowEnergyCentralDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    BOOL exist = [self existPeripheral:peripheral devices:self.connectedPeripherals];
    
    if(exist)
    {
        [self.connectedPeripherals removeObject:peripheral];
    }
    
    [self.tableView reloadData];
    
    if(self.disconnectCounter == 0)
    {
        NSLog(@"disconnected all");
        [self startTesting];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Helper method

- (BOOL)existPeripheral:(CBPeripheral*)device devices:(NSArray*)devices
{
    for(CBPeripheral* targetDevice in devices)
    {
        if([targetDevice.identifier.UUIDString isEqualToString:device.identifier.UUIDString])
        {
            return YES;
        }
    }
    
    return NO;
}

- (CBPeripheral*)peripheralByUUIDString:(NSString*)uuid devices:(NSArray*)devices
{
    for(CBPeripheral* targetDevice in devices)
    {
        if([targetDevice.identifier.UUIDString isEqualToString:uuid])
        {
            return targetDevice;
        }
    }
    
    return nil;
}

#pragma mark - Test Helper method

- (void)writeString:(NSString*)string peripherals:(NSArray*)peripherals index:(NSInteger)index
{
    CBPeripheral* peripheral = [peripherals objectAtIndex:index];
    
    NSData* input = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.bleCentral writeData:input forCharacteristic:TABluetoothLowEnergyCharacteristicTypeVolumeControl device:peripheral];
}

- (void)disconnectAllPeripherals
{
    self.disconnectCounter = [self.connectedPeripherals count];
    
    if(self.disconnectCounter == 0){
        //start shooting here
        [self startTesting];
    }else{
        //disconnect all first
        for(CBPeripheral* peripheral in self.connectedPeripherals)
        {
            [self.bleCentral disconnectDevice:peripheral];
        }
    }
}

- (void)startTesting
{
    NSLog(@"start testing");
    self.disconnectCounter = -1;
    
    //start connect and shooting one by one
    self.nextIndex = 0;
    
    CBPeripheral* target = [self.discoveredPeripherals objectAtIndex:0];
    [self.bleCentral connectDevice:target];
    
}

@end
