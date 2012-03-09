//
//  FirstAuthorizationSetup.m
//  snow
//
//  Created by Oleksii Vynogradov on 22.11.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import "FirstAuthorizationSetup.h"
#import "FirstAuthorizationSetupCompaniesList.h"

#import "desctopAppDelegate.h"
#import "ClientController.h"

#import "CurrentCompany.h"
#include <QuartzCore/QuartzCore.h>


@implementation FirstAuthorizationSetup
@synthesize loginRegistrationErrorView;
//@synthesize firstAuthorizationSetupCompaniesList;
@synthesize registeredCompaniesBox;
@synthesize popoverView;
@synthesize errorMessage;
@synthesize namedLogo;
@synthesize progressLogin;
@synthesize logo;
@synthesize companiesListScrollView;
@synthesize companiesListTableView;
@synthesize logoName;
@synthesize email;
@synthesize password;
@synthesize company;
@synthesize selectorToCompaniesList;
@synthesize companiesList;
@synthesize moc;
@synthesize currentCompany;
@synthesize registration;
@synthesize login;
@synthesize isTremorEmailLeftMoving,tremorEmailCount,tremorCompanyCount,isTremorCompanyLeftMoving,isTremorPasswordLeftMoving,tremorPasswordCount,isCompanyListVisible,isCompanyListProcessingAnimation, isCompanyListWasSelected,deltaToMovingDownLoginPassLogoProgress,isLoginPassLogoProgressInDownPosition,isCompaniesListTableViewHeightChanged,deltaCompaniesListScrollAndTableHeight,deltaCompaniesListScrollViewHeightAndCompaniesListBoxHeight;

@synthesize enterprise;
@synthesize selectedCompanyID;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        [moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setPersistentStoreCoordinator:delegate.persistentStoreCoordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(companyDidChange:) name:NSControlTextDidChangeNotification object:company];
        //        [login layer]. = NSMakeRect(login.frame.origin.x, login.frame.origin.y, login.frame.size.width * 2, login.frame.size.width * 2);
//        isLoginPassLogoProgressInDownPosition = NO;
//        NSUInteger companiesScrollHeight = companiesListScrollView.frame.size.height;
//        NSUInteger companiesTableHeight = companiesListTableView.frame.size.height;
//        deltaCompaniesListScrollViewHeightAndCompaniesListBoxHeight = companiesListScrollView.frame.size.height - companiesList.frame.size.height;
//        
//
//        
//        deltaCompaniesListScrollAndTableHeight = companiesScrollHeight - companiesTableHeight;
        
        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:delegate.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@",@"ixc global"];
//        [fetchRequest setPredicate:predicate];
//        NSError *error = nil;
//        NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        [fetchRequest release];
//        NSLog(@"objects:%@",fetchedObjects);
//        [fetchedObjects enumerateObjectsUsingBlock:^(CurrentCompany *comp, NSUInteger idx, BOOL *stop) {
//            NSLog(@"comp:%@",comp.name);
//
//        }];
//
//        if ([fetchedObjects count] < 10) {
//            for (int i = [fetchedObjects count]; i < 7; i++) {
//                
//                CurrentCompany *newCompany = (CurrentCompany *)[NSEntityDescription 
//                                                                insertNewObjectForEntityForName:@"CurrentCompany" 
//                                                                inManagedObjectContext:moc];
//                newCompany.name = [NSString stringWithFormat:@"ixc global %@",[NSNumber numberWithInteger:i]]; 
//            }
//            NSError *error = nil;
//            [self.moc save:&error];
//            if (error) NSLog(@"%@",[error localizedDescription]);
//            
//        }
//        companiesListPopOver = [[[INPopoverController alloc] initWithContentViewController:[[FirstAuthorizationSetupCompaniesList alloc] initWithNibName:@"FirstAuthorizationSetupCompaniesList" bundle:nil]] autorelease];
//        companiesListPopOver.closesWhenPopoverResignsKey = NO;
//        companiesListPopOver.color = [NSColor colorWithDeviceRed:0.52 green:0.54 blue:0.70 alpha:0.8];
//        companiesListPopOver.borderColor = [NSColor blackColor];
//        companiesListPopOver.borderWidth = 2.0;
//        firstAuthorizationSetupCompaniesList = [[FirstAuthorizationSetupCompaniesList alloc] initWithNibName:@"FirstAuthorizationSetupCompaniesList" bundle:nil];
    }
    
    return self;
}


