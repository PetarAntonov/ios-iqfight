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
    
    self.title = [IQSettings sharedInstance].currentUser.username;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    //TODO: create new game
}

- (IBAction)logoutButtonTapped:(id)sender
{
    //TODO: iztrii tuka i cookite ili kvoto 6te da e tam
    [[IQSettings sharedInstance].currentUser logout];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginRoot"];
    IQAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = loginViewController;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
    });
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

#pragma mark - Private Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

@end
