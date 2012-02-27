//
//  CompanyInfoDetailCell.m
//  snow
//
//  Created by Oleksii Vynogradov on 04.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "CompanyInfoDetailCell.h"
#import "CompanyAddController.h"

#import <QuartzCore/QuartzCore.h>

@implementation CompanyInfoDetailCell

@synthesize name,url,members,destinations,adminFirstName,adminLastName,changeCompanyName,changeCompanyURL,delegate,companyProcess,isVisibleLabel,notification,admin,activity;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}
- (IBAction)didChange:(id)sender {

    [delegate companyDidChangesFor:nil];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [admin release];
    [name release];
    [url release];
    [members release];
    [destinations release];
    [changeCompanyName release];
    [changeCompanyURL release];
    [isVisibleLabel release];
    [notification release];
    [activity release];
    [super dealloc];
}

@end
