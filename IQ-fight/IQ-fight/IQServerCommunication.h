//
//  IQServerCommunication.h
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQServerCommunication : NSObject

- (void)isLoggedWithCompletion:(void (^)(id result, NSError *error))completion;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withCompetionBlock:(void (^)(id result, NSError *error))completion;
- (void)createRegistrationWithUsername:(NSString *)username password:(NSString *)password andPassword1:(NSString *)password1 withCompetionBlock:(void (^)(id result, NSError *error))completion;
- (void)getGamesWithCompletion:(void (^)(id result, NSError *error))completion;
- (void)openGame:(NSString *)gameID withCompletion:(void (^)(id result, NSError *error))completion;
- (void)refreshGame:(NSString *)gameID withCompletion:(void (^)(id result, NSError *error))completion;
- (void)playGameWithCompletion:(void (^)(id result, NSError *error))completion;
- (void)answerQuestion:(NSString *)answerID withCompletion:(void (^)(id result, NSError *error))completion;

@end
