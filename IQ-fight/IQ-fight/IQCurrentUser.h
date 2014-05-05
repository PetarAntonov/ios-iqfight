//
//  IQCurrentUser.h
//  IQ-fight
//
//  Created by Petar Antonov on 4/26/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQCurrentUser : NSObject

@property (nonatomic, strong) NSString *username;

- (void)logout;

@end
