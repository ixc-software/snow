//
//  LinkedinGroupsTableViewCell.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/6/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "LinkedinGroupsTableViewCell.h"

@implementation LinkedinGroupsTableViewCell
@synthesize groupName;
@synthesize bodyForEdit;
@synthesize signature;
@synthesize routesList;
@synthesize postingTitle;
@synthesize groupSwitch;

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
    [groupName release];
    [groupSwitch release];
    [bodyForEdit release];
    [signature release];
    [routesList release];
    [postingTitle release];
    [super dealloc];
}

@end
