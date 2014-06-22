//
//  IQResultViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 5/5/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQResultViewController.h"
#import "DataService.h"
#import "IQGamesViewController.h"
#import "IQSettings.h"

@interface IQResultViewController () <DataServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;

@property (nonatomic, strong) NSDictionary *result;

@end

@implementation IQResultViewController

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
    
    self.title = @"Result";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self performSelectorInBackground:@selector(doShowResult) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)doShowResult
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService showResult];
}

#pragma mark - Service delegates

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
    });
}

- (void)dataServiceResultFinished:(id)sender withData:(NSData *)data
{
    //TODO: kakvo vrashta zaqvkata
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL resultSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        resultSuccessfull = NO;
    
    if (resultSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
            self.result = j;
            [self updateUI];
        });
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

#pragma mark - Action Methods

- (IBAction)homeScreenButtonTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)chooseNewGameButtonTapped:(id)sender
{
//TODO:opravi tuka, move games kontrollera da ne e v nav controlera
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[IQGamesViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

#pragma mark - Private Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

- (void)updateUI
{
    if ([self.result[@"users"] count] > 0 && ![self.result[@"users"][0][@"name"] isEqualToString:@""]) {
        self.player1Label.text = [NSString stringWithFormat:@"%@: %@", self.result[@"users"][0][@"name"], self.result[@"users"][0][@"points"]];
    } else {
        self.player1Label.text = @"";
    }
    if ([self.result[@"users"] count] > 1 && ![self.result[@"users"][1][@"name"] isEqualToString:@""]) {
        self.player2Label.text = [NSString stringWithFormat:@"%@: %@", self.result[@"users"][1][@"name"], self.result[@"users"][1][@"points"]];
    } else {
        self.player2Label.text = @"";
    }
    if ([self.result[@"users"] count] > 2 && ![self.result[@"users"][2][@"name"] isEqualToString:@""]) {
        self.player3Label.text = [NSString stringWithFormat:@"%@: %@", self.result[@"users"][2][@"name"], self.result[@"users"][2][@"points"]];
    } else {
        self.player3Label.text = @"";
    }
    
    self.player1Label.textColor = [UIColor greenColor];
    self.player2Label.textColor = [UIColor redColor];
    self.player3Label.textColor = [UIColor redColor];
}

@end
