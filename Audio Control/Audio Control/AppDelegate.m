//
//  AppDelegate.m
//  Audio Control
//
//  Created by Alain Hsu on 6/28/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "AppDelegate.h"
#import "SystemManager.h"
#import "ThemeUtils.h"
#import <LoginWithAmazon/LoginWithAmazon.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AlexaHTTPRequest.h"

@interface AppDelegate ()<UISplitViewControllerDelegate>{
    MPMusicPlayerController *player;
    id playingItemObserver;
}
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backtaskIdentifier;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [ThemeUtils startTheme];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
        splitViewController.delegate = self;
    }
    
    [[SystemManager sharedManager] start];
    
    player = [MPMusicPlayerController systemMusicPlayer];
    [player beginGeneratingPlaybackNotifications];
    
    [self addNotifications];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    self.backtaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void){

    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application endBackgroundTask:self.backtaskIdentifier];
    self.backtaskIdentifier = UIBackgroundTaskInvalid;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[SystemManager sharedManager].systemService disconnectSystem:[SystemManager sharedManager].connectedSystem];
    [player endGeneratingPlaybackNotifications];
}

-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation
{
    BOOL isValidRedirectSignInURL = [AIMobileLib handleOpenURL:url sourceApplication:sourceApplication];
    
    if (isValidRedirectSignInURL == false) {
        return false;
    }
    return true;
}

- (void)addNotifications {
    playingItemObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:player queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        MPMusicPlayerController *player2 = note.object;
        MPMediaItem *nowPlayingItem = player2.nowPlayingItem;
        
        //date
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmm";
        NSString *res = [formatter stringFromDate:date];

        
        //title
        NSString *tittle;
        if (nowPlayingItem.title) {
            tittle = [self checkStringShouldAlphaNum:nowPlayingItem.title];
        }else{
            tittle = @"";
        }
        
        //genre
        NSString *genre;
        if (nowPlayingItem.genre) {
            genre = [self checkStringShouldAlphaNum:nowPlayingItem.genre];
        }else{
            genre = @"";
        }
        
        //artist
        NSString *artist;
        if (nowPlayingItem.title) {
            artist = [self checkStringShouldAlphaNum:nowPlayingItem.artist];
        }else{
            artist = @"";
        }
        
        //year
        NSNumber *yearNumber = [nowPlayingItem valueForProperty:@"year"];
        NSString *yearStr;
        if ([yearNumber integerValue] == 0){
            yearStr = @"";
        }else{
            NSInteger year = [yearNumber integerValue] /10*10;
            yearStr = [NSString stringWithFormat:@"%ld",year];
        }

        
        NSDictionary *itemInfo = @{@"id":[NSNumber numberWithInteger:1],
                                   @"date":res,
                                   @"title":tittle,
                                   @"genre":genre,
                                   @"artist":artist,
                                   @"year":yearStr,
                                   @"count":[NSNumber numberWithInteger:nowPlayingItem.playCount]
                                   };
        NSLog(@"itemInfo==%@",itemInfo);
        
        [[AlexaHTTPRequest shareInstance] postPlayingItem:itemInfo success:^(id responseObj) {
            NSLog(@"post music info succeed:%@",responseObj);
        } failure:^(NSError *error) {
            NSLog(@"post music info failure:%@",error);
        }];

    }];
}

#pragma mark helper

- (NSString*)checkStringShouldAlphaNum:(NSString*)str {
    NSMutableArray *characters = [NSMutableArray array];
    NSMutableString *mutStr = [NSMutableString string];
    
    
    for (int i = 0; i < str.length; i ++) {
        NSString *subString = [str substringToIndex:i + 1];
        
        subString = [subString substringFromIndex:i];
        
        [characters addObject:subString];
    }
    
    for (NSString *b in characters) {
        NSString *regex = @"^[a-zA-Z0-9]*$";
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isShu = [pre evaluateWithObject:b];
        if (isShu) {
            [mutStr appendString:b];
        }else{
            [mutStr appendString:@" "];
        }
    }
    
    if ([self isStringContainNumberWith:mutStr]) {
        return mutStr;
    }else{
        return @"";
    }
}

- (BOOL)isStringContainNumberWith:(NSString *)str {
    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = [numberRegular numberOfMatchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];

    if (count > 0) {
        return YES;
    }
    return NO;
}


@end
