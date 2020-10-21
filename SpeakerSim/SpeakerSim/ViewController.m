//
//  ViewController.m
//  SpeakerSim
//
//  Created by Lam Yick Hong on 11/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "ViewController.h"
#import "TAPBluetoothLowEnergyService.h"

#define TYM_SERVICE_UUID                    @"7d24"

@interface ViewController ()

@property (nonatomic, strong) TAPBluetoothLowEnergyPeripheral *peripheral;

@property (nonatomic, strong) IBOutlet UILabel *lblConn;
@property (nonatomic, strong) IBOutlet UILabel *lblVersion;
@property (nonatomic, strong) IBOutlet UILabel *lblVolume;

@property (nonatomic, strong) IBOutlet UILabel *lblSongTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblArtistName;
@property (nonatomic, strong) IBOutlet UILabel *lblAlbumTitle;
@property (nonatomic, strong) IBOutlet UIImageView* imgArtwork;

@property (nonatomic, strong) MPMusicPlayerController* player;

@property NSInteger volume;
@property BOOL isBatterySubscribed;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.peripheral = [[TAPBluetoothLowEnergyPeripheral alloc] initWithDelegate:self];
    self.peripheral.serviceName = @"Tymphany BLE Speaker Simulator";
    self.peripheral.serviceUUID = [CBUUID UUIDWithString:TYM_SERVICE_UUID];    
    [self.peripheral startAdvertising];
    
    self.volume = 5;
    
    [self prepareMedia];
    
    self.isBatterySubscribed = NO;
}

- (void)prepareMedia
{
    
    MPMediaQuery* everything = [[MPMediaQuery alloc] init];
    self.player = [MPMusicPlayerController applicationMusicPlayer];
    
    [self.player setQueueWithQuery:everything];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                           selector:@selector(onPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:self.player];
    
    [self.player beginGeneratingPlaybackNotifications];
}

- (void)onPlayingItemChanged:(NSNotification*)notif
{
    NSDictionary* dictionary = [notif userInfo];
    
    NSString* key = [dictionary objectForKey:@"MPMusicPlayerControllerNowPlayingItemPersistentIDKey"];
    
    MPMediaPropertyPredicate *abPredicate =
    [MPMediaPropertyPredicate predicateWithValue:key
                                     forProperty:MPMediaItemPropertyPersistentID];
    
    MPMediaQuery *abQuery = [[MPMediaQuery alloc] init];
    [abQuery addFilterPredicate:abPredicate];
    
    NSArray* items = [[[abQuery collections] objectAtIndex:0] items];
    
    MPMediaItem* mediaItem = [items objectAtIndex:0];
    
    if(mediaItem)
    {
        NSString* songTitle = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
        NSString* artist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
        NSString* albumTitle = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        
        self.lblSongTitle.text = songTitle;
        self.lblArtistName.text = artist;
        self.lblAlbumTitle.text = albumTitle;
        
        MPMediaItemArtwork* artwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        
        if(artwork){
            self.imgArtwork.image = [artwork imageWithSize:CGSizeMake(460, 460)];
        }else{
            
            self.imgArtwork.image = [UIImage imageNamed:@"allplay_now_playing_album.png"];
        }
    }else{
        
        self.lblSongTitle.text = @"Song Title";
        self.lblArtistName.text = @"Artist Name";
        self.lblAlbumTitle.text = @"Album Title";
        
        self.imgArtwork.image = [UIImage imageNamed:@"allplay_now_playing_album.png"];
    }
    
    [self.player prepareToPlay];
    
}

- (void)prepareBattery
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    // Request to be notified when battery charge or state changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBatteryChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBatteryChange:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

- (void)unprepareBattery
{
     [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    
    //TODO: remove notification
}

- (void)onBatteryChange:(NSNotification*)notif
{
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    NSString* batteryString = [NSString stringWithFormat:@"%f", batteryLevel];
    NSData* batteryData = [batteryString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.peripheral sendBatteryToSubscribers:batteryData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheral:(TAPBluetoothLowEnergyPeripheral *)peripheral centralDidSubscribe:(CBCentral *)central  characteristic:(CBCharacteristic *)characteristic{
    
    if(!self.isBatterySubscribed)
    {
        [self prepareBattery];
    }
}

- (void)peripheral:(TAPBluetoothLowEnergyPeripheral *)peripheral centralDidUnsubscribe:(CBCentral *)central  characteristic:(CBCharacteristic *)characteristic{
    
    if(self.isBatterySubscribed)
    {
        [self unprepareBattery];
    }
}

- (void)peripheral:(TAPBluetoothLowEnergyPeripheral *)peripheral readCharacteristic:(CBCharacteristic *)characteristic completion:(void (^)(NSData*))data{
 
    if([characteristic.UUID.UUIDString isEqualToString:TYM_CHARACTERISTIC_SW_VERSION]){
        
        data([@"1.0" dataUsingEncoding:NSUTF8StringEncoding]);
        
    }else if([characteristic.UUID.UUIDString isEqualToString:TYM_CHARACTERISTIC_BATTERY_READ] || [characteristic.UUID.UUIDString isEqualToString:TYM_CHARACTERISTIC_BATTERY_STATUS]){
        
        NSString* batteryLevel = [NSString stringWithFormat:@"%f", [[UIDevice currentDevice] batteryLevel]];
        
        data([batteryLevel dataUsingEncoding:NSUTF8StringEncoding]);
    }
    
    data([NSData data]);
}

- (void)peripheral:(TAPBluetoothLowEnergyPeripheral *)peripheral writeCharacteristic:(CBCharacteristic *)characteristic withData:(NSData*)data completion:(void (^)(NSDictionary*))handler{
    
    NSLog(@"%@", characteristic.UUID.UUIDString);
    
    if([characteristic.UUID.UUIDString isEqualToString:TYM_CHARACTERISTIC_PLAY_CONTROL]){
        
        NSString* playControl = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        BOOL startPlay = [playControl boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(startPlay)
            {
                [self.player play];
                
            }else{
                
                [self.player pause];
            }
            
        });
        
        

    }else if([characteristic.UUID.UUIDString isEqualToString:TYM_CHARACTERISTIC_VOLUME_CONTROL]){
        
        NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.volume = self.volume + [string integerValue];
        
        if(self.volume < 0){
            self.volume = 0;
        }else if (self.volume > 10){
            self.volume = 10;
        }
        
        self.lblVolume.text = [NSString stringWithFormat:@"Volume: %ld", (long)self.volume];
    }
    
    handler(nil);
}


@end
