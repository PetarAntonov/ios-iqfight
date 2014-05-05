//
//  IQGameViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQGameViewController.h"
#import "UIImageView+AFNetworking.h"
#import "IQServerCommunication.h"

@interface IQGameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (strong, nonatomic) IBOutlet UIImageView *questionImageView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UIButton *answer1Button;
@property (weak, nonatomic) IBOutlet UIButton *answer2Button;
@property (weak, nonatomic) IBOutlet UIButton *answer3Button;
@property (weak, nonatomic) IBOutlet UIButton *answer4Button;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) IQServerCommunication *sv;

@end

@implementation IQGameViewController

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
    
    [self updateUI];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:([self.play[@"refresh_interval"] intValue] / 1000) target:self selector:@selector(refreshQuestion) userInfo:nil repeats:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //izvikai zaqvkata za vapros
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)answerButtonTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (self.sv == nil) {
        self.sv = [[IQServerCommunication alloc] init];
    }
    
    [self.sv answerQuestion:[NSString stringWithFormat:@"%d", button.tag]  withCompletion:^(id result, NSError *error) {
        //kakvo stava kato izbera otgovor
        if (result) {
            
        } else {
            [self.timer invalidate];
            self.timer = nil;
            
            [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
        }
    }];
    
}

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

//Answered user:''/Nobody/'sss@ww.com'

#pragma mark - Private Methods

- (void)updateUI
{
//trqbva da polucha nomer na vaprosa
    self.title = self.play[@""];
    
    self.player1Label.text = self.play[@"users"][0];
    self.player2Label.text = self.play[@"users"][1];
    self.player3Label.text = self.play[@"users"][2];
    
/* ako ima i rezultat za tekushtiq igrach
    self.player1Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][0][0], self.play[@"users"][0][1]];
    self.player2Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][1][0], self.play[@"users"][1][1]];
    self.player3Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][2][0], self.play[@"users"][2][1]];
*/
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Time left: %d", ([self.play[@"remaing_time"] intValue] / 1000)];
    self.questionTextView.text = self.play[@"question"][@"question"];
    self.answer1Button.titleLabel.text = self.play[@"answers"][0][@"answer"];
    self.answer2Button.titleLabel.text = self.play[@"answers"][1][@"answer"];
    self.answer3Button.titleLabel.text = self.play[@"answers"][2][@"answer"];
    self.answer4Button.titleLabel.text = self.play[@"answers"][3][@"answer"];
    
    self.answer1Button.tag = [self.play[@"answers"][0][@"id"] intValue];
    self.answer2Button.tag = [self.play[@"answers"][1][@"id"] intValue];
    self.answer3Button.tag = [self.play[@"answers"][2][@"id"] intValue];
    self.answer4Button.tag = [self.play[@"answers"][3][@"id"] intValue];
    
//trqbva mi nomera na vaprosa
    if ([self.play[@"answered_user"] isEqualToString:@""]) {
        self.infoLabel.text = @"";
        self.infoLabel.hidden = YES;
    } else if ([self.play[@"answered_user"] isEqualToString:@"Nobody"]) {
        self.infoLabel.text = [NSString stringWithFormat:@"Nobody answer correct on question %d", [self.play[@"question_number"] intValue] - 1];
        self.infoLabel.hidden = NO;
    } else {
        self.infoLabel.text = [NSString stringWithFormat:@"%@ answer correct on question %d", self.play[@"answered_user"], [self.play[@"question_number"] intValue] - 1];
        self.infoLabel.hidden = NO;
    }
    
    if (![self.play[@"question"][@"picture"] isEqualToString:@""]) {
        self.questionImageView.hidden = NO;
        self.questionImageView.frame = CGRectMake(20, 78, CGRectGetWidth(self.questionImageView.frame), 140);
        [self.questionImageView setImageWithURL:[NSURL URLWithString:self.play[@"question"][@"picture"]]];
        
        int height = CGRectGetHeight(self.questionTextView.frame);
        [self.questionTextView sizeToFit];
        if (CGRectGetHeight(self.questionTextView.frame) > height) {
            self.questionTextView.frame = CGRectMake(20, 226, CGRectGetWidth(self.questionTextView.frame), height);
        } else {
            self.questionTextView.frame = CGRectMake(20, 226, CGRectGetWidth(self.questionTextView.frame), CGRectGetHeight(self.questionTextView.frame));
        }
        
        self.answer1Button.frame = CGRectMake(20, CGRectGetMaxX(self.questionTextView.frame) + 8, CGRectGetWidth(self.answer1Button.frame), CGRectGetHeight(self.answer1Button.frame));
        self.answer2Button.frame = CGRectMake(20, CGRectGetMaxX(self.questionTextView.frame) + 8, CGRectGetWidth(self.answer2Button.frame), CGRectGetHeight(self.answer2Button.frame));
        self.answer3Button.frame = CGRectMake(20, CGRectGetMaxX(self.answer1Button.frame) + 8, CGRectGetWidth(self.answer3Button.frame), CGRectGetHeight(self.answer3Button.frame));
        self.answer4Button.frame = CGRectMake(20, CGRectGetMaxX(self.answer2Button.frame) + 8, CGRectGetWidth(self.answer4Button.frame), CGRectGetHeight(self.answer4Button.frame));
    } else {
        self.questionImageView.hidden = YES;
        self.questionImageView.frame = CGRectMake(20, 78, CGRectGetWidth(self.questionImageView.frame), 1);
        self.questionTextView.frame = CGRectMake(20, 78, CGRectGetWidth(self.questionTextView.frame), CGRectGetHeight(self.questionTextView.frame));
        self.answer1Button.frame = CGRectMake(20, 190, CGRectGetWidth(self.answer1Button.frame), CGRectGetHeight(self.answer1Button.frame));
        self.answer2Button.frame = CGRectMake(164, 190, CGRectGetWidth(self.answer2Button.frame), CGRectGetHeight(self.answer2Button.frame));
        self.answer3Button.frame = CGRectMake(20, 248, CGRectGetWidth(self.answer3Button.frame), CGRectGetHeight(self.answer3Button.frame));
        self.answer4Button.frame = CGRectMake(164, 248, CGRectGetWidth(self.answer4Button.frame), CGRectGetHeight(self.answer4Button.frame));
    }
}

- (void)refreshQuestion
{
    if (self.sv == nil) {
        self.sv = [[IQServerCommunication alloc] init];
    }
    
    [self.sv playGameWithCompletion:^(id result, NSError *error) {
        if (result) {
            self.play = result;
            
            [self.timer invalidate];
            self.timer = nil;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:([self.play[@"refresh_interval"] intValue] / 1000) target:self selector:@selector(refreshQuestion) userInfo:nil repeats:YES];
            
            [self updateUI];
        } else {
            [self.timer invalidate];
            self.timer = nil;
            
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
