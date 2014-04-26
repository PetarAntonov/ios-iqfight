//
//  IQSettings.h
//  IQ-fight
//
//  Created by Petar Antonov on 4/26/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQCurrentUser.h"

@interface IQSettings : NSObject

@property (nonatomic, strong) NSString *servicesURL;
@property (nonatomic, strong) IQCurrentUser *currentUser;
@property (nonatomic, strong) NSArray *games;

- (void)showHud:(NSString *)title onView:(UIView *)v;
- (void)hideHud:(UIView *)v;

+ (IQSettings *)sharedInstance;

@end
