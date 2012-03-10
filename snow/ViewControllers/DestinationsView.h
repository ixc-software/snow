//
//  DestinationsView.h
//  snow
//
//  Created by Oleksii Vynogradov on 04.01.12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//




#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
//#import "RoundedBox.h"
#import "AVTableView.h"
@class desctopAppDelegate;


@interface DestinationsView : NSViewController < NSSoundDelegate >
{
    NSManagedObjectContext *moc;

    IBOutlet NSArrayController *destinationsListForSale;
    IBOutlet NSArrayController *destinationsListWeBuy;
    IBOutlet NSArrayController *destinationsListTargets;
    IBOutlet NSArrayController *destinationsListPushList;
    IBOutlet NSArrayController *codesvsDestinationsList;
    IBOutlet NSArrayController *destinationPerHourStat;
    NSArrayController *destinationsListWeBuyForTargets;
    NSArrayController *destinationsListWeBuyResults;
    NSArrayController *destinationsListWeBuyTesting;
    NSBox *mainBox;
    NSTabView *destinationsTab;
    IBOutlet WebView *callPathWebView;
    NSTabView *destinationsForSaleCodesStatisticRoutingBlock;
    NSButton *addDestinationsButton;
    BOOL isAddDestinationsPanelShort;
    BOOL isAddDestinationsAddNewOutPeerToGroupList;
    NSButton *ivr;
    NSButton *puslist;
    NSButton *changedDate;
    NSButton *enabled;
    NSButton *prefix;
    NSButton *rateSheetList;
    NSButton *codesRatesheet;
    NSButton *codesRateSheetID;
    NSButton *codesPeerID;
    NSProgressIndicator *destinationsForSaleProgress;
    NSButton *rateSheetNameForCodes;
    NSButton *weBuyPushlist;
    NSButton *weBuyChangedDate;
    NSButton *weBuyEnabled;
    NSButton *weBuyPrefix;
    NSButton *weBuyRatesheet;
    NSProgressIndicator *weBuyProgress;
    NSButton *weBuyCodesRatesheet;
    NSButton *weBuyCodesRateSheetID;
    NSButton *weBuyCodesPeerID;
    NSButton *addDestinationsWeBuyButton;
    NSProgressIndicator *importRatesProgress;
    NSTextField *importRatesLabelFirs;
    NSTextField *importRatesLabelSecond;
    NSButton *importRatesButton;
    NSButton *weBuyRatesheetID;
    NSTableView *forSaleTableView;
    NSTableView *forSaleCodesTableView;
    NSTableView *forSaleStatisticTableView;
    NSTableView *weBuyTableView;
    NSTableView *weBuyCodesTableView;
    NSTableView *weBuyPerHourStatisticTableView;
    NSTableView *weBuyTestingTableView;
    NSTableView *weBuyTestingResultsTableView;
    NSButton *targetsInfo;
    NSProgressIndicator *targetsProgress;
    NSTableView *targetsTableView;
    NSTableView *targetsCodesTableView;
    NSTableView *targetsRoutingTableView;
    NSButton *routingPushList;
    NSButton *routingChangedDate;
    NSButton *routingEnabled;
    NSButton *routingPrefix;
    NSButton *routingRateSheet;
    NSProgressIndicator *routingProgress;
    NSButton *addDestinationsTargetsBlock;
    NSButton *addDestinationsTargetsNew;
    NSButton *pushListInfo;
    NSProgressIndicator *pushListProgress;
    NSTableView *pushListTableView;
    NSTableView *pushListCodesTableView;
    NSButton *pushListRemoveDestinations;
    NSButton *addDestinationsPushlistButton;
    NSButton *twitIt;
    NSButton *linkedinIn;
    
    NSManagedObjectID *currentObservedDestination;
    NSInteger previousSelectedIndex;
//    NSMutableString *importRatesSelectedCountryForParsing;
    
