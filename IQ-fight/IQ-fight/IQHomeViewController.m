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

@interface IQHomeViewController ()

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
    
    //
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //set title and other statistics on the UI
    self.title = [IQSettings sharedInstance].currentUser.username;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)newGameButtonTapped:(id)sender
{
    //TODO: create new game
}

- (IBAction)logoutButtonTapped:(id)sender
{
    //TODO: iztrii lognatiq user ako ima
    
    [[IQSettings sharedInstance].currentUser logout];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginRoot"];
    IQAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = loginViewController;
}

- (IBAction)joinGameButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"gamesSegue" sender:nil];
}

@end
