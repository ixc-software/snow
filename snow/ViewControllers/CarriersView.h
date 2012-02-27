//
//  CarriersView.h
//  snow
//
//  Created by Oleksii Vynogradov on 1/26/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "AVTableView.h"
#import "FinancialView.h"
#import "TwitterUpdateDataController.h"

@class desctopAppDelegate;


@interface CarriersView : NSViewController <NSTableViewDelegate,NSTableViewDataSource> {
    desctopAppDelegate *delegate;
    NSManagedObjectContext *moc;
    NSManagedObjectID *selectedCarrierID;
    FinancialView *financialView;
    
    NSMutableArray *allCarrierContactIDs;
    NSMutableArray *allCarrierFinancialIDs;
    NSMutableArray *allCarrierCompanyStufffIDs;
    NSMutableArray *allUpdatedObjectIDs;
    
    NSArrayController *carrier;

    NSButton *twitterAuthorizationButton;
    NSButton *addCarrier;
    NSButton *removeCarrier;
    NSButton *status;
    NSButton *profit;
    NSProgressIndicator *progress;
    NSSearchField *globalSearch;
    NSButton *syncCarrier;
    NSButton *financialInfo;
    NSSegmentedControl *filterByRating;
    NSProgressIndicator *globalSearchProgress;
    NSTextField *filterText;
    NSTableView *carriersTableView;
    NSButton *infoCarrierButton;
    NSPanel *errorPanel;
    NSTextField *errorText;
    NSPopover *infoViewPopover;
    NSPopover *financialViewPopover;
    NSPanel *infoViewPanel;
    NSPanel *financialViewPanel;
    NSViewController *infoViewController;
    NSViewController *financialViewController;
    AVTableView *contactsTableView;
    NSScrollView *contactsScrollView;
    NSPopUpButton *contactsChoice;
    AVTableView *responsibleTableView;
    NSProgressIndicator *responsibleProgress;
    NSPopUpButton *responsibleChoice;
    NSTextField *responsibleChoiceLabelInfo;
    AVTableView *detailsTableView;
    AVTableView *financialDetailsTableView;
    NSScrollView *financialDetailsScrollView;
    NSPopUpButton *financialChoice;
    AVTableView *companyDetailsTableView;
    NSPopUpButton *statisticChoicePeriod;
    NSDatePicker *statisticChoiceDateFrom;
    NSProgressIndicator *statisticProgress;
    NSButton *statisticTotalMysqlRecords;
    NSButton *statisticTotalLocalRecords;
    NSButton *statisticTotalMysqlRecordsWeBuy;
    NSButton *statisticTotalLocalRecordsWeBuy;
    NSArrayController *infoContacts;
    NSArrayController *infoResponsible;
    NSArrayController *infoDetails;
    NSArrayController *infoFinansialDetails;
    NSArrayController *infoCompanyDetails;
    NSTabView *infoTab;
    WebView *twitterWebView;
    NSTextField *pin;
    NSButton *authorizeButton;
    NSViewController *twitterAuthViewController;
    TwitterUpdateDataController *twitterController;
    NSPopover *twitterViewPopover;
    NSPanel *twitterViewPanel;
    NSNumber *introductionShowAgain;
    NSScrollView *introductionInfo;
    NSTextView *introductionText;
    NSPopover *introductionPopover;
    NSPanel *introductionPanel;
    NSButton *introductionButton;
    IBOutlet NSViewController *introductionViewController;
    IBOutlet NSPopover *importRatesPanel;
    NSPanel *importRatesMainPanel;

}
@property (assign) desctopAppDelegate *delegate;
@property (assign) NSManagedObjectContext *moc;
@property (assign) FinancialView *financialView;
@property (assign) TwitterUpdateDataController *twitterController;


