//
//  IQServerCommunication.h
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQServerCommunication : NSObject

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withCompetionBlock:(void (^)(id result, NSError *error))completion;
- (void)isLoggedWithCompletion:(void (^)(id result, NSError *error))completion;
- (void)getGamesWithCompletion:(void (^)(id result, NSError *error))completion;
- (void)openGameWithCompletion:(void (^)(id result, NSError *error))completion;

@end
