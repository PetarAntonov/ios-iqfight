//
//  IQLoginViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQLoginViewController.h"
#import "IQAppDelegate.h"
#import "IQServerCommunication.h"
#import "IQSettings.h"

@interface IQLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation IQLoginViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)loginButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![username isEqualToString:@""] && ![password isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IQSettings sharedInstance] showHud:@"" onView:self.view];
        });
    }
    
    IQServerCommunication *sc = [[IQServerCommunication alloc] init];
    [sc loginWithUsername:username andPassword:password withCompetionBlock:^(id result, NSError *error) {
        if (!result[@"error"]) {
            //ako nqma greshka
            if ([result[@"logged"] boolValue]) {
                //correct username and password
                [IQSettings sharedInstance].currentUser.username = result[@"username"];
                [IQSettings sharedInstance].currentUser.session_id = result[@"session_id"];
                [IQSettings sharedInstance].games = result[@"games"];
    
                [[IQSettings sharedInstance] hideHud:self.view];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                UINavigationController *navViewController = [storyboard instantiateViewControllerWithIdentifier:@"homeRoot"];
                IQAppDelegate *delegate = [UIApplication sharedApplication].delegate;
                delegate.window.rootViewController = navViewController;
            } else {
                //wrong username and password
                [[IQSettings sharedInstance] hideHud:self.view];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong username or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        } else {
            //greshka ot servara
            [[IQSettings sharedInstance] hideHud:self.view];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Server error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