@property (assign) IBOutlet NSArrayController *carrier;
// main block
@property (assign) IBOutlet NSButton *twitterAuthorizationButton;
@property (assign) IBOutlet NSButton *addCarrier;
@property (assign) IBOutlet NSButton *removeCarrier;
@property (assign) IBOutlet NSButton *status;
@property (assign) IBOutlet NSButton *profit;
@property (assign) IBOutlet NSProgressIndicator *progress;
@property (assign) IBOutlet NSSearchField *globalSearch;
@property (assign) IBOutlet NSButton *syncCarrier;
@property (assign) IBOutlet NSButton *financialInfo;
@property (assign) IBOutlet NSSegmentedControl *filterByRating;
@property (assign) IBOutlet NSProgressIndicator *globalSearchProgress;
@property (assign) IBOutlet NSTextField *filterText;
@property (assign) IBOutlet NSPopover *infoViewPopover;
@property (assign) IBOutlet NSPopover *financialViewPopover;
@property (assign) IBOutlet NSPanel *infoViewPanel;
@property (assign) IBOutlet NSPanel *financialViewPanel;
@property (assign) IBOutlet NSViewController *infoViewController;
@property (assign) IBOutlet NSViewController *financialViewController;

@property (assign) IBOutlet NSTableView *carriersTableView;
@property (assign) IBOutlet NSButton *infoCarrierButton;

// finacial block

// info block
@property (assign) IBOutlet NSTabView *infoTab;
@property (assign) IBOutlet AVTableView *contactsTableView;
@property (assign) IBOutlet NSScrollView *contactsScrollView;
@property (assign) IBOutlet NSPopUpButton *contactsChoice;
@property (assign) IBOutlet AVTableView *responsibleTableView;
@property (assign) IBOutlet NSProgressIndicator *responsibleProgress;
@property (assign) IBOutlet NSPopUpButton *responsibleChoice;
@property (assign) IBOutlet NSTextField *responsibleChoiceLabelInfo;
@property (assign) IBOutlet AVTableView *detailsTableView;
@property (assign) IBOutlet AVTableView *financialDetailsTableView;
@property (assign) IBOutlet NSScrollView *financialDetailsScrollView;
@property (assign) IBOutlet NSPopUpButton *financialChoice;
@property (assign) IBOutlet AVTableView *companyDetailsTableView;
@property (assign) IBOutlet NSPopUpButton *statisticChoicePeriod;
@property (assign) IBOutlet NSDatePicker *statisticChoiceDateFrom;
@property (assign) IBOutlet NSProgressIndicator *statisticProgress;
@property (assign) IBOutlet NSButton *statisticTotalMysqlRecords;
@property (assign) IBOutlet NSButton *statisticTotalLocalRecords;
@property (assign) IBOutlet NSButton *statisticTotalMysqlRecordsWeBuy;
@property (assign) IBOutlet NSButton *statisticTotalLocalRecordsWeBuy;
@property (assign) IBOutlet NSArrayController *infoContacts;
@property (assign) IBOutlet NSArrayController *infoResponsible;
@property (assign) IBOutlet NSArrayController *infoDetails;
@property (assign) IBOutlet NSArrayController *infoFinansialDetails;
@property (assign) IBOutlet NSArrayController *infoCompanyDetails;

// twitter auth block;

@property (assign) IBOutlet WebView *twitterWebView;
@property (assign) IBOutlet NSTextField *pin;
@property (assign) IBOutlet NSButton *authorizeButton;
@property (assign) IBOutlet NSViewController *twitterAuthViewController;

// error block
@property (assign) IBOutlet NSPanel *errorPanel;
@property (assign) IBOutlet NSTextField *errorText;

// indroduction view
@property (retain) NSNumber *introductionShowAgain;
@property (assign) IBOutlet NSScrollView *introductionInfo;
@property (assign) IBOutlet NSTextView *introductionText;
@property (assign) IBOutlet NSPopover *introductionPopover;
@property (assign) IBOutlet NSPanel *introductionPanel;
@property (assign) IBOutlet NSButton *introductionButton;

// import rates block
@property (assign) IBOutlet NSPopover *importRatesPanel;
@property (assign) IBOutlet NSPanel *importRatesMainPanel;

-(void)localMocMustUpdate;
-(void) introductionShowFromOutsideView;

@end
