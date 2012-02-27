//
//  FirstAuthorizationSetupCompaniesList.h
//  snow
//
//  Created by Oleksii Vynogradov on 28.11.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FirstAuthorizationSetup;

@interface FirstAuthorizationSetupCompaniesList : NSViewController
{
    NSManagedObjectContext *moc;
    NSArrayController *currentCompany1;
    FirstAuthorizationSetup *firstAuthorizationSetup;
    NSBox *registeredCompaniesBox;
    NSTableView *companiesListTableView;
}
@property (assign) NSManagedObjectContext *moc;
@property (assign) IBOutlet NSArrayController *currentCompany1;
@property (assign) IBOutlet FirstAuthorizationSetup *firstAuthorizationSetup;
@property (assign) IBOutlet NSBox *registeredCompaniesBox;
@property (assign) IBOutlet NSTableView *companiesListTableView;

-(void)test;

@end
