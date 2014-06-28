//
//  IQGameLobyViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQGameLobyViewController.h"
#import "IQSettings.h"
#import "IQGameViewController.h"
#import "DataService.h"
#import "IQGamesViewController.h"

@interface IQGameLobyViewController () <DataServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;
@property (weak, nonatomic) IBOutlet UILabel *questionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePerQuestionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;

@property (nonatomic, assign) NSInteger timeToStart;

@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *gameID;

@end

@implementation IQGameLobyViewController

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
    
    self.title = @"Prepare for game";
    self.gameNameLabel.text = self.game[@"name"];
    
    self.gameName = self.game[@"name"];
    self.gameID = self.game[@"id"];
    
    self.timeToStartLabel.hidden = YES;
    
    [self updateUI];
    
    [self performSelector:@selector(refreshGame) withObject:nil afterDelay:([self.game[@"refresh_interval"] intValue] / 1000)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshGame
{
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[IQGameLobyViewController class]]) {
        [self performSelectorInBackground:@selector(doRefreshGame) withObject:nil];
    }
}

- (void)doRefreshGame
{
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService refreshGame:self.gameID];
}

- (void)startGame
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService playGame];
}

#pragma mark - Service delegates

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
        
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
    });
}

- (void)dataServiceRefreshGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL refreshGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        refreshGameSuccessfull = NO;
    
    if (refreshGameSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.game = j;
            [self updateUI];
            
            if ([j[@"players_to_start"] intValue] == 0) {
                self.timeToStartLabel.hidden = NO;
                self.timeToStart = 5;
                self.timeToStartLabel.text = [NSString stringWithFormat:@"Game will start in: %d", self.timeToStart];
                [self performSelector:@selector(updateTimeLabel) withObject:nil afterDelay:1];
            } else {
                [self performSelector:@selector(refreshGame) withObject:nil afterDelay:([self.game[@"refresh_interval"] intValue] / 1000)];
            }
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

- (void)dataServicePlayGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL playGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        playGameSuccessfull = NO;
    
    if (playGameSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            IQGameViewController *gameVC = [storyboard instantiateViewControllerWithIdentifier:@"GameViewController"];
            gameVC.play = j;
            NSMutableArray *vsc = [self.navigationController.viewControllers mutableCopy];
            [vsc removeLastObject];
            [vsc addObject:gameVC];
            [self.navigationController setViewControllers:vsc animated:YES];
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

#pragma mark - Private Methods

- (void)updateTimeLabel
{
    if (self.timeToStart > 1) {
        self.timeToStartLabel.text = [NSString stringWithFormat:@"Game will start in: %d", self.timeToStart - 1];
        self.timeToStart--;
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[IQGameLobyViewController class]]) {
            [self performSelector:@selector(updateTimeLabel) withObject:nil afterDelay:1];
        }
    } else {
        [self performSelectorInBackground:@selector(startGame) withObject:nil];
    }
}

- (void)updateUI
{
    if ([self.game[@"users"] count] > 0 && ![self.game[@"users"][0] isEqualToString:@""]) {
        self.player1Label.text = self.game[@"users"][0];
    } else {
        self.player1Label.text = @"Waiting for player 1...";
    }
    
    if ([self.game[@"users"] count] > 1 && ![self.game[@"users"][1] isEqualToString:@""]) {
        self.player2Label.text = self.game[@"users"][1];
    } else {
        self.player2Label.text = @"Waiting for player 2...";
    }
    
    if ([self.game[@"users"] count] > 2 && ![self.game[@"users"][2] isEqualToString:@""]) {
        self.player3Label.text = self.game[@"users"][2];
    } else {
        self.player3Label.text = @"Waiting for player 3...";
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

@end
