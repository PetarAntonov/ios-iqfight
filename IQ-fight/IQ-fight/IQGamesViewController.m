//
//  IQGamesViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQGamesViewController.h"
#import "IQServerCommunication.h"
#import "IQGameTableViewCell.h"
#import "IQSettings.h"

@interface IQGamesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IQServerCommunication *sv;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation IQGamesViewController

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
    
    self.title = @"Games";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(updateTableView) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[IQSettings sharedInstance].games count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQGameTableViewCell *cell = (IQGameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
    
    cell.gameLabel.text = [IQSettings sharedInstance].games[indexPath.row][@"gameName"];
    cell.playersToStartLabel.text = [IQSettings sharedInstance].games[indexPath.row][@"players_to_start"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"gameLobySegue" sender:nil];
}

#pragma mark - Private Methods

- (void)updateTableView
{
    if (self.sv == nil) {
        self.sv = [[IQServerCommunication alloc] init];
    }
    
    [self.sv getGamesWithCompletion:^(id result, NSError *error) {
        if (result) {
            //ako ima igri
            [IQSettings sharedInstance].games = result[@"games"];
            
//            if (self.timer == nil) {
//                self.timer = [NSTimer scheduledTimerWithTimeInterval:result["refresh_interval"] target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];
//            }
            
            [self.tableView reloadData];
        } else {
            //ako ima greshka
            if (self.timer != nil) {
                [self.timer invalidate];
                self.timer = nil;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't load the games" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
