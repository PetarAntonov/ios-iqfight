//
//  DataService.m
//  BGTrader
//
//  Created by Sergey Petrov on 4/8/14.
//  Copyright (c) 2014 TitleX. All rights reserved.
//

#import "DataService.h"
#import "IQSettings.h"
#import "URLReader.h"

@interface DataService() <URLReaderDelegate>

@property (nonatomic, strong) URLReader *urlReader;
@property (nonatomic, strong) NSString *lastURL;

@property int OperationID;

@end

@implementation DataService

#pragma mark - Public

- (void)isLogged
{
    self.OperationID = WSOperationsIsLogged;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/is_logged"];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    self.OperationID = WSOperationsLogin;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?username=%@&password=%@", [IQSettings sharedInstance].servicesURL, @"/login", username, password];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)createRegistrationWithUsername:(NSString *)username password:(NSString *)password andPassword1:(NSString *)password1
{
    self.OperationID = WSOperationsRegistration;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?username=%@&password=%@&password1=%@", [IQSettings sharedInstance].servicesURL, @"/register", username, password, password1];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)getGames
{
    self.OperationID = WSOperationsGetGames;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/get_games"];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)openGame:(NSString *)gameID
{
    self.OperationID = WSOperationsOpenGame;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?id=%@", [IQSettings sharedInstance].servicesURL, @"/open_game", gameID];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)refreshGame:(NSString *)gameID
{
    self.OperationID = WSOperationsRefreshGame;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?id=%@", [IQSettings sharedInstance].servicesURL, @"/refresh_game", gameID];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)playGame
{
    self.OperationID = WSOperationsPlayGame;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/play"];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)answerQuestion:(NSString *)answerID
{
    self.OperationID = WSOperationsAnswerQuestion;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?answer_id=%@", [IQSettings sharedInstance].servicesURL, @"/answer", answerID];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)newGame:(NSDictionary *)dic
{
    self.OperationID = WSOperationsNewGame;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?name=%@", [IQSettings sharedInstance].servicesURL, @"/new_game", dic[@"name"]];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)quitGame
{
    self.OperationID = WSOperationQuit;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/quit"];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)logout
{
    self.OperationID = WSOperationLogout;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/logout"];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)showResult:(NSString *)gameID
{
    self.OperationID = WSOperationResult;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?game=%@&limit=3&offset=0", [IQSettings sharedInstance].servicesURL, @"/statistics", gameID];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)showStatistics
{
    self.OperationID = WSOperationStatistics;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?limit=1000&offset=0", [IQSettings sharedInstance].servicesURL, @"/statistics"];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}
#pragma mark - URLReader delegates

- (void)urlRequestError:(id)sender errorMessage:(NSString *)errorMessage {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceError:errorMessage:)])
        [self.delegate dataServiceError:self errorMessage:errorMessage];
}

- (void)urlRequestFinished:(id)sender withData:(NSData *)resultData {
    switch (self.OperationID) {
        case WSOperationsIsLogged:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceIsLoggedFinished:withData:)])
                [self.delegate dataServiceIsLoggedFinished:self withData:resultData];
            break;
        case WSOperationsLogin:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceLoginFinished:withData:)])
                [self.delegate dataServiceLoginFinished:self withData:resultData];
            break;
        case WSOperationsRegistration:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceRegistrationFinished:withData:)])
                [self.delegate dataServiceRegistrationFinished:self withData:resultData];
            break;
        case WSOperationsGetGames:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceGetGamesFinished:withData:)])
                [self.delegate dataServiceGetGamesFinished:self withData:resultData];
            break;
        case WSOperationsOpenGame:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceOpenGameFinished:withData:)])
                [self.delegate dataServiceOpenGameFinished:self withData:resultData];
            break;
        case WSOperationsRefreshGame:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceRefreshGameFinished:withData:)])
                [self.delegate dataServiceRefreshGameFinished:self withData:resultData];
            break;
        case WSOperationsPlayGame:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServicePlayGameFinished:withData:)])
                [self.delegate dataServicePlayGameFinished:self withData:resultData];
            break;
        case WSOperationsAnswerQuestion:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceAnswerQuestionFinished:withData:)])
                [self.delegate dataServiceAnswerQuestionFinished:self withData:resultData];
            break;
        case WSOperationsNewGame:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceNewGameFinished:withData:)])
                [self.delegate dataServiceNewGameFinished:self withData:resultData];
            break;
        case WSOperationQuit:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceQuitGame:withData:)])
                [self.delegate dataServiceQuitGame:self withData:resultData];
            break;
        case WSOperationLogout:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceLogoutFinished:withData:)])
                [self.delegate dataServiceLogoutFinished:self withData:resultData];
            break;
        case WSOperationResult:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceResultFinished:withData:)])
                [self.delegate dataServiceResultFinished:self withData:resultData];
            break;
        case WSOperationStatistics:
            if (self.delegate && [self.delegate respondsToSelector:@selector(dataServiceStatisticsFinished:withData:)])
                [self.delegate dataServiceStatisticsFinished:self withData:resultData];
            break;
        default:
            break;
    }
}

@end
