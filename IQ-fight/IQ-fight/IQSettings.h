//
//  IQSettings.h
//  IQ-fight
//
//  Created by Petar Antonov on 4/26/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQCurrentUser.h"
#import "DataService.h"
#import "URLReader.h"

typedef enum WSOperation {
    WSOperationsUnknown = 0,
    WSOperationsIsLogged,
	WSOperationsLogin,
    WSOperationsRegistration,
    WSOperationsGetGames,
    WSOperationsOpenGame,
    WSOperationsRefreshGame,
    WSOperationsPlayGame,
    WSOperationsAnswerQuestion,
    WSOperationsNewGame,
    WSOperationQuit,
    WSOperationLogout
} WSOperation;

@interface IQSettings : NSObject

@property (nonatomic,assign) BOOL inDebug;
@property (nonatomic, strong) NSString *servicesURL;
@property (nonatomic, strong) IQCurrentUser *currentUser;
@property (nonatomic, strong) DataService *dService;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) URLReader *urlReader;

+ (IQSettings *)sharedInstance;

- (void)LogThis:(NSString *)log, ...;
- (void)showHud:(NSString *)title onView:(UIView *)v;
- (void)hideHud:(UIView *)v;
- (BOOL)internetAvailable;
- (NSData *)dictToJSONData:(NSDictionary *)dict;
- (NSMutableDictionary *)jsonToDict:(NSData *)json;
- (NSString *)jsonDataToString:(NSData *)data;

@end
