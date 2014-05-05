//
//  IQGamesViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQGamesViewController.h"
#import "IQServerCommunication.h"
#import "IQGameTableViewCell.h"
#import "IQSettings.h"
#import "IQGameLobyViewController.h"

@interface IQGamesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IQServerCommunication *sv;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSDictionary *game;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *gameID;

@end

@implementation IQGamesViewController

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
    
    self.title = @"Games";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(updateTableView) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:([self.games[@"refresh_interval"] intValue] / 1000) target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gameLobySegue"]) {
        ((IQGameLobyViewController *)segue.destinationViewController).game = self.game;
        ((IQGameLobyViewController *)segue.destinationViewController).gameName = self.gameName;
        ((IQGameLobyViewController *)segue.destinationViewController).gameID = self.gameID;
    }
}

#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.games[@"games"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQGameTableViewCell *cell = (IQGameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
    
    cell.gameLabel.text = self.games[@"games"][indexPath.row][@"name"];
    cell.playersToStartLabel.text = self.games[@"games"][indexPath.row][@"players_to_start"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    if (self.sv == nil) {
        self.sv = [[IQServerCommunication alloc] init];
    }
    
    [self.sv openGame:self.games[@"games"][indexPath.row][@"id"] withCompletion:^(id result, NSError *error) {
        if ([result[@"players_to_start"] intValue] > 0) {
            [self.sv refreshGame:self.games[@"games"][indexPath.row][@"id"] withCompletion:^(id result, NSError *error) {
                if (result) {
                    [[IQSettings sharedInstance] hideHud:self.view];
                    self.game = result;
                    self.gameName = self.games[@"games"][indexPath.row][@"name"];
                    self.gameID = self.games[@"games"][indexPath.row][@"id"];
                    [self performSegueWithIdentifier:@"gameLobySegue" sender:nil];
                } else {
                    [[IQSettings sharedInstance] hideHud:self.view];
                    [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
                }
            }];
        } else {
            [[IQSettings sharedInstance] hideHud:self.view];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
        }
    }];
    
    [self performSegueWithIdentifier:@"gameLobySegue" sender:nil];
}

#pragma mark - Private Methods

- (void)updateTableView
{
    if (self.sv == nil) {
        self.sv = [[IQServerCommunication alloc] init];
    }
    
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:([self.games[@"refresh_interval"] intValue] / 1000) target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];
    }
    
    IQServerCommunication *sc = [[IQServerCommunication alloc] init];
    [sc getGamesWithCompletion:^(id result, NSError *error) {
        if (result) {
            self.games = result;
            
            [self.tableView reloadData];
        } else {
            if (self.timer != nil) {
                [self.timer invalidate];
                self.timer = nil;
            }
            
            [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
        }
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

@end
