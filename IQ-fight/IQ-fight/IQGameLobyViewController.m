//
//  IQGameLobyViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQGameLobyViewController.h"
#import "IQServerCommunication.h"
#import "IQSettings.h"
#import "IQGameViewController.h"
#import "DataService.h"

@interface IQGameLobyViewController () <DataServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;
@property (weak, nonatomic) IBOutlet UILabel *questionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePerQuestionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;

@property (nonatomic, strong) IQServerCommunication *sv;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timerToStart;
@property (nonatomic, assign) NSInteger timeToStart;

@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *gameID;

@property (nonatomic, strong) NSDictionary *play;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"playGameSegue"]) {
        ((IQGameViewController *)segue.destinationViewController).play = self.play;
    }
}

- (void)refreshGame
{
    [self performSelectorInBackground:@selector(doRefreshGame) withObject:nil];
}

- (void)doRefreshGame
{
    //DataService *dService = [IQSettings sharedInstance].dService;
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService refreshGame:self.gameID];
}

- (void)startGame
{
    //DataService *dService = [IQSettings sharedInstance].dService;
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService playGame];
}

#pragma mark - Service delegates

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

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
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
            
            if ([j[@"players_to_start"] intValue] != 0) {
                self.timeToStartLabel.hidden = NO;
                self.timeToStart = 5;
                self.timeToStartLabel.text = [NSString stringWithFormat:@"Game will start in: %d", self.timeToStart];
                [self performSelector:@selector(updateTimeLabel) withObject:nil afterDelay:1];
            } else {
                if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[IQGameLobyViewController class]]) {
                    [self performSelector:@selector(refreshGame) withObject:nil afterDelay:([self.game[@"refresh_interval"] intValue] / 1000)];
                }
            }
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

//expected request responce
//{
//    'refresh_interval':1000,
//    'question':[],
//    'answers':[],
//    'users':['user1','user2'],
//    'remaing_time':53*1000,
//    'answered_user':'',
//    'status':ok/error,
//    'error_message':''
//}


//'answers':[{
//          'answer':'TEj',
//          'id':90
//          }]

//'question':{
//    'question':'Tuk e tekst',
//    'explanation':'Pak tekst',
//    'picture':'Tuk e tekst NO s URL do snimkata'
//}

- (void)dataServicePlayGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL playGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        playGameSuccessfull = NO;
    
    if (playGameSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.play = j;
            [self performSegueWithIdentifier:@"playGameSegue" sender:nil];
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

#pragma mark - Private Methods

- (void)updateTimeLabel
{
//    if (self.timeToStart > 0) {
//        self.timeToStartLabel.text = [NSString stringWithFormat:@"Game will start in: %d", self.timeToStart - 1];
//        self.timeToStart--;
//        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[IQGameLobyViewController class]]) {
//            [self performSelector:@selector(updateTimeLabel) withObject:nil afterDelay:1];
//        }
//    } else {
        [self performSelectorInBackground:@selector(startGame) withObject:nil];
//    }
}

- (void)updateUI
{
    if ([self.game[@"users"] count] > 0 && ![self.game[@"users"][0] isEqualToString:@""]) {
        self.player1Label.text = self.game[@"users"][0];
    } else {
        self.player1Label.text = @"Waiting for player 1.";
    }
    
    if ([self.game[@"users"] count] > 1 && ![self.game[@"users"][1] isEqualToString:@""]) {
        self.player2Label.text = self.game[@"users"][1];
    } else {
        self.player2Label.text = @"Waiting for player 2.";
    }
    
    if ([self.game[@"users"] count] > 2 && ![self.game[@"users"][2] isEqualToString:@""]) {
        self.player3Label.text = self.game[@"users"][2];
    } else {
        self.player3Label.text = @"Waiting for player 3.";
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

@end
