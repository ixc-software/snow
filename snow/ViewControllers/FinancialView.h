//
//  FinancialViewController.h
//  snow
//
//  Created by Oleksii Vynogradov on 30.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class desctopAppDelegate;

@interface FinancialView : NSViewController <NSTableViewDelegate>{
@private
    desctopAppDelegate *delegate;

    IBOutlet NSArrayController *invoices;
    IBOutlet NSArrayController *payments;
    IBOutlet NSArrayController *financial;
    IBOutlet NSSearchField *search;
    IBOutlet NSButton *disputedSum;
    IBOutlet NSButton *invoicesDifference;
    IBOutlet NSButton *carrierBalance;
    IBOutlet NSPathControl *pathToInvoice;
//    IBOutlet NSArrayController *carriers;
    IBOutlet NSPopUpButton *carrierFinancialChoice;
    IBOutlet NSSegmentedControl *invoicesReceivedSentChoice;
    IBOutlet NSSegmentedControl *paymentsReceiveSentChoice;
    //__weak AppDelegate *appDelegate;

//    IBOutlet NSPanel *financialPanel;
    IBOutlet NSButton *summTotalSelectedPayments;
    IBOutlet NSButton *summTotalSelectedInvoices;
    IBOutlet NSButton *newInvoice;
    IBOutlet NSButton *newPayment;
    IBOutlet NSTableView *invoicesTableView;
    IBOutlet NSTableView *paymentsTableView;
    IBOutlet NSBox *invoicesBox;

    // new received invoice block:
    IBOutlet NSPanel *newReceivedInvoicePanel;
    IBOutlet NSPopover *newReceivedInvoicePopover;
    IBOutlet NSViewController *newReceivedInvoiceViewController;
    
    IBOutlet NSBox *newReceivedInvoice;
    IBOutlet NSPathControl *newReceivedInvoicePath;
    IBOutlet NSTextField *newReceivedInvoiceNumber;
    IBOutlet NSButton *newReceivedInvoiceInternalAmount;
    IBOutlet NSTextField *newReceivedInvoiceInvoiceAmount;
    IBOutlet NSPopUpButton *newReceivedInvoiceCurrency;
    IBOutlet NSPopUpButton *newReceivedInvoiceCompanyAccounts;
    IBOutlet NSDatePicker *newReceivedInvoiceFrom;
    IBOutlet NSDatePicker *newReceivedInvoiceTo;
    IBOutlet NSDatePicker *newReceivedInvoiceWhen;
    NSManagedObjectID *selectedCarrierID;
    IBOutlet NSProgressIndicator *progressUpdate;
    IBOutlet NSButton *changeAccountAlert;
    BOOL newReceivedInvoiceCompanyAccountChanged;
    BOOL newReceivedInvoiceDatePickerChanged;
    BOOL isInvoicePreviewDone;

    IBOutlet NSButton *addInvoiceFile;
    IBOutlet NSButton *applyAndCreateDispute;
    IBOutlet NSButton *apply;
    
    // invoice after generation
//    IBOutlet NSPanel *invoice;
    IBOutlet NSBox *invoiceBox;
    IBOutlet NSView *invoiceFrame;
    IBOutlet NSPanel *invoicePanel;
    IBOutlet NSPopover *invoicePopover;
    IBOutlet NSViewController *invoiceViewController;

    IBOutlet NSImageView *logo;
    IBOutlet NSTextField *companyNameAddressPhone;
    IBOutlet NSTextField *companyBankingDetails;
    IBOutlet NSTextField *invoiceNumber;
    
    IBOutlet NSTextField *carrierNameAndAddress;
    IBOutlet NSArrayController *invoiceGenerationFullData;
    IBOutlet NSArrayController *invoiceGenerationPerDestinationsData;
    IBOutlet NSTableView *invoiceGenerationFullDataTableView;
    IBOutlet NSTableView *invoiceGenerationPerDestinationsDataTableView;
    IBOutlet NSButton *closeButton;
    NSRect initialInvoiceGenerationPerDestinationsDataTableView;
    NSRect initialInvoiceBox;
    NSRect initialCloseButton;
    NSRect initialInvoiceFrame;
    NSRect initialMainInvoiceFrame;
    
    // edit company account details panel
    
//    IBOutlet NSPanel *companyAccountDetails;
    IBOutlet NSTableView *companyAccountDetailsTableView;
    
    IBOutlet NSArrayController *companyAccounts;
    IBOutlet NSArrayController *companyAccountsVerticalView;
    NSManagedObjectContext *moc;
    IBOutlet NSWindow *financialWindow;

}
@property (assign) desctopAppDelegate *delegate;

- (void) prepare;
@property (readwrite) BOOL newReceivedInvoiceCompanyAccountChanged;
@property (readwrite) BOOL newReceivedInvoiceDatePickerChanged;
@property (readwrite) BOOL isInvoicePreviewDone;
@property (assign) NSManagedObjectContext *moc;

@end