- (void)importerDidSave:(NSNotification *)saveNotification {
    //NSLog(@"MERGE in First authorization controller");
    if ([NSThread isMainThread]) {
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        [[delegate managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
    } else {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}
#pragma mark -
#pragma mark Animation block

-(void) didTremorFor:(NSTextField *)tremoredText isFirstStart:(BOOL)isFirstStart
{
    CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    controlPosAnim.delegate = self;
    controlPosAnim.duration = 0.05;
    
    
    NSTextField *tremoredObject;
    NSString *placeholder = [[tremoredText cell] placeholderString];
    BOOL isLeftMoving = NO;
    
    if ([placeholder isEqualToString:@"email (required)"]) {
        if (isFirstStart) tremorEmailCount = 0;
        tremoredObject = email;
        [controlPosAnim setValue:@"email" forKey:@"id"]; 
        isLeftMoving = isTremorEmailLeftMoving;
        
        //        NSLog(@"AUTHORIZATION: email changed to:%@",emailString);
    }
    if ([placeholder isEqualToString:@"password (required)"]) {
        if (isFirstStart) tremorPasswordCount = 0;
        tremoredObject = password;
        [controlPosAnim setValue:@"password" forKey:@"id"]; 
        isLeftMoving = isTremorPasswordLeftMoving;
        
        //        NSLog(@"AUTHORIZATION: password changed to:%@",passwordString);
        
    }
    if ([placeholder isEqualToString:@"company name (required for registration)"]) {
        if (isFirstStart) tremorCompanyCount = 0;
        tremoredObject = company;
        [controlPosAnim setValue:@"company" forKey:@"id"]; 
        isLeftMoving = isTremorCompanyLeftMoving;
        
        //        NSLog(@"AUTHORIZATION: companyString changed to:%@",companyString);
        
    }
    
    NSRect viewRect = [tremoredObject frame];
    
    NSPoint startingPoint = viewRect.origin;
    NSPoint endingPoint = startingPoint;
    
    if (isLeftMoving) endingPoint.x -= 4;
    else endingPoint.x += 4;
    
    //    NSLog(@"%@",[controlPosAnim.delegate class]);
    
    controlPosAnim.fromValue = [NSValue valueWithPoint:startingPoint];
    controlPosAnim.toValue = [NSValue valueWithPoint:endingPoint];
    
    [[tremoredObject  layer] addAnimation:controlPosAnim forKey:@"controlViewPosition"];
    
    
    if (isLeftMoving) [tremoredObject  setFrame:NSMakeRect(viewRect.origin.x - 4, viewRect.origin.y, viewRect.size.width, viewRect.size.height)]; else [tremoredObject  setFrame:NSMakeRect(viewRect.origin.x + 4, viewRect.origin.y, viewRect.size.width, viewRect.size.height)]; 
    
}

- (void) didCompanyListIsVisible:(BOOL)isVisible
{
    
    if (!isCompanyListProcessingAnimation) {
        
        if (isVisible) {
            [self.currentCompany setSelectedObjects:nil];
            NSNumber *alphaFrom = nil;
            NSNumber *alphaTo = nil;
            
            isCompanyListProcessingAnimation = YES;
            
            alphaFrom = [NSNumber numberWithFloat:0.0];
            alphaTo = [NSNumber numberWithFloat:1.0];
            
            CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [controlPosAnim setValue:@"companyList" forKey:@"id"]; 
            controlPosAnim.delegate = self;
            controlPosAnim.duration = 2;
            controlPosAnim.fromValue = alphaFrom;
            controlPosAnim.toValue = alphaTo;
            [[companiesList  layer] addAnimation:controlPosAnim forKey:@"opacity"];
            [[selectorToCompaniesList  layer] addAnimation:controlPosAnim forKey:@"opacity"];
            [[selectorToCompaniesList layer] setOpacity:1.0]; 
            [[companiesList  layer] setOpacity:1.0];
            isCompanyListVisible = YES;
        }
        else { 
            isCompanyListProcessingAnimation = NO;
            [[selectorToCompaniesList  layer] setOpacity:0.0];
            [[companiesList  layer] setOpacity:0.0];
            isCompanyListVisible = NO;
            
            
        }
        
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSString *animID = [theAnimation valueForKey:@"id"];
    NSUInteger tremorCount = 0;
    
    if ([animID isEqualToString:@"email"]) {
        self.isTremorEmailLeftMoving = !self.isTremorEmailLeftMoving;
        tremorEmailCount = tremorEmailCount + 1;
        tremorCount = tremorEmailCount;
    }
    if ([animID isEqualToString:@"password"]) {
        self.isTremorPasswordLeftMoving = !self.isTremorPasswordLeftMoving;
        tremorPasswordCount = tremorPasswordCount + 1;
        tremorCount = tremorPasswordCount;
    }
    if ([animID isEqualToString:@"company"]) {
        self.isTremorCompanyLeftMoving = !self.isTremorCompanyLeftMoving;
        tremorCompanyCount = tremorCompanyCount + 1;        
        tremorCount = tremorCompanyCount;
    }
    if ([animID isEqualToString:@"companyList"]) {
        isCompanyListProcessingAnimation = NO;
        //        if (isCompanyListVisible) { 
        //            [[selectorToCompaniesList animator] setOpacity:1.0]; 
        //            [[companiesList  animator] setOpacity:1.0];
        //        }
        //        else { 
        //            [[selectorToCompaniesList  animator] setOpacity:0.0];
        //            [[companiesList  animator] setOpacity:0.0];
        //
        //        }
    }
    
    //    self.isTremorEmailLeftMoving = !self.isTremorEmailLeftMoving;
    //    tremorEmailCount = tremorEmailCount + 1;
    if ([animID isEqualToString:@"error"]) {
        //sleep(5);
        [[errorMessage  layer] setOpacity:0.0];
        //[self performSelector:@selector(showErrorMessage:) withObject:[theAnimation valueForKey:@"message"]];
    }
    if (tremorCount < 8) { 
        
        if ([animID isEqualToString:@"email"]) [self didTremorFor:email isFirstStart:NO];
        if ([animID isEqualToString:@"password"]) [self didTremorFor:password isFirstStart:NO];
        if ([animID isEqualToString:@"company"]) [self didTremorFor:company isFirstStart:NO];
    }
    
}
- (void)animationDidStart:(CAAnimation *)theAnimation
{
    
}

-(void)hideAuthorizationView
{
    [self.view setHidden:YES];
    desctopAppDelegate *delegate = (desctopAppDelegate *)[NSApplication sharedApplication].delegate;
    [delegate.window setFrame:delegate.startupPosition display:NO];
    [delegate.currentUserInfoList setHidden:NO];
    [delegate updateWellcomeTitle];
    [delegate.carriersView introductionShowFromOutsideView];
    [delegate.showHideUserCompanyInfo setHidden:NO];
    [delegate.mainLogo setHidden:YES];
    [delegate.mainLogoTitle setHidden:YES];
    [delegate.mainLogoSubTitle setHidden:YES];
    [delegate.mainLogoSubSubTitle setHidden:YES];

    
    #if defined(SNOW_CLIENT_APPSTORE)
#else
    [delegate.getExternalInfoButton setHidden:NO];
    
#endif
    //[[delegate.window toolbar] setVisible:YES];
//    [delegate.viewForHideInterface removeFromSuperview];
//    CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    [controlPosAnim setValue:@"auth" forKey:@"id"]; 
//    controlPosAnim.delegate = self;
//    controlPosAnim.duration = 2;
//    controlPosAnim.fromValue = [NSNumber numberWithFloat:1.0];
//    controlPosAnim.toValue = [NSNumber numberWithFloat:0.0];
//    [[self.view layer] addAnimation:controlPosAnim forKey:@"opacity"];
//    [[self.view layer] setOpacity:0.0];
////    [[self.view layer] setHidden:YES];
}

-(void) showErrorMessage:(NSString *)message
{
    errorMessage.stringValue = message;
    CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [controlPosAnim setValue:@"error" forKey:@"id"]; 
    [controlPosAnim setValue:message forKey:@"message"]; 
    
    controlPosAnim.delegate = self;
    controlPosAnim.duration = 1;
    controlPosAnim.repeatCount = 4.0;
    controlPosAnim.fromValue = [NSNumber numberWithFloat:0.0];
    controlPosAnim.toValue = [NSNumber numberWithFloat:1.0];
    [[errorMessage layer] addAnimation:controlPosAnim forKey:@"opacity"];
    [[errorMessage layer] setOpacity:0.0];
    
}
//
//- (void) loginRegistrationSpinLogoIsMovingDown:(BOOL)isMovingDown
//{
//    if (isMovingDown && !isLoginPassLogoProgressInDownPosition) {
//        //NSLog(@"moving down, delta:%u",deltaToMovingDownLoginPassLogoProgress);
//        
////        login.frame = NSMakeRect(login.frame.origin.x, login.frame.origin.y - deltaToMovingDownLoginPassLogoProgress, login.frame.size.width, login.frame.size.height);
////        registration.frame = NSMakeRect(registration.frame.origin.x, registration.frame.origin.y - deltaToMovingDownLoginPassLogoProgress, registration.frame.size.width, registration.frame.size.height);
////        progressLogin.frame = NSMakeRect(progressLogin.frame.origin.x, progressLogin.frame.origin.y - deltaToMovingDownLoginPassLogoProgress, progressLogin.frame.size.width, progressLogin.frame.size.height);
////        namedLogo.frame = NSMakeRect(namedLogo.frame.origin.x, namedLogo.frame.origin.y - deltaToMovingDownLoginPassLogoProgress, namedLogo.frame.size.width, namedLogo.frame.size.height);
////        errorMessage.frame = NSMakeRect(errorMessage.frame.origin.x, errorMessage.frame.origin.y - deltaToMovingDownLoginPassLogoProgress, errorMessage.frame.size.width, errorMessage.frame.size.height);
////        
////        if (errorMessage.frame.origin.y + errorMessage.frame.size.height > self.view.frame.size.height) self.view.frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + self.view.frame.origin.y - errorMessage.frame.origin.y + errorMessage.frame.size.height);
//        NSUInteger delta = self.view.frame.origin.y + self.view.frame.size.height - (loginRegistrationErrorView.frame.origin.y + loginRegistrationErrorView.frame.size.height);
//        
//        loginRegistrationErrorView.frame = NSMakeRect(loginRegistrationErrorView.frame.origin.x, loginRegistrationErrorView.frame.origin.y - deltaToMovingDownLoginPassLogoProgress, loginRegistrationErrorView.frame.size.width, loginRegistrationErrorView.frame.size.height);
//        isLoginPassLogoProgressInDownPosition = YES;
//        
//        if (self.view.frame.origin.y + self.view.frame.size.height > loginRegistrationErrorView.frame.origin.y + loginRegistrationErrorView.frame.size.height) { 
//            AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
//            NSWindow *mainWindow = delegate.window;
//            //[mainWindow setFrame:NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y - delta, mainWindow.frame.size.width, self.view.frame.size.height + delta) display:NO animate:NO];
//            NSUInteger currentWidth = self.view.frame.size.width;
//            self.view.frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y - delta, currentWidth, self.view.frame.size.height + delta);
//            [mainWindow setFrame:NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y, currentWidth, self.view.frame.size.height) display:YES animate:YES];
//
////            delegate.window.frame = NSMakeRect(delegate.window.frame.origin.x, delegate.window.frame.origin.y, delegate.window.frame.size.width, self.view.frame.size.height + delta);
//        }
//
//    } 
//    if (!isMovingDown && isLoginPassLogoProgressInDownPosition) {
//        //NSLog(@"moving up, delta:%u",deltaToMovingDownLoginPassLogoProgress);
//
////    login.frame = NSMakeRect(login.frame.origin.x, login.frame.origin.y + deltaToMovingDownLoginPassLogoProgress, login.frame.size.width, login.frame.size.height);
////        registration.frame = NSMakeRect(registration.frame.origin.x, registration.frame.origin.y + deltaToMovingDownLoginPassLogoProgress, registration.frame.size.width, registration.frame.size.height);
////        progressLogin.frame = NSMakeRect(progressLogin.frame.origin.x, progressLogin.frame.origin.y + deltaToMovingDownLoginPassLogoProgress, progressLogin.frame.size.width, progressLogin.frame.size.height);
////        namedLogo.frame = NSMakeRect(namedLogo.frame.origin.x, namedLogo.frame.origin.y + deltaToMovingDownLoginPassLogoProgress, namedLogo.frame.size.width, namedLogo.frame.size.height);
////        errorMessage.frame = NSMakeRect(errorMessage.frame.origin.x, errorMessage.frame.origin.y + deltaToMovingDownLoginPassLogoProgress, errorMessage.frame.size.width, errorMessage.frame.size.height);
////
////        if (errorMessage.frame.origin.y + errorMessage.frame.size.height < self.view.frame.size.height) self.view.frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + self.view.frame.origin.y + errorMessage.frame.origin.y - errorMessage.frame.size.height);
//        
//        NSUInteger delta = - (self.view.frame.origin.y + self.view.frame.size.height) + (loginRegistrationErrorView.frame.origin.y + loginRegistrationErrorView.frame.size.height);
//
//        
//        
//        loginRegistrationErrorView.frame = NSMakeRect(loginRegistrationErrorView.frame.origin.x, loginRegistrationErrorView.frame.origin.y + deltaToMovingDownLoginPassLogoProgress, loginRegistrationErrorView.frame.size.width, loginRegistrationErrorView.frame.size.height);
//        isLoginPassLogoProgressInDownPosition = NO;
//        if (self.view.frame.origin.y + self.view.frame.size.height < loginRegistrationErrorView.frame.origin.y + loginRegistrationErrorView.frame.size.height) { 
//            
//            self.view.frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y + delta, self.view.frame.size.width, self.view.frame.size.height - delta);
//        }
//
//    }
//
//    
//}
#pragma mark -
#pragma mark control block



- (void)companyDidChange:(NSNotification *)changeNotification
{
    //    if (isCompanyListWasSelected) {
    //        isCompanyListWasSelected = NO;
    //        company.stringValue = [company.stringValue stringByReplacingOccurrencesOfString:@" (join request)" withString:@""];
    //    }
    NSInteger tag = [changeNotification.object tag];
    if (tag == 2) {
        //NSLog(@"%@",[sender class]);
        NSString *currentCompanyName = self.company.stringValue;
        //NSLog(@"%@",currentCompanyName);
        
        NSUInteger lenghString = [currentCompanyName length];
        if (lenghString < 2) { 
            [self didCompanyListIsVisible:NO];
            //NSLog(@" menshe dvuh %@",[changeNotification class]);
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
//                NSManagedObjectContext *newMoc = [[[NSManagedObjectContext alloc] init] autorelease];
//                newMoc.persistentStoreCoordinator = delegate.persistentStoreCoordinator;
//                
//                [currentCompany setManagedObjectContext:newMoc];
//                [currentCompany setFilterPredicate:nil];
               // NSLog(@"bolshe dvuh test:%@",[currentCompany arrangedObjects]);
                NSUInteger countCompanies = 0;
                [currentCompany setFilterPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@",currentCompanyName]];
                NSArray *allCurrentCompanies = [currentCompany  arrangedObjects];
                countCompanies = [allCurrentCompanies count];
                
                
                if (countCompanies > 0) { 
                    [self didCompanyListIsVisible:YES];

                        //NSLog(@"is open companies list");
                    
                } else { 
                    [self didCompanyListIsVisible:NO];

                    //NSLog(@"is close companies list");
                }
            });
            
        } 
    }
    
}

-(BOOL)checkIfEmailAndPasswordFilledForLogin:(BOOL)isLogin
{
    NSArray *emailParts = [email.stringValue componentsSeparatedByString:@"@"];
    NSArray *secondPartEmailParts = nil;
    if ([emailParts count] > 1 ) {
        NSString *secondPartOfEmail = [emailParts objectAtIndex:1];
        if (secondPartOfEmail) secondPartEmailParts = [secondPartOfEmail componentsSeparatedByString:@"."];
    }
    BOOL isPasswordOk = YES;
    BOOL isEmailOk = YES;
    BOOL isCompanyOk = YES;
    
    if (isLogin) {
        if ([password.stringValue isEqualToString:@""]) { [self didTremorFor:password isFirstStart:YES]; isPasswordOk = NO;}
        if ([email.stringValue isEqualToString:@""] || [emailParts count] < 2  || !secondPartEmailParts || [secondPartEmailParts count] < 2 ) { [self didTremorFor:email isFirstStart:YES];  isEmailOk = NO;}
        
        if (isPasswordOk && isEmailOk) return YES;        
    } else {
        if ([company.stringValue isEqualToString:@""]) { [self didTremorFor:company isFirstStart:YES];isCompanyOk = NO; }
        if ([password.stringValue isEqualToString:@""]) { [self didTremorFor:password isFirstStart:YES]; isPasswordOk = NO;}
        if ([email.stringValue isEqualToString:@""] || [emailParts count] < 2 || !secondPartEmailParts || [secondPartEmailParts count] < 2 ) { [self didTremorFor:email isFirstStart:YES]; isEmailOk = NO;}
        
        if (isPasswordOk && isEmailOk && isCompanyOk) return YES;
    }
    
    return NO;
}

- (IBAction)loginStart:(id)sender {
//    [self performSelector:@selector(showErrorMessage:) withObject:@"test"];
    if ([self checkIfEmailAndPasswordFilledForLogin:YES]) {
        
        [progressLogin setHidden:NO];
        [progressLogin startAnimation:self];
        [login setEnabled:NO];
        [registration setEnabled:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            desctopAppDelegate *delegate = (desctopAppDelegate *)[NSApplication sharedApplication].delegate;
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
            CompanyStuff *admin = [clientController authorization];
            if (!admin) {
                [login setEnabled:YES];
                [registration setEnabled:YES];
                progressLogin.hidden = YES;
                [progressLogin stopAnimation:self];
                [self showErrorMessage:@"please wait while inital config will done"];
                [clientController release];
                return ;

            }
            //admin.email = email.stringValue;
            //admin.password = password.stringValue;
            //admin.currentCompany.name = company.stringValue;

            //[clientController finalSave:clientController.moc];
            
            [clientController processLoginForEmail:email.stringValue forPassword:password.stringValue];
            
            //NSString *returnString = [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES];
//            if ([clientController checkIfCurrentAdminCanLogin]) { 
//                admin.isRegistrationDone = [NSNumber numberWithBool:YES];
//                [clientController finalSave:clientController.moc];
//// >>>
//                //[clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES isUserAuthorized:YES];
//                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin objectID]] mustBeApproved:NO];
//            } else {
//                [login setEnabled:YES];
//                [registration setEnabled:YES];
//                progressLogin.hidden = YES;
//                [progressLogin stopAnimation:self];
//                [self showErrorMessage:@"authorization failed"];
//            }
            [clientController release];
            
        });
        
    }
}

- (IBAction)registrationStart:(id)sender {

    if ([self checkIfEmailAndPasswordFilledForLogin:NO]) {
        //if (isCompanyListVisible) { [self didTremorFor:company isFirstStart:YES]; return; }
        
        [progressLogin setHidden:NO];
        [progressLogin startAnimation:self];
        [login setEnabled:NO];
        [registration setEnabled:NO];
//        [self hideAuthorizationView];

        if (isCompanyListWasSelected) {
            // join process
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                
                desctopAppDelegate *delegate = (desctopAppDelegate *)[NSApplication sharedApplication].delegate;
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
                CompanyStuff *admin = [clientController authorization];
                if (!admin) {
                    [self showErrorMessage:@"please wait while main setup will done"];
                    [clientController release];

                    return;
                }
                admin.email = email.stringValue;
                admin.password = password.stringValue;
                //NSString *clearedCompanyName = [company.stringValue stringByReplacingOccurrencesOfString:@" (join request)" withString:@""];
                if (self.selectedCompanyID) {
                    admin.currentCompany = (CurrentCompany *)[clientController.moc objectWithID:self.selectedCompanyID];
                    [clientController finalSave:clientController.moc];
                    [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:admin.objectID] mustBeApproved:YES];
                } else [self showErrorMessage:@"selected company not found"];
                [clientController release];
            });
        } else {
            // particular registration
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                desctopAppDelegate *delegate = (desctopAppDelegate *)[NSApplication sharedApplication].delegate;
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
                CompanyStuff *admin = [clientController authorization];
                if (!admin) {
                    [self showErrorMessage:@"please wait while main setup will done"];
                    [clientController release];
                    return;
                }

                admin.email = email.stringValue;
                admin.password = password.stringValue;
                admin.currentCompany.name = company.stringValue;
                [clientController finalSave:clientController.moc];
                
                //[clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin.currentCompany objectID]] mustBeApproved:NO];
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObjects:admin.currentCompany.objectID,admin.objectID,nil] mustBeApproved:NO];
                [clientController release];
                
            });
            
        }
    }
}


