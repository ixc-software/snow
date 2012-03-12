//
//  desctopAppDelegate.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FinancialView.h"
#import "GetExternalInfoView.h"
#import "DestinationsView.h"
#import "ImportRatesView.h"
#import "CarriersView.h"
#import "UserCompanyInfo.h"


@class HTTPServer;
@class MySQLIXC;
@class UpdateDataController;
@class ProgressUpdateController;

@interface desctopAppDelegate : NSObject <NSApplicationDelegate>
{
    HTTPServer *httpServer;
    NSRect startupPosition;

    DestinationsView *destinationsView;
    ImportRatesView *importRatesView;
    CarriersView *carriersView;
    UserCompanyInfo *userCompanyInfo;
    GetExternalInfoView *getExternalInfoView;

    NSNumber *loggingLevel;
    MySQLIXC *databaseForMainThread;
    UpdateDataController *updateForMainThread;
    ProgressUpdateController *progressForMainThread;

    BOOL queueForUpdatesBusy;
    BOOL cancelAllOperations;
    BOOL isSearchProcessing;

    NSUInteger numberForHardJobConcurentLines;
    NSUInteger numberForSQLQueries;

    NSPopover *userCompanyInfoPopover;
    NSPopover *getExternalCompanyInfoPopover;
    NSTimer *durationRefreasher;
    NSWindow *_window;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;

    IBOutlet NSButton *_currentUserInfoList;
    IBOutlet NSButton *_showHideUserCompanyInfo;
    IBOutlet NSImageView *_mainLogo;
    NSTextField *_mainLogoSubTitle;
    NSTextField *_mainLogoSubSubTitle;
    NSButton *_getExternalInfoButton;
    NSProgressIndicator *getExternalInfoProgress;
    NSProgressIndicator *mainProgressIndicator;
    NSButton *totalProfit;
    IBOutlet NSTextField *_mainLogoTitle;

}
@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (readwrite) NSRect startupPosition;
@property(retain) IBOutlet NSNumber *loggingLevel;

// main window UI:
@property (assign) IBOutlet NSButton *currentUserInfoList;
@property (assign) IBOutlet NSButton *showHideUserCompanyInfo;
@property (assign) IBOutlet NSImageView *mainLogo;
@property (assign) IBOutlet NSTextField *mainLogoTitle;
@property (assign) IBOutlet NSTextField *mainLogoSubTitle;
@property (assign) IBOutlet NSTextField *mainLogoSubSubTitle;
@property (assign) IBOutlet NSButton *getExternalInfoButton;
@property (assign) IBOutlet NSProgressIndicator *getExternalInfoProgress;
@property (assign) IBOutlet NSProgressIndicator *mainProgressIndicator;
@property (assign) IBOutlet NSButton *totalProfit;

// main views
@property(assign) CarriersView *carriersView;
@property(assign) ImportRatesView *importRatesView;
@property(assign) DestinationsView *destinationsView;
@property(assign) GetExternalInfoView *getExternalInfoView;
@property(assign) UserCompanyInfo *userCompanyInfo;

@property (assign) UpdateDataController *updateForMainThread;
@property (assign) ProgressUpdateController *progressForMainThread;

@property (readwrite) BOOL queueForUpdatesBusy;
@property (readwrite) BOOL cancelAllOperations;
@property (readwrite) BOOL isSearchProcessing;

@property(assign) NSUInteger numberForHardJobConcurentLines;
@property(assign) NSUInteger numberForSQLQueries;


- (IBAction)saveAction:(id)sender;
-(void)updateWellcomeTitle;
- (NSURL *)applicationFilesDirectory;
- (BOOL)safeSave; 
-(void) createAndConnectMainThreadControllers;

@end
