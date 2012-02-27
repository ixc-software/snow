//
//  FirstAuthorizationSetup.h
//  snow
//
//  Created by Oleksii Vynogradov on 22.11.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//#import "FirstAuthorizationSetupCompaniesList.h"
//#import "INPopoverController.h"

//@class FirstAuthorizationSetupCompaniesList;

@interface FirstAuthorizationSetup : NSViewController <NSTextFieldDelegate,NSTableViewDelegate> {
     IBOutlet NSImageView *logo;
    NSScrollView *companiesListScrollView;
    NSTableView *companiesListTableView;
     IBOutlet NSTextField *logoName;
     IBOutlet NSTextField *email;
     IBOutlet NSTextField *password;
     IBOutlet NSTextField *company;
    NSButton *selectorToCompaniesList;
    NSBox *companiesList;
    NSManagedObjectContext *moc;
    NSArrayController *currentCompany;
    NSButton *registration;
    NSButton *login;

    NSUInteger tremorEmailCount;
    BOOL isTremorEmailLeftMoving;
    NSUInteger tremorPasswordCount;
    BOOL isTremorPasswordLeftMoving;
    NSUInteger tremorCompanyCount;
    BOOL isTremorCompanyLeftMoving;
    BOOL isCompanyListVisible;
    BOOL isCompanyListProcessingAnimation;
    BOOL isCompanyListWasSelected;

//    id tremoredObject;
    NSProgressIndicator *progressLogin;
    NSTextField *errorMessage;
    NSTextField *namedLogo;
    NSUInteger deltaToMovingDownLoginPassLogoProgress;
    NSUInteger deltaCompaniesListScrollAndTableHeight;
    NSUInteger deltaCompaniesListScrollViewHeightAndCompaniesListBoxHeight;

    BOOL isLoginPassLogoProgressInDownPosition;
    BOOL isCompaniesListTableViewHeightChanged;
    NSView *loginRegistrationErrorView;
//    FirstAuthorizationSetupCompaniesList *firstAuthorizationSetupCompaniesList;
    NSBox *registeredCompaniesBox;
    NSView *popoverView;
    NSManagedObjectID *selectedCompanyID;
//    INPopoverController *companiesListPopOver;

    NSTextField *enterprise;
}
//@property (nonatomic, retain) INPopoverController *companiesListPopOver;

@property (assign) IBOutlet NSTextField *enterprise;
@property (assign) NSManagedObjectID *selectedCompanyID;

@property (assign) IBOutlet NSTextField *errorMessage;
@property (assign) IBOutlet NSTextField *namedLogo;
@property (assign) IBOutlet NSProgressIndicator *progressLogin;
@property (assign) IBOutlet NSImageView *logo;
@property (assign) IBOutlet NSScrollView *companiesListScrollView;
@property (assign) IBOutlet NSTableView *companiesListTableView;
@property (assign) IBOutlet NSTextField *logoName;
@property (assign) IBOutlet NSTextField *email;
@property (assign) IBOutlet NSTextField *password;
@property (assign) IBOutlet NSTextField *company;
@property (assign) IBOutlet NSButton *selectorToCompaniesList;
@property (assign) IBOutlet NSBox *companiesList;
@property (assign) NSManagedObjectContext *moc;
@property (assign) IBOutlet NSArrayController *currentCompany;
@property (assign) IBOutlet NSButton *registration;
@property (assign) IBOutlet NSButton *login;

@property (readwrite) BOOL isTremorEmailLeftMoving;
@property (readwrite) NSUInteger tremorEmailCount;
@property (readwrite) BOOL isTremorPasswordLeftMoving;
@property (readwrite) NSUInteger tremorPasswordCount;
@property (readwrite) BOOL isTremorCompanyLeftMoving;
@property (readwrite) NSUInteger tremorCompanyCount;
@property (readwrite) BOOL isCompanyListVisible;
@property (readwrite) BOOL isCompanyListProcessingAnimation;

@property (readwrite) BOOL isCompanyListWasSelected;

@property (readwrite) NSUInteger deltaToMovingDownLoginPassLogoProgress;
@property (readwrite) NSUInteger deltaCompaniesListScrollAndTableHeight;
@property (readwrite) NSUInteger deltaCompaniesListScrollViewHeightAndCompaniesListBoxHeight;
@property (readwrite) BOOL isLoginPassLogoProgressInDownPosition;
@property (readwrite) BOOL isCompaniesListTableViewHeightChanged;

@property (assign) IBOutlet NSView *loginRegistrationErrorView;
//@property (assign) IBOutlet FirstAuthorizationSetupCompaniesList *firstAuthorizationSetupCompaniesList;

@property (assign) IBOutlet NSBox *registeredCompaniesBox;
@property (assign) IBOutlet NSView *popoverView;


@end
