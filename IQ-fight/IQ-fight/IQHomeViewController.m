//
//  IQHomeViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQHomeViewController.h"
#import "IQAppDelegate.h"
#import "IQSettings.h"
#import "DataService.h"
#import "IQGamesViewController.h"

@interface IQHomeViewController () <DataServiceDelegate>

@property (nonatomic, strong) NSDictionary *games;
@property (nonatomic, assign) BOOL isLogout;

@end

@implementation IQHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isLogout = NO;
    self.title = [IQSettings sharedInstance].currentUser.username;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gamesSegue"]) {
        ((IQGamesViewController *)segue.destinationViewController).games = self.games;
    }
}

#pragma mark - Action Methods

- (IBAction)newGameButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"newGameSegue" sender:nil];
}

- (IBAction)logoutButtonTapped:(id)sender
{
    self.isLogout = YES;
    [self performSelectorInBackground:@selector(doLogout) withObject:nil];
}

- (IBAction)joinGameButtonTapped:(id)sender
{
    [self performSelectorInBackground:@selector(doGetGames) withObject:nil];
}

- (void)doGetGames
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    //DataService *dService = [IQSettings sharedInstance].dService;
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService getGames];
}

- (void)doLogout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    //DataService *dService = [IQSettings sharedInstance].dService;
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService logout];
}

#pragma mark - Service delegates

//expected request responce
//{
//    'games':
//        [ {'id':8,
//            'name': Ebane,
//            'players_to_start':2}
//         ],
//    'refresh_interval':1000ms,
//    'status':"ok/error",
//    'error_message':''
//}

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    if (self.isLogout) {
        [self logout];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
            [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
        });
    }
}

- (void)dataServiceGetGamesFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL getGamesSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        getGamesSuccessfull = NO;
    
    if (getGamesSuccessfull) {
        self.games = j;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
            
            [self performSegueWithIdentifier:@"gamesSegue" sender:nil];
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

- (void)dataServiceLogoutFinished:(id)sender withData:(NSData *)data
{
    [self logout];
}

#pragma mark - Private Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

- (void)logout
{
    self.isLogout = NO;
    
    NSDictionary* cookieDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionid"];
    if (cookieDictionary) {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieDictionary];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[IQSettings sharedInstance].currentUser logout];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginRoot"];
        IQAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        delegate.window.rootViewController = loginViewController;
    });
}

@end
