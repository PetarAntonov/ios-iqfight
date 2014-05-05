//
//  IQSettings.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/26/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQSettings.h"
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

- (id) init
{
	if (self = [super init]) {
        self.servicesURL = @"...";
        
        self.currentUser = [[IQCurrentUser alloc] init];
    }
    
    return self;
}

- (void)showHud:(NSString *)title onView:(UIView *)v
{
//    if (self.hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:v animated:YES];
//    }
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = title;
    self.hud.dimBackground = YES;
}

- (void)hideHud:(UIView *)v
{
    [MBProgressHUD hideHUDForView:v animated:YES];
}

@end
