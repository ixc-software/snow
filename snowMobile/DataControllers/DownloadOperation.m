//
//  DownloadOperation.m
//  snow
//
//  Created by Alex Vinogradov on 02.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DownloadOperation.h"
#import "CountrySpecificCodeList.h"
#import "CodesList.h"
#import "CurrentCompany.h"
#import "DestinationsListPushList.h"
#import "Carrier.h"
#import "CompanyStuff.h"
//#import "UserDataController.h"
#import "Events.h"
#import "MainSystem.h"

#import "ClientController.h"
#import "mobileAppDelegate.h"
@interface DownloadOperation ()
@property (nonatomic, readwrite) BOOL downloadCompleted;
//@property (nonatomic, assign) NSAutoreleasePool *importPool;
@property (nonatomic,retain) NSNumber *downloadSize;
@property (nonatomic,retain) NSMutableData *receivedData;

-(void) updateProgessInfoWithPercent:(NSNumber *)percent;


@end

@implementation DownloadOperation
@synthesize persistentStoreCoordinator,insertionContext,delegate,downloadCompleted,downloadExternalDataWasUnsucceseful,operationName,percentDone,downloadSize,receivedData,isError,isItLatestMessage;

- (void)dealloc {
    //[downloadSize release];
    //[persistentStoreCoordinator release];
    [insertionContext release];
    [super dealloc];
}
//-(void) downLoadForURL:(NSURL *)url
//{
//    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
//                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
//                                          timeoutInterval:60];
//    
//    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    
//    if (theConnection) {
//        // Create the NSMutableData to hold the received data.
//        // receivedData is an instance variable declared elsewhere.
//        receivedData = [[NSMutableData data] retain];
//    } else {
//        // Inform the user that the connection failed.
//    }
//
//}

//-(MainSystem *)getMainSystem;
//{
//    NSError *error = nil;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainSystem" inManagedObjectContext:insertionContext];
//    [fetchRequest setEntity:entity];
//    NSArray *result = [insertionContext executeFetchRequest:fetchRequest error:&error];
//    MainSystem *mainSystem = [result lastObject];
//    [fetchRequest release];
//    return mainSystem;
//}

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    NSNumber *progress = nil;
    if ([data count] > 1) {
        progress = [data objectAtIndex:1];
    } else progress = [NSNumber numberWithInt:0];
    NSString *status = [data objectAtIndex:0];//withProgressEnabled:(BOOL)isProgressEnabled forObjectID:(NSManagedObjectID *)objectID andPercent:(NSNumber *)percent
    //NSLog(@"DOWNLOAD:update UI:%@",status);
    if ([status isEqualToString:@"progress for update graph:CountrySpecificCodeList"]) status = @"internal codes matrix updating...";
    self.operationName = status;
    self.percentDone = progress;
    [self updateProgessInfoWithPercent:progress];
    NSNumber *isItLatestMessageExternal = [data objectAtIndex:2];
    self.isItLatestMessage = [isItLatestMessageExternal boolValue];
    
    NSNumber *isErrorReceived = [data objectAtIndex:3];
    if ([isErrorReceived boolValue]) {
        self.isError = YES;
        
//        dispatch_async(dispatch_get_main_queue(), ^(void) { 
//            
//            iphoneAppDelegate *delegateShared = (iphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
//            NSArray *viewControllers = delegateShared.tabBarController.viewControllers;
//            UINavigationController *info = [viewControllers objectAtIndex:0];
//            
//            
//            UISegmentedControl *alert = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:status]];
//            alert.segmentedControlStyle = UISegmentedControlStyleBar;
//            alert.frame = CGRectMake(0, (info.toolbar.bounds.size.height - alert.frame.size.height)/2, info.toolbar.bounds.size.width - (info.toolbar.bounds.size.height - alert.frame.size.height), alert.frame.size.height);
//            alert.userInteractionEnabled = NO;
//            alert.selectedSegmentIndex = 0;
//            alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];;
//            
//            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:alert];
//            //UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:status style:UIBarButtonItemStylePlain target:nil action:NULL];
//            
//            [info setToolbarItems:[NSArray arrayWithObject:item]];
//            info.toolbar.translucent = YES;
//            info.toolbar.backgroundColor = [UIColor clearColor];
//            info.toolbar.barStyle = UIBarStyleBlack;
//            
//            info.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
//            [info setToolbarHidden:NO animated:YES];
//        });
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//            sleep(10);
//            dispatch_async(dispatch_get_main_queue(), ^(void) { 
//                iphoneAppDelegate *delegateShared = (iphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
//                NSArray *viewControllers = delegateShared.tabBarController.viewControllers;
//                UINavigationController *info = [viewControllers objectAtIndex:0];
//                [info setToolbarHidden:YES animated:YES]; 
//            });
//        });

    } else self.isError = NO;
    
}

