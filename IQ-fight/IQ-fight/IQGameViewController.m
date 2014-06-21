//
//  IQGameViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQGameViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DataService.h"
#import "IQSettings.h"
#import "UITextView+convertSizeToFit.h"
#import "IQHomeViewController.h"

@interface IQGameViewController () <DataServiceDelegate>

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
@property (weak, nonatomic) IBOutlet UIImageView *answer1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *answer2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *answer3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *answer4ImageView;

@end

@implementation IQGameViewController

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
    
    [self refreshQuestion];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.answer1Button.titleLabel.text = @"";
    self.answer2Button.titleLabel.text = @"";
    self.answer3Button.titleLabel.text = @"";
    self.answer4Button.titleLabel.text = @"";
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshQuestion
{
    [self performSelectorInBackground:@selector(doRefreshQuestion) withObject:nil];
}

- (void)doRefreshQuestion
{
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService playGame];
}

- (void)doAnswer:(UIButton *)button
{
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService answerQuestion:[NSString stringWithFormat:@"%d", button.tag]];
}

#pragma mark - Service delegates

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.answer1Button.enabled) {
            [self enableButtons:YES];
        }
        
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[IQHomeViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    });
}

- (void)dataServicePlayGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL refreshQuestionSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        refreshQuestionSuccessfull = NO;
    
    if (refreshQuestionSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.play = j;
            
            [self updateUI];
            
            [self performSelector:@selector(refreshQuestion) withObject:nil afterDelay:1.0];
        });
    } else {
        if ([j[@"error_message"] isEqualToString:@"Game over"]) {
            [self performSegueWithIdentifier:@"resultSegue" sender:nil];
        } else {
            [self dataServiceError:self errorMessage:j[@"error_message"]];
        }
    }
}

- (void)dataServiceAnswerQuestionFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL answerQuestionSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        answerQuestionSuccessfull = NO;
    
    if (answerQuestionSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enableButtons:YES];
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

#pragma mark - Action Methods

- (IBAction)answerButtonTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self enableButtons:NO];
    [self performSelectorInBackground:@selector(doAnswer:) withObject:button];
}

#pragma mark - Private Methods

