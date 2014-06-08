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

@interface IQGamesViewController () <DataServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *game;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, assign) BOOL canRefresh;

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
    
    self.canRefresh = YES;
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
    
    [self performSelector:@selector(refreshGames) withObject:nil afterDelay:([self.games[@"refresh_interval"] intValue] / 1000)];
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

#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.games[@"games"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQGameTableViewCell *cell = (IQGameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
    
    cell.gameLabel.text = self.games[@"games"][indexPath.row][@"name"];
    cell.playersToStartLabel.text = [NSString stringWithFormat:@"Players to start: %@", self.games[@"games"][indexPath.row][@"players_to_start"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.canRefresh = NO;
    self.gameID = self.games[@"games"][indexPath.row][@"id"];
    self.gameName = self.games[@"games"][indexPath.row][@"name"];
    [self performSelectorInBackground:@selector(doQuitGame) withObject:nil];
}

#pragma mark - Private Methods

- (void)refreshGames
{
    [self performSelectorInBackground:@selector(doGetGames) withObject:nil];
}

- (void)doGetGames
{
    //DataService *dService = [IQSettings sharedInstance].dService;
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService getGames];
}

- (void)doQuitGame
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    //DataService *dService = [IQSettings sharedInstance].dService;
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService quitGame];
}

#pragma mark - Service delegates

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
    });
}

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
            if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[IQGamesViewController class]]) {
                [self performSelector:@selector(refreshGames) withObject:nil afterDelay:([self.games[@"refresh_interval"] intValue] / 1000)];
            }
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}
//expected request responce
//{
//    'status': ok,
//    'error_message':''
//}

- (void)dataServiceQuitGame:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL quitGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        quitGameSuccessfull = NO;
    
    if (quitGameSuccessfull) {
        //DataService *dService = [IQSettings sharedInstance].dService;
        DataService *dService = [[DataService alloc] init];
        dService.delegate = self;
        [dService openGame:self.gameID];
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

//expected request responce
//{
//    'players_to_start':2,
//    status:ok/error,
//    'error_message':''
//}

- (void)dataServiceOpenGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL openGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        openGameSuccessfull = NO;
    
    if (openGameSuccessfull) {
        //DataService *dService = [IQSettings sharedInstance].dService;
        DataService *dService = [[DataService alloc] init];
        dService.delegate = self;
        [dService refreshGame:self.gameID];
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

//expected request responce
//{
//    'players_to_start':1,
//    'users':['user1',
//             'user2'
//             ],
//    'refresh_interval':1000ms,
//    'status':'ok/error',
//    'error_message':''
//}

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

@end
