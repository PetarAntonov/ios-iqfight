//
//  IQServerCommunication.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQServerCommunication.h"
#import "AFNetworking.h"
#import "IQSettings.h"

@implementation IQServerCommunication

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withCompetionBlock:(void (^)(id result, NSError *error))completion
{
    //TODO: opravi url-a
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"login"]];
    
    NSDictionary *params = @{@"username": username,
                             @"password": password};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                   options:0
                                                     error:nil];
    
    [self makeRequest:url httpMethod:@"POST" httpBody:data completion:completion];
    
}

- (void)isLoggedWithCompletion:(void (^)(id result, NSError *error))completion
{    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @"is_logged"]];
    
    [self makeRequest:url httpMethod:@"GET" httpBody:nil completion:completion];
}

- (void)getGamesWithCompletion:(void (^)(id result, NSError *error))completion
{
    //TODO: opravi url-a
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @""]];
    
    [self makeRequest:url httpMethod:@"GET" httpBody:nil completion:completion];
}

- (void)openGameWithCompletion:(void (^)(id result, NSError *error))completion
{
    //TODO: opravi url-a
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, @""]];
    
    NSDictionary *params = @{@"username": [IQSettings sharedInstance].currentUser.username};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                   options:0
                                                     error:nil];
    
    [self makeRequest:url httpMethod:@"POST" httpBody:data completion:completion];
}

- (void)makeRequest:(NSURL *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)httpBody completion:(void (^)(id result, NSError *error))completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setTimeoutInterval:60];
    
    [request setHTTPMethod:httpMethod];
    
    if (httpBody != nil) {
        [request setHTTPBody:httpBody];
    }
    
    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        id result = nil;
        if (responseObject) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            
            //TODO: obraboti rezultata
            
            NSLog(@"result: %@", result);
            if ([[result objectForKey:@"error"] isEqualToString:@""]) {
                completion([result objectForKey:@"result"],nil);
            } else {
                completion(nil, [NSError errorWithDomain:@"ServerCommunication" code:500 userInfo:@{NSLocalizedDescriptionKey: [result objectForKey:@"error"]}]);
            }
        } else {
            completion(nil, [NSError errorWithDomain:@"ServerCommunication" code:500 userInfo:@{NSLocalizedDescriptionKey: @"Няма резултат от сървъра"}]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
    
    [httpOperation start];
}

@end
