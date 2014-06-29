//
//  IQStatisticsViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 6/29/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQStatisticsViewController.h"
#import "IQStatisticsTableViewCell.h"
#import "IQSettings.h"

@interface IQStatisticsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic , strong) UIView *viewTableHeader;

@end

@implementation IQStatisticsViewController

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
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.statistics != nil && [self.statistics count] > 0) {
        return [self.statistics count];
    } else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.viewTableHeader == nil) {
        self.viewTableHeader = [[UIView alloc] init];
        self.viewTableHeader.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30);
        self.viewTableHeader.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        
        UILabel *usernameLabel = [[UILabel alloc] init];
        usernameLabel.frame = CGRectMake(20, 0, 100, CGRectGetHeight(self.viewTableHeader.frame));
        usernameLabel.backgroundColor = [UIColor clearColor];
        usernameLabel.textColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1];
        usernameLabel.font = [UIFont boldSystemFontOfSize:15.0];
        usernameLabel.textAlignment = NSTextAlignmentLeft;
        usernameLabel.text = @"Username";
        [self.viewTableHeader addSubview:usernameLabel];
        
        UILabel *pointsLabel = [[UILabel alloc] init];
        pointsLabel.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 20 - 100, 0, 100, CGRectGetHeight(self.viewTableHeader.frame));
        pointsLabel.backgroundColor = [UIColor clearColor];
        pointsLabel.textColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1];
        pointsLabel.font = [UIFont boldSystemFontOfSize:15.0];
        pointsLabel.textAlignment = NSTextAlignmentRight;
        pointsLabel.text = @"Points";
        [self.viewTableHeader addSubview:pointsLabel];
        
        UIView *vs = [[UIView alloc] init];
        vs.frame = CGRectMake(0, CGRectGetHeight(self.viewTableHeader.frame) - 2, CGRectGetWidth(self.viewTableHeader.frame), 2);
        vs.backgroundColor = [UIColor lightGrayColor];
        [self.viewTableHeader addSubview:vs];
    }
    
    return self.viewTableHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQStatisticsTableViewCell *cell = (IQStatisticsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"statCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (self.statistics == nil || [self.statistics count] < 1) {
        cell.playerLabel.text = @"Statistics isn't available";
        cell.pointsLabel.text = @"";
    } else {
        cell.playerLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, self.statistics[indexPath.row][@"usernam"]];
        cell.pointsLabel.text = [NSString stringWithFormat:@"%@", self.statistics[indexPath.row][@"scores"]];
        
        cell.userInteractionEnabled = YES;
    }
    
    if (indexPath.row < 3) {
        cell.playerLabel.font = [UIFont boldSystemFontOfSize:20.0];
        cell.pointsLabel.font = [UIFont boldSystemFontOfSize:20.0];
    } else {
        cell.playerLabel.font = [UIFont systemFontOfSize:18.0];
        cell.pointsLabel.font = [UIFont systemFontOfSize:18.0];
    }
    
    if ([self.statistics[indexPath.row][@"usernam"] isEqualToString:[IQSettings sharedInstance].currentUser.username]) {
        cell.playerLabel.textColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1];
        cell.pointsLabel.textColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1];
    } else {
        cell.playerLabel.textColor = [UIColor whiteColor];
        cell.pointsLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

@end
