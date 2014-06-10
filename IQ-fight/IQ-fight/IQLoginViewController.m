//
//  IQLoginViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQLoginViewController.h"
#import "IQSettings.h"
#import "NSString+RegularExpressions.h"
#import "DataService.h"
#import "IQAppDelegate.h"

@interface IQLoginViewController () <DataServiceDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) NSDictionary *test;

@end

@implementation IQLoginViewController

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
    
    if ([IQSettings sharedInstance].inDebug) {
        self.usernameTextField.text = @"peshotest@abv.bg";
        self.passwordTextField.text = @"123456";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action Methods

- (IBAction)loginButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![username isEqualToString:@""] && ![password isEqualToString:@""]) {
        if ([self.usernameTextField.text isValidEmail]) {
            [self performSelectorInBackground:@selector(doLogin:) withObject:@{@"username":username,
                                                                               @"password":password}];
        } else {
            [self showAlertWithTitle:@"Error" message:@"Invalid email." cancelButton:@"OK"];
        }
    } else {
        [self showAlertWithTitle:@"Error" message:@"Empty fields." cancelButton:@"OK"];
    }
}

- (void)doLogin:(NSDictionary *)dic
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService loginWithUsername:dic[@"username"] andPassword:dic[@"password"]];
}

- (IBAction)newRegistrationButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"registrationSegue" sender:nil];
}

#pragma mark - Service delegates

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
    });
}

- (void)dataServiceLoginFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL loginSuccessfull = YES;
    
    if (j[@"username"] == nil || [j[@"username"] isEqualToString:@""] || ![j[@"status"] isEqualToString:@"ok"])
        loginSuccessfull = NO;
    
    if (loginSuccessfull) {
        [IQSettings sharedInstance].currentUser.username = j[@"username"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] hideHud:self.view];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UINavigationController *navViewController = [storyboard instantiateViewControllerWithIdentifier:@"homeRoot"];
            IQAppDelegate *delegate = [UIApplication sharedApplication].delegate;
            delegate.window.rootViewController = navViewController;
        });
    } else {
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
