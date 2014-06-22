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
#import "IQGameLobyViewController.h"

@interface IQNewGameViewController () <DataServiceDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *gameTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, assign) int ddRow;

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
    
    self.types = @[@"Short - 5 questions", @"Standart - 10 questions", @"Long - 15 questions"];
    self.ddRow = 1;
    self.gameTypeTextField.text = self.types[1];
    [self setupPickerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action Methods

- (IBAction)createButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *name = self.nameTextField.text;
    int type = self.ddRow;
    NSString *password = @"";
    if (![self.gameTypeTextField.text isEqualToString:@""] && self.gameTypeTextField.text != nil) {
        password = self.gameTypeTextField.text;
    }
    
    if (![name isEqualToString:@""]) {
        [self performSelectorInBackground:@selector(doNewGame:) withObject:@{@"name":name,
                                                                             @"type":@(type),
                                                                             @"password":password}];
    } else {
        [self showAlertWithTitle:@"Error" message:@"Enter game name." cancelButton:@"OK"];
    }
}

- (void)doNewGame:(NSDictionary *)dic
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService newGame:dic];
}

#pragma mark - Service delegates

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
        
        DataService *dService = [[DataService alloc] init];
        dService.delegate = self;
        [dService openGame:self.gameID];
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

- (void)dataServiceOpenGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL openGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        openGameSuccessfull = NO;
    
    if (openGameSuccessfull) {
        DataService *dService = [[DataService alloc] init];
        dService.delegate = self;
        [dService refreshGame:self.gameID];
    } else {
        [self dataServiceError:self errorMessage:j[@"error_message"]];
    }
}

- (void)dataServiceRefreshGameFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL refreshGameSuccessfull = YES;
    
    if (![j[@"status"] isEqualToString:@"ok"])
        refreshGameSuccessfull = NO;
    
    if (refreshGameSuccessfull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
            
            NSMutableDictionary *game = [j mutableCopy];
            [game setValue:self.gameID forKey:@"id"];
            [game setValue:self.gameName forKey:@"name"];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            IQGameLobyViewController *gameLoby = [storyboard instantiateViewControllerWithIdentifier:@"GameLobyViewController"];
            gameLoby.game = game;
            NSMutableArray *vsc = [self.navigationController.viewControllers mutableCopy];
            [vsc removeLastObject];
            [vsc addObject:gameLoby];
            [self.navigationController setViewControllers:vsc animated:YES];
            
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

#pragma mark - Picker view delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.types count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.types[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.ddRow = row;
    self.gameTypeTextField.text = self.types[row];
}

#pragma mark - Private Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

- (void)setupPickerView
{
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    [pickerView setDelegate:self];
    [pickerView setDataSource:self];
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView selectRow:self.ddRow inComponent:0 animated:YES];
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.gameTypeTextField setInputView:pickerView];
    
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    [toolBar setBackgroundColor:[UIColor darkGrayColor]];
    [toolBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self.gameTypeTextField action:@selector(resignFirstResponder)];
    [toolBar setItems:@[itemSpace, btnDone]];
    [self.gameTypeTextField setInputAccessoryView:toolBar];
}

@end
