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
#import "IQServerCommunication.h"
#import "IQGamesViewController.h"

@interface IQHomeViewController ()

@property (nonatomic, strong) NSDictionary *games;

@end

@implementation IQHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [[IQSettings sharedInstance].currentUser logout];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginRoot"];
    IQAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = loginViewController;
}

- (IBAction)joinGameButtonTapped:(id)sender
{
    [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    IQServerCommunication *sc = [[IQServerCommunication alloc] init];
    [sc getGamesWithCompletion:^(id result, NSError *error) {
        if (result) {
            self.games = result;
            [self performSegueWithIdentifier:@"gamesSegue" sender:nil];
        } else {
            [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
        }
    }];
}

#pragma mark - Private Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

@end