    NSPanel *errorPanel;
    NSTextField *errorText;
    NSPopover *testingResults;
    NSPopover *addDestinationsPanel;
    NSViewController *addRoutesViewController;
    NSViewController *testingResultsController;
    NSTextField *testingResultInfo1;
    NSTextField *testingResultInfo2;
    NSTextField *testingResultInfo3;
    NSTextField *testingResultInfo4;
    NSTextField *testingResultInfo5;
    NSButton *testingResultIPlay1;
    NSButton *testingResultIPlay2;
    NSButton *testingResultIPlay3;
    NSButton *testingResultIPlay4;
    NSButton *testingResultIPlay5;
    NSButton *testingResultShortInfo;
    NSScrollView *addDestinationsRoutesListTableView;
    NSBox *addDestinationsGroupsView;
    NSBox *addDestinationsCarriersAndRatesheetsView;
    NSScrollView *addDestinationsRateSheetsView;
    NSButton *addDestinationsStartButton;
    NSArrayController *addDestinationsList;
    NSTableView *addDestinationsListTableView;
    NSTableView *addDestinationsOutGroupTableView;
    NSTableView *addDestinationsOutGroupDestinationsTableView;
    NSTableView *addDestinationsCarriersListTableView;
    NSTableView *addDestinationsCarriersRateSheetsTableView;
    NSArrayController *addDestinationCarriersList;
    NSStepper *addDestinationsStepper;
    NSTextField *addDestinationsPercent;
    NSArrayController *addDestinationsOutGroups;
    NSArrayController *addDestinationsOutGroupsOutPeerList;
    NSProgressIndicator *addDestinationsProgress;
    NSPanel *addDestinationsMainPanel;
    NSView *addDestinationsView;
//    NSView *importRatesView;
//    NSViewController *importRatesViewController;
//    NSViewController *importRatesColumnSelectViewController;
//    NSTableView *importRatesImportedRoutes;
//    NSTableView *importRatesParsedRows;
//    NSTableColumn *importRatesParsedCodes;
//    AVTableView *importRatesCarrierList;
//    AVTableView *importRatesCarriersRateSheet;
//    NSDatePicker *importRatesEffectiveDate;
//    NSArrayController *importRatesSelectionList;
//    NSMutableString *importRatesRelationshipName;
//    NSMutableString *importRatesCarrierName;
//    NSButton *importRatesStartParsing;
//    NSPopUpButton *importRatesRatesheetList;
//    NSProgressIndicator *importRatesProgress;
//    NSTextField *importRatesPrefix;
//    NSArrayController *importRatesFirsParserResult;
//    AVTableView *importRatesCodesTableView;
//    NSArrayController *importRatesSecondParserResult;
//    NSPopUpButton *importRatesDestinationChoice;
//    NSButton *importRatesApply;
    IBOutlet NSPopover *importRatesPanel;
//    NSPopover *importRatesColumnSelectPanel;
    NSPopover *addDestinationsChangeOutPeer;
    IBOutlet desctopAppDelegate *delegate;
    NSViewController *addDestinationsChangeOutPeerController;
    NSArrayController *addDestinationsWeBuyForChangeOutPeers;
    AVTableView *addDestinationsChangeOutPeerView;
    AVTableView *addDestinationsChangeOutPeerTableView;
    NSButton *addDestinationsAddNewPeerToOutGroupList;
    NSBox *addDestinationsBox;
    
    NSSound *s;
    NSPanel *importRatesMainPanel;
    
}


@property (assign) IBOutlet desctopAppDelegate *delegate;
@property (assign) NSManagedObjectContext *moc;
@property (assign) NSManagedObjectID *currentObservedDestination;
@property(retain) NSSound *s;


// arrays:
@property (assign) IBOutlet NSArrayController *destinationsListForSale;
@property (assign) IBOutlet NSArrayController *destinationsListWeBuy;
@property (assign) IBOutlet NSArrayController *destinationsListTargets;
@property (assign) IBOutlet NSArrayController *destinationsListPushList;
@property (assign) IBOutlet NSArrayController *codesvsDestinationsList;
@property (assign) IBOutlet NSArrayController *destinationPerHourStat;
@property (assign) IBOutlet NSArrayController *destinationsListWeBuyForTargets;
@property (assign) IBOutlet NSArrayController *destinationsListWeBuyResults;
@property (assign) IBOutlet NSArrayController *destinationsListWeBuyTesting;
@property (assign) IBOutlet NSBox *mainBox;
@property (assign) IBOutlet NSTabView *destinationsTab;


// destinations for sale block:
@property (assign) IBOutlet NSTableView *forSaleTableView;
@property (assign) IBOutlet NSTableView *forSaleCodesTableView;
@property (assign) IBOutlet NSTableView *forSaleStatisticTableView;

@property (assign) IBOutlet NSButton *ivr;
@property (assign) IBOutlet NSButton *puslist;
@property (assign) IBOutlet NSButton *changedDate;
@property (assign) IBOutlet NSButton *enabled;
@property (assign) IBOutlet NSButton *prefix;
@property (assign) IBOutlet NSButton *rateSheetList;

