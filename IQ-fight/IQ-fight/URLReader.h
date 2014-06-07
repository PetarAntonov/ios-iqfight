//
//  URLReader.h
//  BGTrader
//
//  Created by Sergey Petrov on 4/7/14.
//  Copyright (c) 2014 TitleX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol URLReaderDelegate <NSObject>

@optional

- (void)urlRequestError:(id)sender errorMessage:(NSString *)errorMessage;
- (void)urlRequestFinished:(id)sender withData:(NSData *)resultData;

@end

@interface URLReader : NSObject

@property (nonatomic , weak) id<URLReaderDelegate> delegate;

- (void)getFromURL:(NSString *)URL postData:(NSData *)pData postMethod:(NSString *)pMethod;

@end
