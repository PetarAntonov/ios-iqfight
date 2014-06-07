//
//  URLReader.m
//  BGTrader
//
//  Created by Sergey Petrov on 4/7/14.
//  Copyright (c) 2014 TitleX. All rights reserved.
//

#import "URLReader.h"
#import "IQSettings.h"

@interface URLReader ()

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation URLReader

#pragma mark - System

- (void)getFromURL:(NSString *)URL postData:(NSData *)pData postMethod:(NSString *)pMethod {
    [[IQSettings sharedInstance] LogThis:@"getFromURL URL = %@", URL];
	
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSMutableURLRequest *request = [IQSettings sharedInstance].request;
	[request setURL:[NSURL URLWithString:URL]];
	[request setHTTPMethod:pMethod];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    if (![pMethod isEqualToString:@"GET"]) {
        [request setHTTPBody:pData];
    }
    [[IQSettings sharedInstance] LogThis:@"getFromURL method = %@, postData = %@", pMethod, [[IQSettings sharedInstance] jsonDataToString:pData]];
    
    NSError *error;
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ([data length] > 0 && error == nil) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [[IQSettings sharedInstance] LogThis:@"getFromURL downloaded = %@", dataString];
        if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(urlRequestFinished:withData:)])
            [self.delegate urlRequestFinished:self withData:data];
    } else {
        [[IQSettings sharedInstance] LogThis:@"getFromURL error = %@", [error localizedDescription]];
        if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(urlRequestError:errorMessage:)])
            [self.delegate urlRequestError:self errorMessage:[error localizedDescription]];
    }
}

@end