@property (assign) IBOutlet NSButton *codesRatesheet;
@property (assign) IBOutlet NSButton *codesRateSheetID;
@property (assign) IBOutlet NSButton *codesPeerID;

@property (assign) IBOutlet NSProgressIndicator *destinationsForSaleProgress;

@property (assign) IBOutlet WebView *callPathWebView;
@property (assign) IBOutlet NSTabView *destinationsForSaleCodesStatisticRoutingBlock;
@property (assign) IBOutlet NSButton *addDestinationsButton;

// destinations we buy block:

@property (assign) IBOutlet NSTableView *weBuyTableView;
@property (assign) IBOutlet NSTableView *weBuyCodesTableView;
@property (assign) IBOutlet NSTableView *weBuyPerHourStatisticTableView;

@property (assign) IBOutlet NSTableView *weBuyTestingTableView;
@property (assign) IBOutlet NSTableView *weBuyTestingResultsTableView;


@property (assign) IBOutlet NSButton *weBuyPushlist;
@property (assign) IBOutlet NSButton *weBuyChangedDate;
@property (assign) IBOutlet NSButton *weBuyEnabled;
@property (assign) IBOutlet NSButton *weBuyPrefix;
@property (assign) IBOutlet NSButton *weBuyRatesheet;
@property (assign) IBOutlet NSProgressIndicator *weBuyProgress;

@property (assign) IBOutlet NSButton *weBuyCodesRatesheet;
@property (assign) IBOutlet NSButton *weBuyCodesRateSheetID;
@property (assign) IBOutlet NSButton *weBuyCodesPeerID;
@property (assign) IBOutlet NSButton *addDestinationsWeBuyButton;
@property (assign) IBOutlet NSProgressIndicator *importRatesProgress;
@property (assign) IBOutlet NSTextField *importRatesLabelFirs;
@property (assign) IBOutlet NSTextField *importRatesLabelSecond;
@property (assign) IBOutlet NSButton *importRatesButton;

// destinations targets block:
@property (assign) IBOutlet NSButton *targetsInfo;
@property (assign) IBOutlet NSProgressIndicator *targetsProgress;
@property (assign) IBOutlet NSTableView *targetsTableView;
@property (assign) IBOutlet NSTableView *targetsCodesTableView;
@property (assign) IBOutlet NSTableView *targetsRoutingTableView;

@property (assign) IBOutlet NSButton *routingPushList;
@property (assign) IBOutlet NSButton *routingChangedDate;
@property (assign) IBOutlet NSButton *routingEnabled;
@property (assign) IBOutlet NSButton *routingPrefix;
@property (assign) IBOutlet NSButton *routingRateSheet;
@property (assign) IBOutlet NSProgressIndicator *routingProgress;
@property (assign) IBOutlet NSButton *addDestinationsTargetsBlock;
@property (assign) IBOutlet NSButton *addDestinationsTargetsNew;

// destinations pushlist block:

@property (assign) IBOutlet NSButton *pushListInfo;
@property (assign) IBOutlet NSProgressIndicator *pushListProgress;
@property (assign) IBOutlet NSTableView *pushListTableView;
@property (assign) IBOutlet NSTableView *pushListCodesTableView;
@property (assign) IBOutlet NSButton *pushListRemoveDestinations;
@property (assign) IBOutlet NSButton *addDestinationsPushlistButton;
@property (assign) IBOutlet NSButton *twitIt;
@property (assign) IBOutlet NSButton *linkedinIn;

// errorPanel

@property (assign) IBOutlet NSPanel *errorPanel;
@property (assign) IBOutlet NSTextField *errorText;

// testing results view
@property (assign) IBOutlet NSPopover *testingResults;
@property (assign) IBOutlet NSViewController *testingResultsController;
@property (assign) IBOutlet NSTextField *testingResultInfo1;
@property (assign) IBOutlet NSTextField *testingResultInfo2;
@property (assign) IBOutlet NSTextField *testingResultInfo3;
@property (assign) IBOutlet NSTextField *testingResultInfo4;
@property (assign) IBOutlet NSTextField *testingResultInfo5;
@property (assign) IBOutlet NSButton *testingResultIPlay1;
@property (assign) IBOutlet NSButton *testingResultIPlay2;
@property (assign) IBOutlet NSButton *testingResultIPlay3;
@property (assign) IBOutlet NSButton *testingResultIPlay4;
@property (assign) IBOutlet NSButton *testingResultIPlay5;
@property (assign) IBOutlet NSButton *testingResultShortInfo;