#pragma mark -
#pragma mark NSTAbleView delegate block
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row;
{
    CurrentCompany *selectedCompany = [[currentCompany arrangedObjects] objectAtIndex:row];
    if (selectedCompany) {
        company.stringValue = [NSString stringWithFormat:@"%@ (join request)",selectedCompany.name];
        isCompanyListWasSelected = YES;
        selectedCompanyID = selectedCompany.objectID;
        [self didCompanyListIsVisible:NO];
        //[self loginRegistrationSpinLogoIsMovingDown:NO];

        return YES;
    } else return NO;
    
}
#pragma mark -
#pragma mark Text field delegate block

//- (BOOL)control:(NSControl *)control isValidObject:(id)object
//{
//    NSLog(@"control");
//    return YES;
//    
//}
//
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    [[errorMessage  layer] setOpacity:0.0];
    
    if (isCompanyListWasSelected) {
        self.isCompanyListWasSelected = NO;
        NSString *clearedCompanyName = [company.stringValue stringByReplacingOccurrencesOfString:@" (join request)" withString:@""];
        company.stringValue = clearedCompanyName;
        return NO;
    }
    return YES;
    
}
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    if ([self checkIfEmailAndPasswordFilledForLogin:NO]) return YES;
    return YES;
}
//
//- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
//{
//    NSLog(@"control3");
//
//    return nil;
//}
//- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
//{
//    NSLog(@"control4");
//    return YES;
//
//}



