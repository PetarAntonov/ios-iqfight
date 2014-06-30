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
#import "IQGamesViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "IQResultViewController.h"

@interface IQGameViewController () <DataServiceDelegate>

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
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
//@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *answer1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *answer2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *answer3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *answer4ImageView;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (nonatomic, assign) int prQuestionNumber;
@property (nonatomic, strong) NSArray *stats;

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
    
    self.questionTextView.selectable = NO;
    
    [self refreshQuestion];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.answer1Button.titleLabel.text = @"";
    self.answer2Button.titleLabel.text = @"";
    self.answer3Button.titleLabel.text = @"";
    self.answer4Button.titleLabel.text = @"";
    
    self.prQuestionNumber = 0;
    
//    self.infoLabel.hidden = YES;
    self.infoTextView.text = @"";
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"resultSegue"]) {
        ((IQResultViewController *)segue.destinationViewController).stats = self.stats;
    }
}

- (void)refreshQuestion
{
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[IQGameViewController class]]) {
        if ([[IQSettings sharedInstance] internetAvailable]) {
            [self performSelectorInBackground:@selector(doRefreshQuestion) withObject:nil];
        } else {
            [self showAlertWithTitle:@"Error" message:@"No internet connection." cancelButton:@"OK"];
        }
    }
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

- (void)doStatisticks
{
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService showResult:self.gameID];
}

#pragma mark - Service delegates

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
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
            
            if ([j[@"game_over"] boolValue]) {
                if ([[IQSettings sharedInstance] internetAvailable]) {
                    [[IQSettings sharedInstance] showHud:@"" onView:self.view];
                    [self performSelectorInBackground:@selector(doStatisticks) withObject:nil];
                } else {
                    [self showAlertWithTitle:@"Error" message:@"No internet connection." cancelButton:@"OK"];
                }
            } else {
                self.play = j;
                
                [self updateUI];
                
                [self performSelector:@selector(refreshQuestion) withObject:nil afterDelay:1.0];
            }
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
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
            if (![j[@"correct"] boolValue]) {
//                self.infoTextView.text = @"Wrong! Wait until others answer";
//                [self.infoTextView convertSizeToFit];
//                CGSize size = self.scrollView.contentSize;
//                size.height = CGRectGetMaxY(self.infoTextView.frame);
//                self.scrollView.contentSize = size;
//                self.infoLabel.text = [NSString stringWithFormat:@"Wrong! Wait until others answer"];
            }
            
            [self enableButtons:YES];
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

- (void)dataServiceResultFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL statisticsSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        statisticsSuccessfull = NO;
    
    if (statisticsSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
            
            self.stats = j[@"users"];
            [self performSegueWithIdentifier:@"resultSegue" sender:nil];
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

#pragma mark - Action Methods

- (IBAction)answerButtonTapped:(id)sender
{
//    [self performSegueWithIdentifier:@"resultSegue" sender:nil];
    
    if (![self.play[@"is_blocked"] boolValue]) {
        UIButton *button = (UIButton *)sender;
        [self enableButtons:NO];
        
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1].CGColor;
        
        for (UIView *subview in self.scrollView.subviews) {
            if (subview.tag == button.tag) {
                ((UIImageView *)subview).layer.borderWidth = 2.0;
                ((UIImageView *)subview).layer.borderColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1].CGColor;
            }
        }
        
        if ([[IQSettings sharedInstance] internetAvailable]) {
            [self performSelectorInBackground:@selector(doAnswer:) withObject:button];
        } else {
            [self showAlertWithTitle:@"Error" message:@"No internet connection." cancelButton:@"OK"];
        }
    }
}

#pragma mark - Private Methods

