//
//  ImportRatesViewClass.h
//  snow
//
//  Created by Oleksii Vynogradov on 1/21/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AVTableView.h"


@class desctopAppDelegate;

@interface ImportRatesView : NSViewController
{
    NSManagedObjectContext *moc;
    desctopAppDelegate *delegate;
    NSManagedObjectID *dragToCarrier;
    
    // import rates or destinations view
    NSPopover *importRatesPanel;
    NSPopover *importRatesColumnSelectPanel;
    
//    NSView *importRatesView;
    NSViewController *importRatesViewController;
    NSViewController *importRatesColumnSelectViewController;
    NSTableView *importRatesImportedRoutes;
    NSTableView *importRatesParsedRows;
    
//    NSTableColumn *importRatesParsedCodes;
    AVTableView *importRatesCarrierList;
    AVTableView *importRatesCarriersRateSheet;
    NSDatePicker *importRatesEffectiveDate;
    NSArrayController *importRatesSelectionList;
    NSMutableString *importRatesRelationshipName;
    NSMutableString *importRatesCarrierName;
    NSMutableString *importRatesSelectedCountryForParsing;
    NSButton *importRatesStartParsing;
    NSPopUpButton *importRatesRatesheetList;
    NSProgressIndicator *importRatesProgress;
    NSTextField *importRatesPrefix;
    NSArrayController *importRatesFirsParserResult;
    AVTableView *importRatesCodesTableView;
    NSArrayController *importRatesSecondParserResult;
    NSTextField *importDestinationsLabel;
    NSSegmentedControl *chooseDestinationsType;
    NSButton *removePreviousButton;
    NSTextField *chooseExcelSheetLabel;
    NSButton *uncheckedLines;
    NSPopUpButton *importRatesDestinationChoice;
    NSButton *importRatesApply;
    NSArrayController *addDestinationCarriersList;
    NSURL *parsedFileURL;
}

@property (assign) desctopAppDelegate *delegate;
@property (assign) NSManagedObjectContext *moc;
@property (assign) NSManagedObjectID *dragToCarrier;
@property (assign) NSMutableString *importRatesRelationshipName;
@property (assign) NSMutableString *importRatesCarrierName;
@property (assign) NSMutableString *importRatesSelectedCountryForParsing;

// import rates or destinations view
@property (assign) IBOutlet NSPopover *importRatesPanel;
@property (assign) IBOutlet NSPopover *importRatesColumnSelectPanel;

//@property (assign) IBOutlet NSView *importRatesView;
@property (assign) IBOutlet NSViewController *importRatesViewController;
@property (assign) IBOutlet NSViewController *importRatesColumnSelectViewController;
@property (assign) IBOutlet NSTableView *importRatesImportedRoutes;
@property (assign) IBOutlet NSTableView *importRatesParsedRows;

//@property (assign) IBOutlet NSTableColumn *importRatesParsedCodes;
@property (assign) IBOutlet AVTableView *importRatesCarrierList;
@property (assign) IBOutlet AVTableView *importRatesCarriersRateSheet;
@property (assign) IBOutlet NSDatePicker *importRatesEffectiveDate;
@property (assign) IBOutlet NSButton *importRatesStartParsing;
@property (assign) IBOutlet NSPopUpButton *importRatesRatesheetList;
@property (assign) IBOutlet NSProgressIndicator *importRatesProgress;
@property (assign) IBOutlet NSTextField *importRatesPrefix;
@property (assign) IBOutlet AVTableView *importRatesCodesTableView;
@property (assign) IBOutlet NSPopUpButton *importRatesDestinationChoice;
@property (assign) IBOutlet NSButton *importRatesApply;

@property (assign) IBOutlet NSArrayController *addDestinationCarriersList;
@property (assign) IBOutlet NSArrayController *importRatesSelectionList;
@property (assign) IBOutlet NSArrayController *importRatesFirsParserResult;
@property (assign) IBOutlet NSArrayController *importRatesSecondParserResult;

@property (assign) IBOutlet NSTextField *importDestinationsLabel;
@property (assign) IBOutlet NSSegmentedControl *chooseDestinationsType;
@property (assign) IBOutlet NSButton *removePreviousButton;
@property (assign) IBOutlet NSTextField *chooseExcelSheetLabel;
@property (assign) IBOutlet NSButton *uncheckedLines;

@property (retain) NSURL *parsedFileURL;

- (void)loadView;


@end
