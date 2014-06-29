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
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *gamesButton;

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
    
    self.navigationItem.hidesBackButton = YES;
    
    self.title = @"Results";
    
//    self.stats = @[@{@"usernam": @"peshotest@abv.bg", @"scores": @4},
//                   @{@"usernam": @"peshotest2@abv.bg", @"scores": @1},
//                   @{@"usernam": @"peshotest3@abv.bg", @"scores": @0}];
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action Methods

- (IBAction)homeScreenButtonTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)chooseNewGameButtonTapped:(id)sender
{
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
    if ([[IQSettings sharedInstance].currentUser.username isEqualToString:self.stats[0][@"usernam"]]) {
        self.titleLabel.text = @"You won";
    } else {
        self.titleLabel.text = @"You lose";
    }
    
    if ([self.stats count] > 0 && ![self.stats[0][@"usernam"] isEqualToString:@""]) {
        self.player1Label.text = [NSString stringWithFormat:@"%@: %@", self.stats[0][@"usernam"], self.stats[0][@"scores"]];
    } else {
        self.player1Label.text = @"";
    }
    if ([self.stats count] > 1 && ![self.stats[1][@"usernam"] isEqualToString:@""]) {
        self.player2Label.text = [NSString stringWithFormat:@"%@: %@", self.stats[1][@"usernam"], self.stats[1][@"scores"]];
    } else {
        self.player2Label.text = @"";
    }
    if ([self.stats count] > 2 && ![self.stats[2][@"usernam"] isEqualToString:@""]) {
        self.player3Label.text = [NSString stringWithFormat:@"%@: %@", self.stats[2][@"usernam"], self.stats[2][@"scores"]];
    } else {
        self.player3Label.text = @"";
    }
}

@end
