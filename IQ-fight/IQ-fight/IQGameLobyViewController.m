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

@interface IQGameLobyViewController ()

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

@property (nonatomic, strong) NSDictionary *play;

@end

@implementation IQGameLobyViewController

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
    
    self.title = @"Prepare for game";
    self.gameNameLabel.text = self.gameName;
    
    self.timeToStartLabel.hidden = YES;
    
    [self updateUI];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:([self.game[@"refresh_interval"] intValue] / 1000) target:self selector:@selector(refreshGame) userInfo:nil repeats:YES];
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
    [self.timerToStart invalidate];
    self.timerToStart = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"playGameSegue"]) {
        ((IQGameViewController *)segue.destinationViewController).play = self.play;
    }
}

//{
//    'players_to_start':2,
//    'users':['user1'],
//    'refresh_interval':1000ms,
//    'status':ok/error,
//    'error_message':''
//}

#pragma mark - Private Methods

- (void)refreshGame
{
    if (self.sv == nil) {
        self.sv = [[IQServerCommunication alloc] init];
    }
    
    [self.sv openGame:self.gameID withCompletion:^(id result, NSError *error) {
        if ([result[@"players_to_start"] intValue] >= 0 && [result[@"players_to_start"] intValue] < 3) {
            self.game = result;
            
            [self updateUI];
            
            if ([result[@"players_to_start"] intValue] == 0) {
                self.timeToStartLabel.hidden = NO;
                self.timeToStart = 5;
                self.timeToStartLabel.text = [NSString stringWithFormat:@"Game will start in: %d", self.timeToStart];
                
                [self.timer invalidate];
                self.timer = nil;
                
                self.timerToStart = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
            } else {
                //kakvo stava ako nqma greshka i imam igra4i izvan normata
            }
        } else {
            [self.timer invalidate];
            self.timer = nil;
            
            [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
        }
    }];
}

- (void)updateTimeLabel
{
    if (self.timeToStart > 0) {
        self.timeToStartLabel.text = [NSString stringWithFormat:@"Game will start in: %d", self.timeToStart - 1];
    } else {
        if (self.sv == nil) {
            self.sv = [[IQServerCommunication alloc] init];
        }
        
        [self.sv playGameWithCompletion:^(id result, NSError *error) {
            if (result) {
                self.play = result;
                [self performSegueWithIdentifier:@"playGameSegue" sender:nil];
            } else {
                [self.timerToStart invalidate];
                self.timerToStart = nil;
                
                [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
            }
        }];
        
        
    }
}

- (void)updateUI
{
    if (![self.game[@"users"][0] isEqualToString:@""]) {
        self.player1Label.text = self.game[@"users"][0];
    } else {
        self.player1Label.text = @"Waiting for player 1.";
    }
    
    if (![self.game[@"users"][1] isEqualToString:@""]) {
        self.player2Label.text = self.game[@"users"][1];
    } else {
        self.player2Label.text = @"Waiting for player 2.";
    }
    
    if (![self.game[@"users"][2] isEqualToString:@""]) {
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
