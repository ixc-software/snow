//
//  GetExternalInfoView.h
//  snow
//
//  Created by Oleksii Vynogradov on 06.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LightView.h"
@class desctopAppDelegate;

@interface GetExternalInfoView : NSViewController
{
    NSManagedObjectContext *moc;
    BOOL isFirstStart;
    BOOL isViewHidden;
    BOOL isDaylySyncProcessing;
    NSProgressIndicator *downloadDataProgress;
    NSProgressIndicator *updateOperationProgress;
    LightView *errorView;
    NSTextField *errorText;
    NSTextField *carrierNameForUpdates;
    NSTextField *operationNameForUpdates;
    NSButton *startSyncForEnterpriseServer;
    NSButton *ratesStackIndicator;
    NSTextField *getExternalInfoProgressTextField;
    NSButton *checkEvents;
    NSButton *startSync;
    NSButton *getCarriersList;
    NSButton *cycleUpdateDaylyCount;
    NSButton *cycleUpdatePerHourCount;
    NSTextField *urlForGetCompaniesList;
    NSPopUpButton *companyForSync;
    NSBox *getCompaniesList;

    IBOutlet NSTableView *databaseConfigurationTableView;
    IBOutlet NSTableView *operationsListTableView;
    NSProgressIndicator *getExternalInfoProgress;
    NSArrayController *operationProgress;
    NSProgressIndicator *ratesStackProgressIndicator;
    NSTextField *importCSVUploadPriceLabel;
    BOOL cancelAllOperations;
    IBOutlet NSProgressIndicator *getCompaniesProgress;
//    NSOperationQueue *queue;
    desctopAppDelegate *delegate;
    NSArrayController *databaseConnections;
    NSPopUpButton *userToSync;
}
//@property (retain) NSOperationQueue *queue;
@property (assign) desctopAppDelegate *delegate;
@property (assign) IBOutlet NSArrayController *databaseConnections;
@property (assign) IBOutlet NSPopUpButton *userToSync;

@property (assign) IBOutlet NSTextField *importCSVUploadPriceLabel;
@property (assign) IBOutlet NSProgressIndicator *ratesStackProgressIndicator;
@property (assign) IBOutlet NSArrayController *operationProgress;
@property (assign) IBOutlet NSProgressIndicator *getExternalInfoProgress;
@property (retain) NSManagedObjectContext *moc;
@property (readwrite) BOOL isViewHidden;
@property (readwrite) BOOL isDaylySyncProcessing;
@property (assign) IBOutlet NSProgressIndicator *downloadDataProgress;
@property (assign) IBOutlet NSProgressIndicator *updateOperationProgress;
@property (assign) IBOutlet LightView *errorView;
@property (assign) IBOutlet NSTextField *errorText;
@property (assign) IBOutlet NSTextField *carrierNameForUpdates;
@property (assign) IBOutlet NSTextField *operationNameForUpdates;
@property (assign) IBOutlet NSButton *startSyncForEnterpriseServer;

@property (assign) IBOutlet NSButton *ratesStackIndicator;
@property (assign) IBOutlet NSTextField *getExternalInfoProgressTextField;
@property (assign) IBOutlet NSButton *checkEvents;
@property (assign) IBOutlet NSButton *startSync;
@property (assign) IBOutlet NSButton *getCarriersList;
@property (assign) IBOutlet NSButton *cycleUpdateDaylyCount;
@property (assign) IBOutlet NSButton *cycleUpdatePerHourCount;
@property (assign) IBOutlet NSTextField *urlForGetCompaniesList;
@property (assign) IBOutlet NSPopUpButton *companyForSync;
@property (assign) IBOutlet NSBox *getCompaniesList;

@property (readwrite) BOOL cancelAllOperations;

- (IBAction)getCompaniesList:(id)sender;

@end
