//
//  DataService.h
//  BGTrader
//
//  Created by Sergey Petrov on 4/8/14.
//  Copyright (c) 2014 TitleX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataServiceDelegate <NSObject>

@optional

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage;
- (void)dataServiceIsLoggedFinished:(id)sender withData:(NSData *)data;
- (void)dataServiceLoginFinished:(id)sender withData:(NSData *)data;
- (void)dataServiceRegistrationFinished:(id)sender withData:(NSData *)data;
- (void)dataServiceGetGamesFinished:(id)sender withData:(NSData *)data;
- (void)dataServiceOpenGameFinished:(id)sender withData:(NSData *)data;
- (void)dataServiceRefreshGameFinished:(id)sender withData:(NSData *)data;
- (void)dataServicePlayGameFinished:(id)sender withData:(NSData *)data;
- (void)dataServiceAnswerQuestionFinished:(id)sender withData:(NSData *)data;
- (void)dataServiceNewGameFinished:(id)sender withData:(NSData *)data;
- (void)dataServiceQuitGame:(id)sender withData:(NSData *)data;
- (void)dataServiceLogoutFinished:(id)sender withData:(NSData *)data;

@end

@interface DataService : NSObject

@property (nonatomic, weak) id<DataServiceDelegate> delegate;

- (void)isLogged;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)createRegistrationWithUsername:(NSString *)username password:(NSString *)password andPassword1:(NSString *)password1;
- (void)getGames;
- (void)openGame:(NSString *)gameID;
- (void)refreshGame:(NSString *)gameID;
- (void)playGame;
- (void)answerQuestion:(NSString *)answerID;
- (void)newGameWithName:(NSString *)name;
- (void)quitGame;
- (void)logout;

@end
