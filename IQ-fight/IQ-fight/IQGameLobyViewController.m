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

@interface IQGameLobyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;
@property (weak, nonatomic) IBOutlet UILabel *questionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePerQuestionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToStartLabel;

@property (nonatomic, strong) IQServerCommunication *sv;
@property (nonatomic, strong) NSDictionary *gameInfo;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timerToStart;
@property (nonatomic, assign) NSInteger timeToStart;

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
    
    self.title = @"Game loby";

    //TODO: setni UI
    //zaqvka da updaitva igrata
    //kogato ima igra4i se otvarq prozoreca za igra
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.timeToStart = 5;
    
    [self getGame];
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

- (void)getGame
{
    if (self.sv == nil) {
        self.sv = [[IQServerCommunication alloc] init];
    }
    
    [self.sv openGameWithCompletion:^(id result, NSError *error) {
        //po kakvo shte se proverqva?
        if (result) {
            //ima rezultata
            self.gameInfo = result;
            self.player1Label.text = self.gameInfo[@"players"][0];
            self.player2Label.text = self.gameInfo[@"players"][0];
            self.player3Label.text = self.gameInfo[@"players"][0];
            self.questionsLabel = self.gameInfo[@"questions"];
            self.timePerQuestionLabel = self.gameInfo[@"time"];
            self.timeToStartLabel.hidden = YES;
            
            if ([result[@"players_to_start"] intValue] == 0) {
                //ako ima 3ma igrachi i igrata trqbva da zapochne
                self.timeToStartLabel.hidden = NO;
                self.timeToStart = 5;
                self.timeToStartLabel.text = [NSString stringWithFormat:@"Game will start in: %d", self.timeToStart];
                
                [self.timer invalidate];
                self.timer = nil;
                
                self.timerToStart = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
                
                
            } else {
                //ako nqma dostatachno igrachi i trqbva da se chaka
//                if (self.timer == nil) {
//                    self.timer = [NSTimer scheduledTimerWithTimeInterval:result["refresh_interval"] target:self selector:@selector(getGame) userInfo:nil repeats:YES];
//                }

            }
        } else {
            //greshka ot servara
            [[IQSettings sharedInstance] hideHud:self.view];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Server error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)updateTimeLabel
{
    if (self.timeToStart > 0) {
        self.timeToStartLabel.text = [NSString stringWithFormat:@"Game will start in: %d", self.timeToStart - 1];
    } else {
        [self performSegueWithIdentifier:@"playGameSegue" sender:nil];
    }
}

@end