// add destinations view
@property (assign) IBOutlet NSPopover *addDestinationsPanel;
@property (assign) IBOutlet NSViewController *addRoutesViewController;
@property (assign) IBOutlet NSView *addDestinationsView;
@property (assign) IBOutlet NSPanel *addDestinationsMainPanel;
@property (assign) IBOutlet NSScrollView *addDestinationsRoutesListTableView;
@property (assign) IBOutlet NSBox *addDestinationsGroupsView;
@property (assign) IBOutlet NSBox *addDestinationsCarriersAndRatesheetsView;
@property (assign) IBOutlet NSScrollView *addDestinationsRateSheetsView;
@property (assign) IBOutlet NSButton *addDestinationsStartButton;
@property (assign) IBOutlet NSArrayController *addDestinationsList;
@property (assign) IBOutlet NSTableView *addDestinationsListTableView;
@property (assign) IBOutlet NSTableView *addDestinationsOutGroupTableView;
@property (assign) IBOutlet NSTableView *addDestinationsOutGroupDestinationsTableView;
@property (assign) IBOutlet NSTableView *addDestinationsCarriersListTableView;
@property (assign) IBOutlet NSTableView *addDestinationsCarriersRateSheetsTableView;
@property (assign) IBOutlet NSStepper *addDestinationsStepper;
@property (assign) IBOutlet NSTextField *addDestinationsPercent;
@property (assign) IBOutlet NSArrayController *addDestinationsOutGroups;
@property (assign) IBOutlet NSArrayController *addDestinationsOutGroupsOutPeerList;
@property (assign) IBOutlet NSProgressIndicator *addDestinationsProgress;
@property (assign) IBOutlet NSPopover *addDestinationsChangeOutPeer;
@property (assign) IBOutlet NSViewController *addDestinationsChangeOutPeerController;
@property (assign) IBOutlet NSArrayController *addDestinationsWeBuyForChangeOutPeers;
@property (assign) IBOutlet AVTableView *addDestinationsChangeOutPeerView;
@property (assign) IBOutlet AVTableView *addDestinationsChangeOutPeerTableView;
@property (assign) IBOutlet NSButton *addDestinationsAddNewPeerToOutGroupList;
@property (assign) IBOutlet NSBox *addDestinationsBox;

// add destinations and import rates together
@property (assign) IBOutlet NSArrayController *addDestinationCarriersList;


// import rates or destinations view
@property (assign) IBOutlet NSPopover *importRatesPanel;
@property (assign) IBOutlet NSPanel *importRatesMainPanel;

//@property (assign) IBOutlet NSPopover *importRatesColumnSelectPanel;
//
//@property (assign) IBOutlet NSView *importRatesView;
//@property (assign) IBOutlet NSViewController *importRatesViewController;
//@property (assign) IBOutlet NSViewController *importRatesColumnSelectViewController;
//@property (assign) IBOutlet NSTableView *importRatesImportedRoutes;
//@property (assign) IBOutlet NSTableView *importRatesParsedRows;
//
//@property (assign) IBOutlet NSTableColumn *importRatesParsedCodes;
//@property (assign) IBOutlet AVTableView *importRatesCarrierList;
//@property (assign) IBOutlet AVTableView *importRatesCarriersRateSheet;
//@property (assign) IBOutlet NSDatePicker *importRatesEffectiveDate;
//@property (assign) IBOutlet NSArrayController *importRatesSelectionList;
//@property (assign) NSMutableString *importRatesRelationshipName;
//@property (assign) NSMutableString *importRatesCarrierName;
//@property (assign) NSMutableString *importRatesSelectedCountryForParsing;
//@property (assign) IBOutlet NSButton *importRatesStartParsing;
//@property (assign) IBOutlet NSPopUpButton *importRatesRatesheetList;
//@property (assign) IBOutlet NSProgressIndicator *importRatesProgress;
//@property (assign) IBOutlet NSTextField *importRatesPrefix;
//@property (assign) IBOutlet NSArrayController *importRatesFirsParserResult;
//@property (assign) IBOutlet AVTableView *importRatesCodesTableView;
//@property (assign) IBOutlet NSArrayController *importRatesSecondParserResult;
//@property (assign) IBOutlet NSPopUpButton *importRatesDestinationChoice;
//@property (assign) IBOutlet NSButton *importRatesApply;
//
-(void)localMocMustUpdate;


@end
