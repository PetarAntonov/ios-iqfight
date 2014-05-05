//
//  IQResultViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 5/5/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQResultViewController.h"
#import "IQServerCommunication.h"

@interface IQResultViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;

@end

@implementation IQResultViewController

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
    
    self.title = @"Result";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)homeScreenButtonTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)chooseNewGameButtonTapped:(id)sender
{
//napravi delegate da se setnat igrite
    IQServerCommunication *sc = [[IQServerCommunication alloc] init];
    [sc getGamesWithCompletion:^(id result, NSError *error) {
        if (result) {
//            self.games = result[@"games"];
//            self.refreshInterval = [result[@"refresh_interval"] integerValue];
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
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