- (void)updateUI
{
//trqbva da polucha nomer na vaprosa
    //self.title = self.play[@""];
    
    if ([self.play[@"users"] count] > 0 && ![self.play[@"users"][0][@"name"] isEqualToString:@""]) {
        self.player1Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][0][@"name"], self.play[@"users"][0][@"points"]];
    } else {
        self.player1Label.text = @"";
    }
    if ([self.play[@"users"] count] > 1 && ![self.play[@"users"][1][@"name"] isEqualToString:@""]) {
        self.player2Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][1][@"name"], self.play[@"users"][1][@"points"]];
    } else {
        self.player2Label.text = @"";
    }
    if ([self.play[@"users"] count] > 2 && ![self.play[@"users"][2][@"name"] isEqualToString:@""]) {
        self.player3Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][2][@"name"], self.play[@"users"][2][@"points"]];
    } else {
        self.player3Label.text = @"";
    }
    
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Time left: %d", ([self.play[@"remaing_time"] intValue] / 1000)];
    
    self.questionTextView.text = self.play[@"question"][@"question"];
    self.questionTextView.font = [UIFont boldSystemFontOfSize:14.0];
    [self.questionTextView convertSizeToFit];
    
    if ([self.play[@"question"][@"picture"] isEqualToString:@""] || self.play[@"question"][@"picture"] == nil) {
        self.questionImageView.hidden = YES;
        self.questionImageView.frame = CGRectMake(10, 146, CGRectGetWidth(self.questionImageView.frame), 1);
        self.answer1Button.frame = CGRectMake(10, CGRectGetMaxY(self.questionTextView.frame), CGRectGetWidth(self.answer1Button.frame), CGRectGetHeight(self.answer1Button.frame));
        self.answer2Button.frame = CGRectMake(162, CGRectGetMaxY(self.questionTextView.frame), CGRectGetWidth(self.answer2Button.frame), CGRectGetHeight(self.answer2Button.frame));
        self.answer3Button.frame = CGRectMake(10, CGRectGetMaxY(self.answer1Button.frame) + 4, CGRectGetWidth(self.answer3Button.frame), CGRectGetHeight(self.answer3Button.frame));
        self.answer4Button.frame = CGRectMake(162, CGRectGetMaxY(self.answer2Button.frame) + 4, CGRectGetWidth(self.answer4Button.frame), CGRectGetHeight(self.answer4Button.frame));
        self.answer1ImageView.frame = self.answer1Button.frame;
        self.answer2ImageView.frame = self.answer2Button.frame;
        self.answer3ImageView.frame = self.answer3Button.frame;
        self.answer4ImageView.frame = self.answer4Button.frame;
    } else {
        self.questionImageView.hidden = NO;
        self.questionImageView.frame = CGRectMake(10, CGRectGetMaxY(self.questionTextView.frame) - 3, CGRectGetWidth(self.questionImageView.frame), 140);
        NSString *pictureURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, self.play[@"question"][@"picture"]];
        [self.questionImageView setImageWithURL:[NSURL URLWithString:pictureURLString]];
        
        self.answer1Button.frame = CGRectMake(10, CGRectGetMaxY(self.questionImageView.frame) + 4, CGRectGetWidth(self.answer1Button.frame), CGRectGetHeight(self.answer1Button.frame));
        self.answer2Button.frame = CGRectMake(162, CGRectGetMaxY(self.questionImageView.frame) + 4, CGRectGetWidth(self.answer2Button.frame), CGRectGetHeight(self.answer2Button.frame));
        self.answer3Button.frame = CGRectMake(10, CGRectGetMaxY(self.answer1Button.frame) + 4, CGRectGetWidth(self.answer3Button.frame), CGRectGetHeight(self.answer3Button.frame));
        self.answer4Button.frame = CGRectMake(162, CGRectGetMaxY(self.answer2Button.frame) + 4, CGRectGetWidth(self.answer4Button.frame), CGRectGetHeight(self.answer4Button.frame));
        self.answer1ImageView.frame = self.answer1Button.frame;
        self.answer2ImageView.frame = self.answer2Button.frame;
        self.answer3ImageView.frame = self.answer3Button.frame;
        self.answer4ImageView.frame = self.answer4Button.frame;
    }
    
    if (self.play[@"answers"] != nil && [self.play[@"answers"] count] > 0) {
        NSArray *answers = self.play[@"answers"];
        if ([answers[0][@"picture"] isEqualToString:@""]) {
            [self.answer1Button setTitle:answers[0][@"answer"] forState:UIControlStateNormal];
            self.answer1ImageView.image = nil;
        } else {
            [self.answer1Button setTitle:@"" forState:UIControlStateNormal];
            NSString *answerURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, answers[0][@"picture"]];
            [self.answer1ImageView setImageWithURL:[NSURL URLWithString:answerURLString]];
        }
        if ([answers[1][@"picture"] isEqualToString:@""]) {
            [self.answer2Button setTitle:answers[1][@"answer"] forState:UIControlStateNormal];
            self.answer2ImageView.image = nil;
        } else {
            [self.answer2Button setTitle:@"" forState:UIControlStateNormal];
            NSString *answerURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, answers[1][@"picture"]];
            [self.answer2ImageView setImageWithURL:[NSURL URLWithString:answerURLString]];
        }
        if ([answers[2][@"picture"] isEqualToString:@""]) {
            [self.answer3Button setTitle:answers[2][@"answer"] forState:UIControlStateNormal];
            self.answer3ImageView.image = nil;
        } else {
            [self.answer3Button setTitle:@"" forState:UIControlStateNormal];
            NSString *answerURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, answers[2][@"picture"]];
            [self.answer3ImageView setImageWithURL:[NSURL URLWithString:answerURLString]];
        }
        if ([answers[3][@"picture"] isEqualToString:@""]) {
            [self.answer4Button setTitle:answers[3][@"answer"] forState:UIControlStateNormal];
            self.answer4ImageView.image = nil;
        } else {
            [self.answer4Button setTitle:@"" forState:UIControlStateNormal];
            NSString *answerURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, answers[3][@"picture"]];
            [self.answer4ImageView setImageWithURL:[NSURL URLWithString:answerURLString]];
        }
        
        self.answer1Button.tag = [answers[0][@"id"] intValue];
        self.answer2Button.tag = [answers[1][@"id"] intValue];
        self.answer3Button.tag = [answers[2][@"id"] intValue];
        self.answer4Button.tag = [answers[3][@"id"] intValue];
    }
    
//trqbva mi nomera na vaprosa
    if ([self.play[@"answered_user"] isEqualToString:@""]) {
        self.infoLabel.text = @"";
        self.infoLabel.hidden = YES;
    } else if ([self.play[@"answered_user"] isEqualToString:@"Nobody"]) {
        self.infoLabel.text = [NSString stringWithFormat:@"Nobody answered correct on the previous question"];
        self.infoLabel.hidden = NO;
        [self performSelector:@selector(hideInfoLabel) withObject:nil afterDelay:10];
    } else if (![self.play[@"answered_user"] isEqualToString:[IQSettings sharedInstance].currentUser.username]) {
        self.infoLabel.text = [NSString stringWithFormat:@"%@ answered correct on the previous question", self.play[@"answered_user"]];
        self.infoLabel.hidden = NO;
    } else {
        self.infoLabel.text = @"You answered correct on the previous question";
        self.infoLabel.hidden = NO;
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

- (void)hideInfoLabel
{
    self.infoLabel.hidden = YES;
}

- (void)enableButtons:(BOOL)enable
{
    self.answer1Button.enabled = enable;
    self.answer2Button.enabled = enable;
    self.answer3Button.enabled = enable;
    self.answer4Button.enabled = enable;
}

@end
