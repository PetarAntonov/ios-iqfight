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
        self.urlReader = [IQSettings sharedInstance].urlReader;
//        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/is_logged"];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    self.OperationID = WSOperationsLogin;
    
    if (self.urlReader == nil)
        self.urlReader = [IQSettings sharedInstance].urlReader;
//        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?username=%@&password=%@", [IQSettings sharedInstance].servicesURL, @"/login", username, password];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
    
//POST REQUEST
//    NSDictionary *params = @{@"username": username,
//                             @"password": password};
    
//    NSData *postData = [[IQSettings sharedInstance] dictToJSONData:params];
//    NSData *postData = [[NSString stringWithFormat:@"username=%@&password=%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
//    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/login"];
    
//    [self.urlReader getFromURL:self.lastURL postData:postData postMethod:@"POST"];
}

- (void)createRegistrationWithUsername:(NSString *)username password:(NSString *)password andPassword1:(NSString *)password1
{
    self.OperationID = WSOperationsRegistration;
    
    if (self.urlReader == nil)
        self.urlReader = [IQSettings sharedInstance].urlReader;
//        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?username=%@&password=%@&password1=%@", [IQSettings sharedInstance].servicesURL, @"/register", username, password, password1];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];

//POST REQUEST
//    NSDictionary *params = @{@"username": username,
//                             @"password": password,
//                             @"password1": password1};
//    
//    NSData *postData = [[IQSettings sharedInstance] dictToJSONData:params];
//    
//    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/register"];
//    
//    [self.urlReader getFromURL:self.lastURL postData:postData postMethod:@"POST"];
}

- (void)getGames
{
    self.OperationID = WSOperationsGetGames;
    
    if (self.urlReader == nil)
        self.urlReader = [IQSettings sharedInstance].urlReader;
//        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/get_games"];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
}

- (void)openGame:(NSString *)gameID
{
    self.OperationID = WSOperationsOpenGame;
    
    if (self.urlReader == nil)
        self.urlReader = [IQSettings sharedInstance].urlReader;
//        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?id=%@", [IQSettings sharedInstance].servicesURL, @"/open_game", gameID];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
    
//POST REQUEST
//    NSDictionary *params = @{@"id": gameID};
//    
//    NSData *postData = [[IQSettings sharedInstance] dictToJSONData:params];
//    
//    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/open_game"];
//    
//    [self.urlReader getFromURL:self.lastURL postData:postData postMethod:@"POST"];
}

- (void)refreshGame:(NSString *)gameID
{
    self.OperationID = WSOperationsRefreshGame;
    
    if (self.urlReader == nil)
        self.urlReader = [[URLReader alloc] init];
    [self.urlReader setDelegate:self];
    
    self.lastURL = [NSString stringWithFormat:@"%@%@?id=%@", [IQSettings sharedInstance].servicesURL, @"/refresh_game", gameID];
    
    [self.urlReader getFromURL:self.lastURL postData:nil postMethod:@"GET"];
    
//POST REQUEST
//    NSDictionary *params = @{@"id": gameID};
//    
//    NSData *postData = [[IQSettings sharedInstance] dictToJSONData:params];
//    
//    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/refresh_game"];
//    
//    [self.urlReader getFromURL:self.lastURL postData:postData postMethod:@"POST"];
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
    
//POST REQUEST
//    NSDictionary *params = @{@"answer_id": answerID};
//    
//    NSData *postData = [[IQSettings sharedInstance] dictToJSONData:params];
//    
//    self.lastURL = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"/answer"];
//    
//    [self.urlReader getFromURL:self.lastURL postData:postData postMethod:@"POST"];
}


#pragma mark - URLReader delegates

- (void)urlRequestError:(id)sender errorMessage:(NSString *)errorMessage {
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServiceError:errorMessage:)])
        [self.delegate dataServiceError:self errorMessage:errorMessage];
}

- (void)urlRequestFinished:(id)sender withData:(NSData *)resultData {
    switch (self.OperationID) {
        case WSOperationsIsLogged:
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServiceIsLoggedFinished:withData:)])
                [self.delegate dataServiceIsLoggedFinished:self withData:resultData];
            break;
        case WSOperationsLogin:
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServiceLoginFinished:withData:)])
                [self.delegate dataServiceLoginFinished:self withData:resultData];
            break;
        case WSOperationsRegistration:
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServiceRegistrationFinished:withData:)])
                [self.delegate dataServiceRegistrationFinished:self withData:resultData];
            break;
        case WSOperationsGetGames:
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServiceGetGamesFinished:withData:)])
                [self.delegate dataServiceGetGamesFinished:self withData:resultData];
            break;
        case WSOperationsOpenGame:
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServiceOpenGameFinished:withData:)])
                [self.delegate dataServiceOpenGameFinished:self withData:resultData];
            break;
        case WSOperationsRefreshGame:
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServiceRefreshGameFinished:withData:)])
                [self.delegate dataServiceRefreshGameFinished:self withData:resultData];
            break;
        case WSOperationsPlayGame:
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServicePlayGameFinished:withData:)])
                [self.delegate dataServicePlayGameFinished:self withData:resultData];
            break;
        case WSOperationsAnswerQuestion:
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataServiceAnswerQuestionFinished:withData:)])
                [self.delegate dataServiceAnswerQuestionFinished:self withData:resultData];
            break;
        default:
            break;
    }
}

@end
