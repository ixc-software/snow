//
//  UserCompanyInfo.h
//  snow
//
//  Created by Oleksii Vynogradov on 06.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class desctopAppDelegate;

@interface UserCompanyInfo : NSViewController <NSTableViewDelegate> {
    IBOutlet NSPanel *errorPanel;
    IBOutlet NSTextField *errorText;
    NSManagedObjectContext *moc;
    IBOutlet NSArrayController *currentCompany;
    IBOutlet NSArrayController *companyStuff;
    IBOutlet NSArrayController *companyStuffFirstPlusLastName;
    IBOutlet NSArrayController *companyStuffVerticalView;
    IBOutlet NSArrayController *recordsAwaitingApproveStack;
                                
    IBOutlet NSButton *currentCompanyStatus;
    IBOutlet NSButton *makeVisible;
    IBOutlet NSButton *removeCompany;
    IBOutlet NSButton *registerButton;

    NSMutableArray *observedCompaniesIDs;

    IBOutlet NSTextField *loginInfo;
    IBOutlet NSButton *loginStart;
    IBOutlet NSButton *loginCancel;
    IBOutlet NSPanel *authorization;
    IBOutlet NSTextField *loginField;
    IBOutlet NSSecureTextField *passwordField;
    IBOutlet NSProgressIndicator *loginProgressIndicator;
    //NSManagedObjectID *temporaryUserForLogin;
    NSManagedObjectID *observedCurrentCompany;

    BOOL isLoginWasSuccesseful;
    IBOutlet NSTableView *companyStuffVerticalTableView;

    IBOutlet NSPanel *joinRequest;
    IBOutlet NSTextField *joinRequestFirstName;
    IBOutlet NSSecureTextField *joinRequestPassword;
    IBOutlet NSTextField *joinRequestEmail;
    IBOutlet NSTextField *joinRequestLastName;
    IBOutlet NSTableView *usersAwaitingApproveTableView;
    
    IBOutlet NSButton *removeAwaitingApproveRegistration;
    IBOutlet NSTableView *currentCompanyTableView;
    IBOutlet NSTableView *companyStuffTableView;
    BOOL isViewHidden;
    BOOL isFirstStart;
    IBOutlet NSButton *changeToAdmin;
    IBOutlet NSButton *addUser;
    IBOutlet NSButton *login;
    IBOutlet NSButton *approveUser;
    IBOutlet NSButton *declineUser;
    IBOutlet NSView *loginView;
    IBOutlet NSView *joinToCompanyView;
    IBOutlet NSView *errorView;
    IBOutlet NSButton *removeUser;
    NSManagedObjectID *selectedUserID;
    IBOutlet NSButton *addCompany;

    IBOutlet NSButton *modifiedDate;
     desctopAppDelegate *delegate;
}

@property (retain) NSManagedObjectContext *moc;
@property (readwrite) BOOL isLoginWasSuccesseful;
@property (readwrite) BOOL isViewHidden;
@property (assign) IBOutlet NSButton *removeAwaitingApproveRegistration;
@property (assign) IBOutlet NSButton *addUser;
@property (assign) IBOutlet NSButton *changeToAdmin;
@property (assign) IBOutlet NSArrayController *companyStuffFirstPlusLastName;

@property (retain) NSManagedObjectID *selectedUserID;

@property (assign) IBOutlet NSButton *addCompany;
@property (assign) desctopAppDelegate *delegate;

//- (IBAction) test;
- (IBAction)refreshUsersAvaitingApproveList:(id)sender;
-(void)localMocMustUpdate;


@end
