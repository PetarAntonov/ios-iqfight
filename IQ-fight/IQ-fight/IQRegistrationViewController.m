//
//  IQRegistrationViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 5/5/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQRegistrationViewController.h"
#import "IQAppDelegate.h"
#import "IQSettings.h"
#import "NSString+RegularExpressions.h"
#import "DataService.h"

@interface IQRegistrationViewController () <DataServiceDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;

@property (nonatomic, strong) NSDictionary *test;

@end

@implementation IQRegistrationViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action Methods

- (IBAction)createButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password1 = [self.repeatPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![username isEqualToString:@""] && ![password isEqualToString:@""] && ![password1 isEqualToString:@""]) {
     
        if ([username isValidEmail]) {
            
            if ([password isEqualToString:password1]) {
                [self performSelectorInBackground:@selector(doRegister:) withObject:@{@"username":username,
                                                                                      @"password":password,
                                                                                      @"password1":password1}];
            } else {
                [self showAlertWithTitle:@"Error" message:@"Passwords doesn't match." cancelButton:@"OK"];
            }
        } else {
            [self showAlertWithTitle:@"Error" message:@"Invalid email." cancelButton:@"OK"];
        }
    } else {
        [self showAlertWithTitle:@"Error" message:@"Empty fields." cancelButton:@"OK"];
    }
}

- (void)doRegister:(NSDictionary *)dic
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] showHud:@"" onView:self.view];
    });
    
    DataService *dService = [[DataService alloc] init];
    dService.delegate = self;
    [dService createRegistrationWithUsername:dic[@"username"] password:dic[@"password"] andPassword1:dic[@"password1"]];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Service delegates

- (void)dataServiceError:(id)sender errorMessage:(NSString *)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQSettings sharedInstance] hideHud:self.view];
        [self showAlertWithTitle:@"Error" message:errorMessage cancelButton:@"OK"];
    });
}

- (void)dataServiceRegistrationFinished:(id)sender withData:(NSData *)data
{
    NSDictionary *j = [[IQSettings sharedInstance] jsonToDict:data];
    
    BOOL registrationSuccessfull = YES;
    
    if (j[@"username"] == nil || [j[@"username"] isEqualToString:@""] || ![j[@"status"] isEqualToString:@"ok"])
        registrationSuccessfull = NO;
    
    if (registrationSuccessfull) {
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
