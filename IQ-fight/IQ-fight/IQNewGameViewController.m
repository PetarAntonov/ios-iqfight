//
//  IQNewGameViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 6/8/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQNewGameViewController.h"
#import "IQSettings.h"
#import "DataService.h"
#import "IQGameLobyViewController.h"

@interface IQNewGameViewController () <DataServiceDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSMutableDictionary *game;

@end

@implementation IQNewGameViewController

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
    
    self.game = [@{} mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openGameSegue"]) {
        ((IQGameLobyViewController *)segue.destinationViewController).game = self.game;
    }
}

#pragma mark - Action Methods

- (IBAction)createButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *name = self.nameTextField.text;
    
    if (![name isEqualToString:@""]) {
        [self performSelectorInBackground:@selector(doNewGame:) withObject:@{@"name":name}];
    } else {
        [self showAlertWithTitle:@"Error" message:@"Enter game name." cancelButton:@"OK"];
    }
}

- (void)doNewGame:(NSDictionary *)dic
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    //DataService *dService = [IQSettings sharedInstance].dService;
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService newGameWithName:dic[@"name"]];
}

#pragma mark - Service delegates

//expected request responce
//{
//    'name':'...',
//    'id':'' ,
//    'status:ok/error',
//    'error_message':''
//}

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
    });
}

- (void)dataServiceNewGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL newGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        newGameSuccessfull = NO;
    
    if (newGameSuccessfull) {
        self.gameName = j[@"name"];
        self.gameID = j[@"id"];
        
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
            
            [self performSegueWithIdentifier:@"openGameSegue" sender:nil];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
        });
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Private Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

@end