- (void)main;
{
    @autoreleasepool {
        self.operationName = @"Prepare internal data";
        NSLog(@"%@",operationName);

        [self updateProgessInfoWithPercent:[NSNumber numberWithDouble:0]];
        
        //self.importPool = [[NSAutoreleasePool alloc] init];
        
        if (delegate && [delegate respondsToSelector:@selector(importerDidSave:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
        }
        mobileAppDelegate *delegateShared = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[insertionContext persistentStoreCoordinator] withSender:self withMainMoc:[delegateShared managedObjectContext]];
        self.operationName = @"Frst setup";
        NSLog(@"%@",operationName);

        [self updateProgessInfoWithPercent:[NSNumber numberWithDouble:0]];
        [clientController firstSetup];
        
        self.operationName = @"Get companies list.";
        NSLog(@"%@",operationName);

        [self updateProgessInfoWithPercent:[NSNumber numberWithDouble:0]];
        
        [clientController getCompaniesListWithImmediatelyStart:YES];

        self.operationName = @"Update internal codes";

        NSLog(@"%@",operationName);

        [clientController updateInternalCountryCodesList];

        self.operationName = @"Download from V5.0 data";

        [clientController getCarriersList];

//        //    [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:NO isUserAuthorized:NO];
        self.operationName = @"Download events data";
        NSLog(@"%@",operationName);

        self.percentDone = [NSNumber numberWithDouble:0];
        [self updateProgessInfoWithPercent:[NSNumber numberWithDouble:0]];
        
        //[clientController getAllObjectsForEntity:@"Events" immediatelyStart:YES isUserAuthorized:NO];
        
         [clientController release];
        NSError *error = nil;
        if (![insertionContext save:&error]) {
            NSLog(@"Unhandled error saving managed object context in import thread: %@", [error localizedDescription]);
            NSLog(@"%@",[[error userInfo] valueForKey:@"conflictList"]);
        }
        self.operationName = @"";
        self.percentDone = [NSNumber numberWithDouble:0];
        [self updateProgessInfoWithPercent:self.percentDone];
        
        if (delegate && [delegate respondsToSelector:@selector(importerDidSave:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
        }
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(importerDidFinishParsingData:)]) {
            [self.delegate importerDidFinishParsingData:self];
        }
        //    [fetchRequest release];
    }

}

-(void) updateProgessInfoWithPercent:(NSNumber *)percent;
{
    self.percentDone = percent;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(importerDidFinishParsingData:)]) {
        [self.delegate importerDidChangeParsingData:self];
    }

}

- (NSManagedObjectContext *)insertionContext {
    if (insertionContext == nil) {
        insertionContext = [[NSManagedObjectContext alloc] init];
        [insertionContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return insertionContext;
}

-(void) safeSave
{
    NSError *saveError = nil;
#pragma unused (saveError)

    NSAssert1([insertionContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
}

//#pragma mark - URL download delegates
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    //NSInteger statusCode_ = [response statusCode];
//    //if (statusCode_ == 200) {
//    self.downloadSize = [[NSNumber alloc] initWithLongLong:[response expectedContentLength]];
//    //}
//    // This method is called when the server has determined that it
//    // has enough information to create the NSURLResponse.
//    
//    // It can be called multiple times, for example in the case of a
//    // redirect, so each time we reset the data.
//    
//    // receivedData is an instance variable declared elsewhere.
//    [receivedData setLength:0];
//}
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    // Append the new data to receivedData.
//    // receivedData is an instance variable declared elsewhere.
//    [receivedData appendData:data];
//
//    self.percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:[self.receivedData length]] doubleValue] / [self.downloadSize doubleValue]];
//    if (!downloadCompleted) [self updateProgessInfoWithPercent:self.percentDone];
//
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
//{
//    self.downloadCompleted = YES;
//
//    // release the connection, and the data object
//    [connection release];
//    // receivedData is declared as a method instance elsewhere
//    [receivedData release];
//    self.operationName = @"Download failed. please check u connection";
//    [self updateProgessInfoWithPercent:self.percentDone];
//
//    // inform the user
//    NSLog(@"Connection failed! Error - %@ %@",
//          [error localizedDescription],
//          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
//}
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    if (![receivedData writeToURL:[[NSBundle mainBundle] URLForResource:@"nextTwoWeekEvents" withExtension:@"ary"] atomically:YES])
//        NSLog(@"Write was failed");
//    // do something with the data
//    // receivedData is declared as a method instance elsewhere
//    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
//    self.downloadCompleted = YES;
//    // release the connection, and the data object
//    [connection release];
//    [receivedData release];
//}

@end