- (void)updateUI
{
    int questionNumber = [self.play[@"question"][@"number"] intValue] + 1;
    self.title = [NSString stringWithFormat:@"Question %d", questionNumber] ;
    
    NSMutableArray *points = [@[] mutableCopy];
    if ([self.play[@"users"] count] > 0 && ![self.play[@"users"][0][@"name"] isEqualToString:@""]) {
        self.player1Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][0][@"name"], self.play[@"users"][0][@"points"]];
        [points addObject:@([self.play[@"users"][0][@"points"] intValue])];
    } else {
        self.player1Label.text = @"";
    }
    if ([self.play[@"users"] count] > 1 && ![self.play[@"users"][1][@"name"] isEqualToString:@""]) {
        self.player2Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][1][@"name"], self.play[@"users"][1][@"points"]];
        [points addObject:@([self.play[@"users"][0][@"points"] intValue])];
    } else {
        self.player2Label.text = @"";
    }
    if ([self.play[@"users"] count] > 2 && ![self.play[@"users"][2][@"name"] isEqualToString:@""]) {
        self.player3Label.text = [NSString stringWithFormat:@"%@: %@", self.play[@"users"][2][@"name"], self.play[@"users"][2][@"points"]];
        [points addObject:@([self.play[@"users"][0][@"points"] intValue])];
    } else {
        self.player3Label.text = @"";
    }
    
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Time left: %d", ([self.play[@"remaing_time"] intValue] / 1000)];
    
    self.questionTextView.text = self.play[@"question"][@"question"];
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
    
    self.infoTextView.frame = CGRectMake(CGRectGetMinX(self.infoTextView.frame), CGRectGetMaxY(self.answer4Button.frame), CGRectGetWidth(self.infoTextView.frame),CGRectGetHeight(self.infoTextView.frame));
    
    if (self.play[@"answers"] != nil && [self.play[@"answers"] count] > 0) {
        NSArray *answers = self.play[@"answers"];
        if ([answers[0][@"picture"] isEqualToString:@""]) {
            self.answer1Button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
            [self.answer1Button setTitle:answers[0][@"answer"] forState:UIControlStateNormal];
            self.answer1ImageView.image = nil;
            self.answer1ImageView.hidden = YES;
        } else {
            self.answer1Button.backgroundColor = [UIColor clearColor];
            [self.answer1Button setTitle:@"" forState:UIControlStateNormal];
            NSString *answerURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, answers[0][@"picture"]];
            [self.answer1ImageView setImageWithURL:[NSURL URLWithString:answerURLString]];
            self.answer1ImageView.hidden = NO;
        }
        if ([answers[1][@"picture"] isEqualToString:@""]) {
            self.answer2Button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
            [self.answer2Button setTitle:answers[1][@"answer"] forState:UIControlStateNormal];
            self.answer2ImageView.image = nil;
            self.answer2ImageView.hidden = YES;
        } else {
            self.answer2Button.backgroundColor = [UIColor clearColor];
            [self.answer2Button setTitle:@"" forState:UIControlStateNormal];
            NSString *answerURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, answers[1][@"picture"]];
            [self.answer2ImageView setImageWithURL:[NSURL URLWithString:answerURLString]];
            self.answer2ImageView.hidden = NO;
        }
        if ([answers[2][@"picture"] isEqualToString:@""]) {
            self.answer3Button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
            [self.answer3Button setTitle:answers[2][@"answer"] forState:UIControlStateNormal];
            self.answer3ImageView.image = nil;
            self.answer3ImageView.hidden = YES;
        } else {
            self.answer3Button.backgroundColor = [UIColor clearColor];
            [self.answer3Button setTitle:@"" forState:UIControlStateNormal];
            NSString *answerURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, answers[2][@"picture"]];
            [self.answer3ImageView setImageWithURL:[NSURL URLWithString:answerURLString]];
            self.answer3ImageView.hidden = NO;
        }
        if ([answers[3][@"picture"] isEqualToString:@""]) {
            self.answer4Button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
            [self.answer4Button setTitle:answers[3][@"answer"] forState:UIControlStateNormal];
            self.answer4ImageView.image = nil;
            self.answer4ImageView.hidden = YES;
        } else {
            self.answer4Button.backgroundColor = [UIColor clearColor];
            [self.answer4Button setTitle:@"" forState:UIControlStateNormal];
            NSString *answerURLString = [NSString stringWithFormat:@"%@%@", [IQSettings sharedInstance].servicesURL, answers[3][@"picture"]];
            [self.answer4ImageView setImageWithURL:[NSURL URLWithString:answerURLString]];
            self.answer4ImageView.hidden = NO;
        }
        
        self.answer1Button.tag = [answers[0][@"id"] intValue];
        self.answer2Button.tag = [answers[1][@"id"] intValue];
        self.answer3Button.tag = [answers[2][@"id"] intValue];
        self.answer4Button.tag = [answers[3][@"id"] intValue];
        self.answer1ImageView.tag = [answers[0][@"id"] intValue];
        self.answer2ImageView.tag = [answers[1][@"id"] intValue];
        self.answer3ImageView.tag = [answers[2][@"id"] intValue];
        self.answer4ImageView.tag = [answers[3][@"id"] intValue];
    }
    
    [self updateInfoText];
    
    CGSize size = self.scrollView.contentSize;
    size.height = CGRectGetMaxY(self.infoTextView.frame);
    self.scrollView.contentSize = size;
}

