//
//  DataDumpViewController.m
//  Bluetooth Tool
//
//  Created by Lam Yick Hong on 5/7/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "DataDumpViewController.h"
#import "PopTableViewController.h"
#import "DocumentUtils.h"

#define kVersionNumber @"CFBundleShortVersionString"
#define kBuildNumber @"CFBundleVersion"

@interface DataDumpViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton* btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnDevice;
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) PopTableViewController* discoverListViewController;
@property (nonatomic, strong) TAPBluetoothLowEnergyCentral* bleCentral;

@property (nonatomic, strong) NSMutableArray* discoveredSystems;
@property (nonatomic, strong) CBPeripheral* connectedDevice;

@property (nonatomic, strong) NSMutableString* buffer;
@property (nonatomic, strong) NSString* emailAdress;

@end

#define TYM_DEBUG_SERVICE_ID @"8FE6819D-D5F9-49FA-90BA-4DA05A7D2725"
//#define TYM_DEBUG_SERVICE_ID @"FE89"
#define TYM_DEBUG_CHARACTERISTIC_ID @"5E868054-3ED3-4ACD-A18A-28F812DFB14F"

@implementation DataDumpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.emailAdress = [userDefaults objectForKey:@"emailAdress"];
    self.mailTextField.text = [userDefaults objectForKey:@"emailAdress"];
    
    self.versionLabel.text = [NSString stringWithFormat:@"v%@.%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:kVersionNumber],[[[NSBundle mainBundle] infoDictionary] objectForKey:kBuildNumber]];
    
    //initialize
    self.discoveredSystems = [[NSMutableArray alloc] init];
    
    //maybe we would implement another "easy" initializer without dictionary but simple parameter
    NSDictionary* serviceInfo = [DocumentUtils dictionaryFromResources:@"csr8670"];
    
    NSLog([serviceInfo description]);
    
    self.bleCentral = [[TAPBluetoothLowEnergyCentral alloc] initWithDelegate:self serviceInfo:serviceInfo  scanMode:TAPBluetoothLowEnergyCentralConnectModeManual connectMode:TAPBluetoothLowEnergyCentralConnectModeManual];
}
- (IBAction)viewTapped:(id)sender {
    [self.mailTextField resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.bleCentral disconnectDevice:self.connectedDevice];
    [self.bleCentral stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton

- (IBAction)onDiscoverTapped:(id)sender
{
    [self openDiscovery];
}

- (IBAction)onStartTapped:(id)sender
{
    self.btnStart.selected = !self.btnStart.isSelected;
    
    if(self.btnStart.isSelected)
    {
        self.buffer = [[NSMutableString alloc] init];
        [self subscribe:YES];
        
    }else{
        
        [self subscribe:NO];
        
        if([self.buffer length] > 0)
        {
            [self openEmailAddress:self.emailAdress subject:@"Debug Data" body:self.buffer notSupportMessage:@"Your device does not support email sending or no email account has been setup" data:nil];
        }
    }
}
- (IBAction)disconnectBtnTapped:(id)sender {
    
    [self.bleCentral disconnectDevice:self.connectedDevice];
    
    self.btnDevice.hidden = YES;
}


#pragma mark - TAPBluetoothLowEnergyCentralDelegate methods

- (void)bluetoothLowEnergyCentralDidUpdateState:(TAPBluetoothLowEnergyCentralState)state
{
    switch (state) {
        case TAPBluetoothLowEnergyCentralStatePowerOn:
        {
            [self.bleCentral startScan];            
        }
            break;
            
        default:
            break;
    }
}

- (void)bluetoothLowEnergyCentralDidDiscoverDevice:(CBPeripheral *)device RSSI:(NSNumber *)RSSI
{
    BOOL found = NO;
    
    for(CBPeripheral* discoveredSystem in self.discoveredSystems)
    {
        if([[discoveredSystem.identifier UUIDString] isEqualToString:[device.identifier UUIDString]])
        {
            found = YES;
            break;
        }
    }
    
    if(!found)
    {
        //store the peripherals
        [self.discoveredSystems addObject:device];
    }
    
    NSArray* names = [self namesDiscoveredSystems];
    
    [self.discoverListViewController updateItems:names];    
}

- (void)bluetoothLowEnergyCentralDidConnectToDevice:(CBPeripheral *)device
{
    NSLog(@"DidConnect");
    
    [self.btnDevice setTitle:device.name forState:0];
    
    self.btnDevice.hidden = NO;
}

- (void)bluetoothLowEnergyCentralDidConnectDevice:(CBPeripheral *)device didDiscoverCharacteristicsForService:(NSArray *)characteristics
{
    NSLog(@"DidConnect DidDiscoverCharacteristicForService");
    
    //ready!
    self.connectedDevice = device;
}

- (void)bluetoothLowEnergyCentralDidFailToConnectDevice:(CBPeripheral *)device error:(NSError *)error
{
    [self promptError:@"Connection Error" message:@"Failed to connect"];
}

- (void)bluetoothLowEnergyCentralDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.connectedDevice = nil;
    
    [self promptError:peripheral.name message:@"Disconnected"];
}

- (void)bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic)
    {
        //TP Signal mode
        NSData* value = characteristic.value;
        
        for (int i = 0; i < value.length; i++) {
            NSData *subValue = [value subdataWithRange:NSMakeRange(i, 1)];
//            NSInteger valueInt = *(NSInteger*)([subValue bytes]);
            
            if(self.buffer)
            {
//                [self.buffer appendString:[NSString stringWithFormat:@"%ld",(long)valueInt]];
                [self.buffer appendString:[[NSString alloc]initWithData:subValue encoding:NSASCIIStringEncoding];
            }
//            if (i != value.length-1) {
//                [self.buffer appendString:@","];
//            }
        }
        
        [self.buffer appendString:@"<br />"];

        if (error)
        {
            NSLog(@"Received error in reading: %@", [error localizedDescription]);
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.emailAdress = textField.text;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.emailAdress forKey:@"emailAdress"];
    [userDefaults synchronize];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.emailAdress = textField.text;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.emailAdress forKey:@"emailAdress"];
    [userDefaults synchronize];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    

    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}