//- (void)observeValueForKeyPath:(NSString *)keyPath
//					  ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context
//{
//    NSLog( @">>>> COMPANY STUFF:Detected Change in keyPath: %@", keyPath );
//}
#pragma mark -
#pragma mark external reload methods

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    NSLog(@"FIRST AUTHORIZATION SETUP: data:%@",data);
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSManagedObjectID *objectID = nil;
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {             
        dispatch_async(dispatch_get_main_queue(), ^(void) {            
            [login setEnabled:YES];
            [registration setEnabled:YES];
            progressLogin.hidden = YES;
            [progressLogin stopAnimation:self];
            [self showErrorMessage:status];
        });
        return;
        
    }
    
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    
    if (objectID) {
        desctopAppDelegate *delegate = (desctopAppDelegate *)[NSApplication sharedApplication].delegate;
        NSManagedObject *updatedObject = [delegate.managedObjectContext objectWithID:objectID];
        
        if ([[[updatedObject entity] name] isEqualToString:@"CompanyStuff"]) {
                if (![isItLatestMessage boolValue])
                {
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                        progressLogin.hidden = NO;
                        [progressLogin startAnimation:self];
//                        [self hideAuthorizationView];
                    });

                } else {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {

                    progressLogin.hidden = YES;
                    [progressLogin stopAnimation:self];
                    [delegate.carriersView localMocMustUpdate];
                    [delegate.destinationsView localMocMustUpdate];
                    [delegate updateWellcomeTitle];
                        [self hideAuthorizationView];

//                    [delegate.companyStuffTableViewDelegate updateStatusButtons]; 
//                    [delegate.companyStuffTableViewDelegate updateWellcomeTitle]; 
//                    [delegate.companyStuffTableViewDelegate updateVerticalViewDataForObjectID:updatedObject.objectID];
                    
//                    NSUInteger index = 0;
//                    NSArray *allCompanies = [currentCompany arrangedObjects];        
//                    
//                    for (NSManagedObject *companyForCheck in allCompanies)
//                    {
//                        if ([[companyForCheck objectID] isEqual:[[updatedObject valueForKey:@"currentCompany"] objectID]]) {
//                            break;
//                        }
//                        index++;
//                    }

//                    [delegate.currentCompanyTableVew selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:YES];
//                    [delegate.currentCompanyTableVew scrollRowToVisible:index];

                    if ([status isEqualToString:@"put object finish"] && ![isError boolValue] && isCompanyListWasSelected) { 
                        [self showErrorMessage:@"you request was sent to admin"];
                        [self hideAuthorizationView];
                    } else {
                        //[self hideAuthorizationView];
                        
                    }
                    });

                    
                }
        }
        
    }
}

@end
