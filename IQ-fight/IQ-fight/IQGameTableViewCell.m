//
//  IQGameTableViewCell.m
//  IQ-fight
//
//  Created by Petar Antonov on 4/21/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQGameTableViewCell.h"

@implementation IQGameTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