- (void)updateInfoText
{
    if ([self.play[@"answered_user"] isEqualToString:@""]) {
        self.infoTextView.text = @"";
    } else if ([self.play[@"answered_user"] isEqualToString:@"Nobody"]) {
        NSString *explanation;
        if ([self.play[@"question"][@"explanation"] isEqualToString:@""]) {
            explanation = [NSString stringWithFormat:@"No available explanation for this question."];
        } else {
            explanation = self.play[@"question"][@"explanation"];
        }
        self.infoTextView.text = [NSString stringWithFormat:@"Nobody answered correct.\nExplanation: %@", explanation];
    } else if (![self.play[@"answered_user"] isEqualToString:[IQSettings sharedInstance].currentUser.username]) {
        NSString *explanation;
        if ([self.play[@"question"][@"explanation"] isEqualToString:@""]) {
            explanation = [NSString stringWithFormat:@"No available explanation for this question."];
        } else {
            explanation = self.play[@"question"][@"explanation"];
        }
        self.infoTextView.text = [NSString stringWithFormat:@"%@ answered correct.\nExplanation: %@", self.play[@"answered_user"], explanation];
    } else {
        NSString *explanation;
        if ([self.play[@"question"][@"explanation"] isEqualToString:@""]) {
            explanation = [NSString stringWithFormat:@"No available explanation for this question."];
        } else {
            explanation = self.play[@"question"][@"explanation"];
        }
        self.infoTextView.text = [NSString stringWithFormat:@"You answered correct.\nExplanation: %@", explanation];
    }
    
    [self.infoTextView convertSizeToFit];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

//- (void)hideInfoLabel
//{
//    self.infoLabel.hidden = YES;
//}

- (void)enableButtons:(BOOL)enable
{
    self.answer1Button.enabled = enable;
    self.answer2Button.enabled = enable;
    self.answer3Button.enabled = enable;
    self.answer4Button.enabled = enable;
    
    self.answer1Button.layer.borderWidth = 0;
    self.answer2Button.layer.borderWidth = 0;
    self.answer3Button.layer.borderWidth = 0;
    self.answer4Button.layer.borderWidth = 0;
    
    self.answer1ImageView.layer.borderWidth = 0;
    self.answer2ImageView.layer.borderWidth = 0;
    self.answer3ImageView.layer.borderWidth = 0;
    self.answer4ImageView.layer.borderWidth = 0;
}

@end

//NSNumber *max = [points valueForKeyPath:@"@max.intValue"];
//if ([max intValue] > 0) {
//    int index = [points indexOfObject:max];
//    switch (index) {
//        case 0:
//            self.player1Label.font = [UIFont boldSystemFontOfSize:15.0];
//            self.player2Label.font = [UIFont systemFontOfSize:15.0];
//            self.player3Label.font = [UIFont systemFontOfSize:15.0];
//            
//            break;
//        case 1:
//            self.player2Label.font = [UIFont boldSystemFontOfSize:15.0];
//            self.player1Label.font = [UIFont systemFontOfSize:15.0];
//            self.player3Label.font = [UIFont systemFontOfSize:15.0];
//            break;
//        case 2:
//            self.player3Label.font = [UIFont boldSystemFontOfSize:15.0];
//            self.player2Label.font = [UIFont systemFontOfSize:15.0];
//            self.player1Label.font = [UIFont systemFontOfSize:15.0];
//            break;
//        default:
//            self.player1Label.font = [UIFont systemFontOfSize:15.0];
//            self.player2Label.font = [UIFont systemFontOfSize:15.0];
//            self.player3Label.font = [UIFont systemFontOfSize:15.0];
//            break;
//    }
//}

//if ((CGRectGetMaxY(self.answer4Button.frame) + 40) > CGRectGetHeight(self.view.frame)) {
//    CGSize size = self.scrollView.contentSize;
//    size.height = (CGRectGetMaxY(self.answer4Button.frame) + 40);
//    self.scrollView.contentSize = size;
//    self.infoLabel.frame = CGRectMake(CGRectGetMinX(self.infoLabel.frame), CGRectGetMaxY(self.answer4Button.frame) + 8, CGRectGetWidth(self.infoLabel.frame), CGRectGetHeight(self.infoLabel.frame));
//} else {
//    CGSize size = self.scrollView.contentSize;
//    size.height = CGRectGetHeight(self.view.frame);
//    self.scrollView.contentSize = size;
//    self.infoLabel.frame = CGRectMake(CGRectGetMinX(self.infoLabel.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.infoLabel.frame) - 4, CGRectGetWidth(self.infoLabel.frame), CGRectGetHeight(self.infoLabel.frame));
//}

//if ([self.play[@"answered_user"] isEqualToString:@""]) {
//    self.infoLabel.text = @"";
//    //        self.infoLabel.hidden = YES;
//} else if ([self.play[@"answered_user"] isEqualToString:@"Nobody"]) {
//    self.infoLabel.text = @"Nobody answered correct.";
//    //        self.infoLabel.hidden = NO;
//    [self performSelector:@selector(hideInfoLabel) withObject:nil afterDelay:10];
//} else if (![self.play[@"answered_user"] isEqualToString:[IQSettings sharedInstance].currentUser.username]) {
//    self.infoLabel.text = [NSString stringWithFormat:@"%@ answered correct on question %d", self.play[@"answered_user"], [self.play[@"question"][@"number"] intValue]];
//    self.infoLabel.hidden = NO;
//    [self performSelector:@selector(hideInfoLabel) withObject:nil afterDelay:10];
//} else {
//    self.infoLabel.text = [NSString stringWithFormat:@"You answered correct on question %d", [self.play[@"question"][@"number"] intValue]];
//    self.infoLabel.hidden = NO;
//    [self performSelector:@selector(hideInfoLabel) withObject:nil afterDelay:10];
//}

