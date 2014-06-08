//
//  IQSettings.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/26/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQSettings.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface IQSettings ()

@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation IQSettings

+ (IQSettings *)sharedInstance
{
    static dispatch_once_t once;
    static IQSettings * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)LogThis:(NSString *)log, ... {
    if (self.inDebug) {
        NSString *output;
        va_list ap;
        va_start(ap, log);
        output = [[NSString alloc] initWithFormat:log arguments:ap];
        va_end(ap);
        NSLog(@"[IQ-Fight] %@", output);
    }
}

- (BOOL)internetAvailable {
	Reachability *r = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL result = FALSE;
	if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN)
	    result = TRUE;
	return result;
}

- (id) init
{
	if (self = [super init]) {
#if (TARGET_IPHONE_SIMULATOR)
        self.inDebug = YES;
#else
        self.inDebug = NO;`
#endif
        self.servicesURL = @"http://iqfight.empters.com";
        
        self.currentUser = [[IQCurrentUser alloc] init];
        self.dService = [[DataService alloc] init];
        self.request = [[NSMutableURLRequest alloc] init];
        self.urlReader = [[URLReader alloc] init];
    }
    
    return self;
}

#pragma mark - HUD

- (void)showHud:(NSString *)title onView:(UIView *)v {
    if (v != nil)
        self.hud = [MBProgressHUD showHUDAddedTo:v animated:YES];
    else
        self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = title;
    self.hud.dimBackground = YES;
}

- (void)hideHud:(UIView *)v {
    if (v != nil)
        [MBProgressHUD hideHUDForView:v animated:YES];
    else
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:YES];
}

#pragma mark - JSON

- (NSData *)dictToJSONData:(NSDictionary *)dict {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error != nil)
        [[IQSettings sharedInstance] LogThis:@"dictToJSONData error - %@", [error localizedDescription]];
    return jsonData;
}

- (NSMutableDictionary *)jsonToDict:(NSData *)json {
    NSError *error = nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:&error];
    if (error != nil)
        [[IQSettings sharedInstance] LogThis:@"jsonToDict error - %@", [error localizedDescription]];
    return dict;
}

- (NSString *)jsonDataToString:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
