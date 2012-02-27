//
//  CompanyAndUserInfoCell.m
//  snow
//
//  Created by Oleksii Vynogradov on 02.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "CompanyAndUserInfoCell.h"


@implementation CompanyAndUserInfoCell
@synthesize attribute,data,delegate,currentIndexPath,state,approve,activity;


- (IBAction)finishEditing:(id)sender {
    //NSLog(@"Update data in cell:%@ at indexpath:%@",data.text,self.currentIndexPath);
    data.hidden = YES;
    [self.delegate updateData:data.text forCellAtIndexPath:self.currentIndexPath];
    
}
- (IBAction)approveRegistration:(id)sender {
    [self.delegate approveRegistrationForCellAtIndexPath:self.currentIndexPath];
}

- (void)dealloc
{
    [state release];
//    [currentData release];
    [attribute release];
    [data release];
    [super dealloc];
}

@end
