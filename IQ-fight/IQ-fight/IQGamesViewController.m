//
//  IQGamesViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQGamesViewController.h"
#import "IQGameTableViewCell.h"
#import "IQSettings.h"
#import "IQGameLobyViewController.h"
#import "DataService.h"

@interface IQGamesViewController () <DataServiceDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *game;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *gameID;

@end

@implementation IQGamesViewController

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
    
    self.title = @"Games";
    
    self.gameID = @"";
    self.gameName = @"";
    self.game = [@{} mutableCopy];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(refreshGames) forControlEvents:UIControlEventValueChanged];
//    [self.tableView addSubview:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    [self refreshGames];
//    [self quitGames];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gameLobySegue"]) {
        ((IQGameLobyViewController *)segue.destinationViewController).game = self.game;
    }
}

#pragma mark - Action Methods

- (IBAction)newGameButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"newGameSegue" sender:nil];
}


#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.games[@"games"] == nil || [self.games[@"games"] count] < 1) {
        return 1;
    } else {
        return [self.games[@"games"] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQGameTableViewCell *cell = (IQGameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
    
    if (self.games[@"games"] == nil || [self.games[@"games"] count] < 1) {
        cell.gameLabel.text = @"No games available";
        cell.playersToStartLabel.text = @"";
        
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.gameLabel.text = self.games[@"games"][indexPath.row][@"name"];
        cell.playersToStartLabel.text = [NSString stringWithFormat:@"Players to start: %@", self.games[@"games"][indexPath.row][@"players_to_start"]];
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.gameLabel.textColor = [UIColor whiteColor];
    cell.playersToStartLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.gameID = self.games[@"games"][indexPath.row][@"id"];
    self.gameName = self.games[@"games"][indexPath.row][@"name"];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.games[@"games"][indexPath.row][@"password"] isEqualToString:@""] || self.games[@"games"][indexPath.row][@"password"] == nil) {
        if ([[IQSettings sharedInstance] internetAvailable]) {
            [[IQSettings sharedInstance] showHud:@"" onView:self.view];
            [self openGame];
        } else {
            [self showAlertWithTitle:@"Error" message:@"No internet connection." cancelButton:@"OK"];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Private game!" message:@"Enter password to join" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert show];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
}

#pragma mark - Private Methods

- (void)quitGames
{
    if ([[IQSettings sharedInstance] internetAvailable]) {
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
        [self performSelectorInBackground:@selector(doQuitGame) withObject:nil];
    } else {
        [self showAlertWithTitle:@"Error" message:@"No internet connection." cancelButton:@"OK"];
    }
}

- (void)refreshGames
{
    if ([[IQSettings sharedInstance] internetAvailable]) {
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[IQGamesViewController class]]) {
            [self performSelectorInBackground:@selector(doGetGames) withObject:nil];
        }
    } else {
        [self dataServiceError:self errorMessage:@"No internet connection."];
    }
}

- (void)openGame
{
    [self performSelectorInBackground:@selector(doOpenGame) withObject:nil];
}

- (void)doQuitGame
{
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService quitGame];
}

- (void)doGetGames
{
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService getGames];
}

- (void)doOpenGame
{
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService openGame:self.gameID];
}

#pragma mark - Service delegates

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
    });
}

- (void)dataServiceQuitGame:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL quitGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        quitGameSuccessfull = NO;
    
    if (quitGameSuccessfull) {
        if ([[IQSettings sharedInstance] internetAvailable]) {
            [self doGetGames];
        } else {
            [self dataServiceError:self errorMessage:@"No internet connection."];
        }
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
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
            
            [self.tableView reloadData];
            
            [self performSelector:@selector(refreshGames) withObject:nil afterDelay:([self.games[@"refresh_interval"] intValue] / 1000)];
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

- (void)dataServiceOpenGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL openGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        openGameSuccessfull = NO;
    
    if (openGameSuccessfull) {
        if ([[IQSettings sharedInstance] internetAvailable]) {
            DataService *dService = [[DataService alloc] init];
            dService.delegate = self;
            [dService refreshGame:self.gameID];
        } else {
            [self dataServiceError:self errorMessage:@"No internet connection."];
        }
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

- (void)dataServiceRefreshGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL refreshGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        refreshGameSuccessfull = NO;
    
    if (refreshGameSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
            
            self.game = [j mutableCopy];
            [self.game setValue:self.gameID forKey:@"id"];
            [self.game setValue:self.gameName forKey:@"name"];
            
            [self performSegueWithIdentifier:@"gameLobySegue" sender:nil];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
        });
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Alert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField * alertTextField = [alertView textFieldAtIndex:0];
    if (buttonIndex == 1) {
        for (NSDictionary *game in self.games[@"games"]) {
            if ([game[@"name"] isEqualToString:self.gameName]) {
                if ([alertTextField.text isEqualToString:game[@"password"]]) {
                    [self openGame];
                } else {
                    [self showAlertWithTitle:@"Error" message:@"Wrong password!" cancelButton:@"OK"];
                }
                break;
            }
        }
    }
}

@end
