//
//  RegistrationsDetailTableViewCell.m
//  snow
//
//  Created by Oleksii Vynogradov on 28.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "RegistrationsDetailTableViewCell.h"


@implementation RegistrationsDetailTableViewCell

@synthesize key,attribute;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [key release];
    [attribute release];
    [super dealloc];
}

@end
