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

- (IBAction)loginButtonTapped:(id)sender
{
    //start internet activity
    
    if (![self.usernameTextField.text isEqualToString:@""] || ![self.passwordTextField.text isEqualToString:@""]) {
        IQServerCommunication *sc = [[IQServerCommunication alloc] init];
        [sc loginWithUsername:self.usernameTextField.text andPassword:self.passwordTextField.text withCompetionBlock:^(id result, NSError *error) {
            
            //TODO:proverka na rezultata kakvo 6te vrashta v kakvo 6te se zapazva
            
            if (result) {
                //save user????
                //stop internet activity
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                UINavigationController *navViewController = [storyboard instantiateViewControllerWithIdentifier:@"homeRoot"];
                IQAppDelegate *delegate = [UIApplication sharedApplication].delegate;
                delegate.window.rootViewController = navViewController;
                
            } else {
                //stop internet activity
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong username or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    } else {
        //stop internet activity
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Empty fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@end
