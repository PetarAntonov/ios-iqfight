//
//  IQGameTableViewCell.h
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IQGameTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *gameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playersToStartLabel;

@end
