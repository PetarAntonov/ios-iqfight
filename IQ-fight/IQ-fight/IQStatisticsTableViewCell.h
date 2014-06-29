//
//  IQStatisticsTableViewCell.h
//  IQ-fight
//
//  Created by Petar Antonov on 6/29/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IQStatisticsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *playerLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@end
