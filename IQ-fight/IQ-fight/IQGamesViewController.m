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
    
    //TODO: set the title
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTableView];
    
    //TODO: timeintervala da bade raven na rezultata ot zaqvkata
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //TODO: opravi boq na kletkite
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IQGameTableViewCell *cell = (IQGameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
    
   //TODO: set the cell views
    
    return cell;
}

#pragma mark - Private Methods

- (void)updateTableView
{
    if (self.sv == nil) {
        self.sv = [[IQServerCommunication alloc] init];
    }
    
    [self.sv getGamesWithCompletion:^(id result, NSError *error) {
        if (result) {
            
            //TODO: zapazi ne6tata to zaqvkata
            
            [self.tableView reloadData];
        } else {
            if (self.timer != nil) {
                [self.timer invalidate];
                self.timer = nil;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't load the games" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)refresh
{
    [self updateTableView];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];
}

@end