#pragma mark - Helper methods

- (NSArray*)namesDiscoveredSystems
{
    NSMutableArray* names = [[NSMutableArray alloc] init];
    
    for (CBPeripheral* peripheral in self.discoveredSystems)
    {
        if(peripheral.name)
        {
            [names addObject:peripheral.name];
        }else{
            [names addObject:@"Unnamed"];
        }
        
    }
    return names;
}

- (void)openDiscovery
{
    if(!self.discoverListViewController)
    {
        NSArray* names = [self namesDiscoveredSystems];
        self.discoverListViewController = [[PopTableViewController alloc] initWithTitle:@"Discovered Devices" items:names];
    }
    
    [self.discoverListViewController show: ^(NSInteger selectedIndex){
        
        if(selectedIndex >= 0)
        {
            [self connectPeripheral:[self.discoveredSystems objectAtIndex:selectedIndex]];
        }
    }];
}

- (void)connectPeripheral:(CBPeripheral*)peripheral
{
    [self.bleCentral connectDevice:peripheral];
}

- (void)promptError:(NSString*)title message:(NSString*)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action){
        
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)subscribe:(BOOL)notify
{
    if(self.connectedDevice)
    {
        CBService* service = [TAPBluetoothLowEnergyCentral serviceWithPeripheral:self.connectedDevice uuidString:TYM_DEBUG_SERVICE_ID];
        
        if (service.characteristics != nil)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                if([[characteristic.UUID UUIDString] isEqualToString:TYM_DEBUG_CHARACTERISTIC_ID])
                {
                    [self.connectedDevice setNotifyValue:notify forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (void)openEmailAddress:(NSString*)address subject:(NSString*)subject body:(NSString*)body notSupportMessage:(NSString*)message data:(NSData*)data
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        //recipient
        if(address)
        {
            [mailer setToRecipients:@[address]];
        }
        
        
        //subject
        [mailer setSubject:subject];
        
        //body
        [mailer setMessageBody:body isHTML:YES];
        
        [self presentViewController:mailer animated:YES completion:^(void){
            
        }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can Not Send Mail", nil)
                                                        message:NSLocalizedString(@"Please check your email account in iPhone setting.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
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

@end
