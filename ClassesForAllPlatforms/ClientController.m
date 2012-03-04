//
//
//  ClientController.m
//  snow
//
//  Created by Oleksii Vynogradov on 04.09.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "MainSystem.h"

#import "CompanyStuff.h"
#import "CurrentCompany.h"
#import "CompanyAccounts.h"
#import "Carrier.h"
#import "CodesList.h"
#import "CountrySpecificCodeList.h"
#import "DestinationsListPushList.h"
#import "Carrier.h"
#import "CarrierStuff.h"
#import "DestinationsListForSale.h"
#import "DestinationsListWeBuy.h"
#import "DestinationsListTargets.h"
#import "Financial.h"
#import "InvoicesAndPayments.h"
#import "CodesvsDestinationsList.h"
#import "DestinationPerHourStat.h"
#import "DestinationsListWeBuyTesting.h"
#import "DestinationsListWeBuyResults.h"

#import "OperationNecessaryToApprove.h"
#import "Events.h"
#import "ClientController.h"
#import "JSONKit.h"
#import "ParseCSV.h"

static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end


@implementation ClientController

@synthesize moc,mainServer,sender,downloadSize,mainMoc;

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator withSender:(id)senderForThisClass withMainMoc:(NSManagedObjectContext *)itMainMoc;
{
    self = [super init];
    if (self) {
        // Initialization code here.
        mainMoc = itMainMoc;
        //receivedData = [[NSMutableData alloc] init];

        sender = senderForThisClass;
 
#if defined(SNOW_SERVER)

        mainServer = [[NSURL alloc] initWithString:@"https://mac.ixcglobal.com:8081"];
#else
        mainServer = [[NSURL alloc] initWithString:@"http://127.0.0.1:8081"];
//        mainServer = [[NSURL alloc] initWithString:@"http://192.168.0.58:8081"];
#endif
        
//
        
//        mainServer = [[NSURL alloc] initWithString:@"http://127.0.0.1:8081"];
//        mainServer = [[NSURL alloc] initWithString:@"http://91.224.223.42:8081"];
//        mainServer = [[NSURL alloc] initWithString:@"https://192.168.0.58:8081"];
//        mainServer = [[NSURL alloc] initWithString:@"https://193.108.122.154:8081"];

        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
//        [moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

        //[moc setMergePolicy:NSRollbackMergePolicy];
        [moc setPersistentStoreCoordinator:coordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];
//        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
//        [[NSURLCache sharedURLCache] setDiskCapacity:0];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.moc];
//    [mainMoc release];
    [moc release];
    [mainServer release];
    //[receivedData release];
    [super dealloc];
}
#pragma mark -
#pragma mark core multithread methods

- (void)importerDidSave:(NSNotification *)saveNotification {
//    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:saveNotification waitUntilDone:NO];

//    //NSLog(@"MERGE in client controller");
//    if ([NSThread isMainThread]) {
//        [mainMoc mergeChangesFromContextDidSaveNotification:saveNotification];
//////        [self performSelectorOnMainThread:@selector(finalSave:) withObject:self.moc waitUntilDone:YES];
////        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
////
//    } else {
//        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
//    }
////    dispatch_async(dispatch_get_main_queue(), ^(void) { 
////        [self.mainMoc mergeChangesFromContextDidSaveNotification:saveNotification];
////        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
//    });
    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                                                    withObject:saveNotification
                                                 waitUntilDone:YES];

}

- (void)logError:(NSError*)error;
{
    id sub = [[error userInfo] valueForKey:@"NSUnderlyingException"];
    
    if (!sub) {
        sub = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
    }
    
    if (!sub) {
        NSLog(@"%@:%@ Error Received: %@", [self class], NSStringFromSelector(_cmd), 
              [error localizedDescription]);
        return;
    }
    
    if ([sub isKindOfClass:[NSArray class]] || 
        [sub isKindOfClass:[NSSet class]]) {
        for (NSError *subError in sub) {
            NSLog(@"%@:%@ SubError: %@", [self class], NSStringFromSelector(_cmd), 
                  [subError localizedDescription]);
        }
    } else {
        NSLog(@"%@:%@ exception %@", [self class], NSStringFromSelector(_cmd), [sub description]);
    }
}

-(void) finalSave:(NSManagedObjectContext *)mocForSave; 
{
    
    if ([mocForSave hasChanges]) {
        NSError *error = nil;
        if (![mocForSave save: &error]) {
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0)
            {
                for(NSError* detailedError in detailedErrors)
                {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else
            {
                NSLog(@"  %@", [error userInfo]);
            }
            [self logError:error];
        }
    }
    
    return;
    
}



#pragma mark -
#pragma mark methods for all

- (id)dataWithBase64EncodedString:(NSString *)string;
{
    if (string == nil) return nil; //[NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64EncodingData:(NSData *)data;
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';    
    }
    
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}



-(NSDictionary *) clearNullKeysForDictionary:(NSDictionary *)dictionary
{
    __block NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //NSLog(@"clearance was start:%@",obj);
        
        if ([[obj class] isSubclassOfClass:[NSNull class]]) [result removeObjectForKey:key];
        if ([[obj class] isSubclassOfClass:[NSDate class]]) { 
            [result setValue:[obj description] forKey:key];
            //NSLog(@"date was converted:%@",obj);
        }
        if ([[obj class] isSubclassOfClass:[NSData class]]) { 
            NSString *stringToPass = [[NSString alloc] initWithData:obj encoding:NSASCIIStringEncoding];
            [result setValue:stringToPass forKey:key];
            [stringToPass release];
            //NSLog(@"data was converted:%@",obj);
        }

    }];
    return [NSDictionary dictionaryWithDictionary:result];
    
}

-(NSDictionary *) dictionaryFromObject:(NSManagedObject *)object
{
    NSArray *keys = [[[object entity] attributesByName] allKeys];
    NSDictionary *dict = [object dictionaryWithValuesForKeys:keys];
    return [self clearNullKeysForDictionary:dict];
}



-(void) updateUIwithMessage:(NSString *)message withObjectID:(NSManagedObjectID *)objectID withLatestMessage:(BOOL)isItLatestMessage error:(BOOL)isError;
{
    //NSLog(@"CLIENT CONTROLLER: this is UI message:%@",message);
    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObjects:message,[NSNumber numberWithInt:0],[NSNumber numberWithBool:isItLatestMessage],[NSNumber numberWithBool:isError],objectID,nil]];
    }

}

-(void) updateUIwithMessage:(NSString *)message andProgressPercent:(NSNumber *)percent withObjectID:(NSManagedObjectID *)objectID;
{
    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObjects:message,percent,[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],objectID,nil]];
    }

}

-(void) setValuesFromDictionary:(NSDictionary *)values anObject:(NSManagedObject *)object
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];


    NSEntityDescription *entity = [object entity];
    NSDictionary *attributes = [entity attributesByName];
    
    NSArray *allKeys = [values allKeys];
    for (NSString *key in allKeys) {
        
        id obj = [values objectForKey:key];
        
        NSAttributeDescription *attribute = [attributes valueForKey:key];
        NSString *className = [attribute attributeValueClassName];
        //NSLog(@"class name::%@",className);
        if ([className isEqualToString:@"NSDate"]){
            //NSLog(@"dateUpdate");
            NSDate *dateToPass = [formatter dateFromString:obj];
            [object setValue:dateToPass forKey:key];
            continue;
        } 
        
        if ([className isEqualToString:@"NSData"]){
            NSData *dataToPass = [obj dataUsingEncoding:NSASCIIStringEncoding];
            [object setValue:dataToPass forKey:key];
            //[dataToPass release];
            continue;
        } 
        
        [object setValue:obj forKey:key];
    }
    [formatter release];
    //return object;
}


-(void) setUserDefaultsObject:(id)object forKey:(NSString *)key;
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id) userDefaultsObjectForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
-(NSString *)localStatusForObjectsWithRootGuid:(NSString *)rootObjectGUID;
{
    //NSString *objectGUID = [objects valueForKey:@"rootObjectGUID"];
    NSDictionary *objectStatus =[self userDefaultsObjectForKey:rootObjectGUID];
    NSString *status = nil;
    if (objectStatus) { 
        if ([objectStatus valueForKey:@"update"]) status = [objectStatus valueForKey:@"update"];
        if ([objectStatus valueForKey:@"new"]) status =  [objectStatus valueForKey:@"new"]; 
        if ([objectStatus valueForKey:@"login"]) status =  [objectStatus valueForKey:@"login"]; 
        
    }
    return status;
}


-(void) createCountrySpecificCodesInCoreDataForMainSystem:(MainSystem *)mainSystem;
{
    // CREATE COUNTRY SPECIFIC CODES IN CORE DATA
//    if (sender && [sender respondsToSelector:@selector(setOperationName:)]) [sender performSelector:@selector(setOperationName:) withObject:@"Update destinations internal data"];
//    if (sender && [sender respondsToSelector:@selector(updateProgessInfoWithPercent:)]) [sender performSelector:@selector(updateProgessInfoWithPercent:) withObject:[NSNumber numberWithDouble:0]];
    [self updateUIwithMessage:@"Update destinations internal data" andProgressPercent:[NSNumber numberWithDouble:0] withObjectID:nil];
    //NSLog(@"CLIENT CONTROLLER: createCountrySpecificCodesInCoreDataForMainSystem start");

    NSError *error = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:nil];
    NSUInteger count = [self.moc countForFetchRequest:fetchRequest error:&error];
    
    if (count == 0) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"codeList" ofType:@"txt" ];
        NSAssert(path != nil, @"Unable to find codeList.txt in main bundle"); 
        ParseCSV *parser = [[ParseCSV alloc] init];
        [parser openFile:path];
        NSMutableArray *codesFromFile = [parser parseFile];
        [parser release], parser = nil;
        path = nil;
        NSMutableArray *countrySpecificCodesList = [NSMutableArray array];
        NSUInteger countForCodes = codesFromFile.count;
        
        
        
        [codesFromFile enumerateObjectsWithOptions:NSSortStable usingBlock:^(id code, NSUInteger idx, BOOL *stop) {
            NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:countForCodes] doubleValue]];
            [self updateUIwithMessage:@"Parse codes list.." andProgressPercent:percentDone withObjectID:nil];

            NSMutableDictionary *codesFromFileListNew = [NSMutableDictionary dictionary];
            [codesFromFileListNew setValue:[code objectAtIndex:0] forKey:@"country"];
            [codesFromFileListNew setValue:[code objectAtIndex:1] forKey:@"specific"];
            NSMutableArray *filteredResult = [NSMutableArray arrayWithArray:countrySpecificCodesList];
            [filteredResult filterUsingPredicate:[NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",[code objectAtIndex:0],[code objectAtIndex:1]]];
            if ([filteredResult count] != 0)
            {
                // NSLog (@"We find a simular country: %@ specific %@ and code %@ Total destinations:%ld",[code objectAtIndex:0],[code objectAtIndex:1], [code objectAtIndex:2], [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList count]);
                NSMutableDictionary *lastObject = [[NSArray arrayWithArray:countrySpecificCodesList] lastObject];
                NSMutableArray *codes = [lastObject valueForKey:@"code"];
                [codes addObject:[code objectAtIndex:2]];
                [lastObject setValue:codes forKey:@"code"];
                [countrySpecificCodesList removeLastObject];
                [countrySpecificCodesList addObject:lastObject];
                lastObject = nil;
                codes = nil;
            } else {
                NSMutableDictionary *codesFromFileList = [NSMutableDictionary dictionary];
                NSString *countryBefore = [code objectAtIndex:0];
                NSString *specificBefore = [code objectAtIndex:1];
                NSString *country = [countryBefore stringByReplacingOccurrencesOfString:@"'" withString:@"~"];
                NSString *specific = [specificBefore stringByReplacingOccurrencesOfString:@"'" withString:@"~"];
                
                [codesFromFileList setValue:country forKey:@"country"];
                [codesFromFileList setValue:specific forKey:@"specific"];
                [codesFromFileList setValue:[NSMutableArray arrayWithObject:[code objectAtIndex:2]] forKey:@"code"];
                [countrySpecificCodesList addObject:codesFromFileList];
            }
        }];
        

        NSManagedObjectID *mainSystemID = [mainSystem objectID];
        
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"myCountrySpecificCodeList" ofType:@"ary" ];
        
        //NSAssert(path != nil, @"Unable to find myCountrySpecificCodeList.ary in main bundle"); 
        
        //NSArray *countrySpecificCodesList = [[NSArray alloc] initWithContentsOfFile:path];
        
        if (countrySpecificCodesList.count == 0) {
            NSLog(@"CLIENT CONTROLLER: warning, countrySpecificCodesList is empty");
        }
        //NSLog(@"%@",countrySpecificCodesList);
        //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSUInteger idx = 0;
        for (NSDictionary *countrySpecific in countrySpecificCodesList) {
            NSNumber *percentDone = [NSNumber numberWithDouble:([[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:[countrySpecificCodesList count]] doubleValue])];
//            if (sender && [sender respondsToSelector:@selector(updateProgessInfoWithPercent:)]) [sender performSelector:@selector(updateProgessInfoWithPercent:) withObject:percentDone];
            [self updateUIwithMessage:@"Update codes database..." andProgressPercent:percentDone withObjectID:nil];
            
            CountrySpecificCodeList *newTest = (CountrySpecificCodeList *)[NSEntityDescription insertNewObjectForEntityForName:@"CountrySpecificCodeList" inManagedObjectContext:self.moc]; 
            newTest.country = [countrySpecific valueForKey:@"country"];
            newTest.specific = [countrySpecific valueForKey:@"specific"];
            //NSLog(@"CLIENT CONTROLLER: createCountrySpecificCodesInCoreDataForMainSystem start for %@ specific:%@",newTest.country,newTest.specific);

            newTest.mainSystem = (MainSystem *)[self.moc objectWithID:mainSystemID];
            NSMutableString *codes = [NSMutableString string];
            NSArray *codesListLocal = [countrySpecific valueForKey:@"code"];
            NSUInteger idxCodes = 0;
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            
            for (NSString *codeString in codesListLocal) {
                CodesList *newList = (CodesList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesList" inManagedObjectContext:self.moc]; 
                NSNumber *codeNumber = [formatter numberFromString:codeString];
                newList.code = codeNumber;
                newList.countrySpecificCodesList = newTest;
                
                if (idxCodes != [codesListLocal count] - 1) [codes appendFormat:@"%@, ",codeString];
                else [codes appendFormat:@"%@",codeString];
                idxCodes++;
            }
            [formatter release],formatter = nil;
            
            newTest.codes = [NSString stringWithString:codes];
            //NSLog(@"New Object = %@/%@",newTest.country,newTest.specific);
            //[pool drain],pool = nil;
            //pool = [[NSAutoreleasePool alloc] init];
            idx++;
        }
        //[pool drain],pool = nil;
        [countrySpecificCodesList release];
    }
    [fetchRequest release];
    
}

- (CompanyStuff *)authorization;
{
    NSString *keyAofAuthorized = @"authorizedUserGUID";
    
#if defined(SNOW_CLIENT_APPSTORE)
    keyAofAuthorized = @"authorizedUserGUIDclient";
#endif
    NSString *authorizedUserGUID = [self userDefaultsObjectForKey:keyAofAuthorized];
    

    //NSString *password = [self userDefaultsObjectForKey:@"password"];
    
    //NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    //NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",authorizedUserGUID];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSArray *result = [self.moc executeFetchRequest:fetchRequest error:&error];
    CompanyStuff *stuff = [result lastObject];
    [fetchRequest release];
    return stuff;
}


-(MainSystem *)getMainSystem;
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainSystem" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    NSArray *result = [self.moc executeFetchRequest:fetchRequest error:&error];
    MainSystem *mainSystem = [result lastObject];
    [fetchRequest release];
    return mainSystem;
}


- (MainSystem *) firstSetup;
{
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSArray *result = nil;
    __block NSEntityDescription *entity = nil;
    
    //CHECK IF MAIN SYSTEM IS PRESENT (means that all setup issues is done)
    entity = [NSEntityDescription entityForName:@"MainSystem" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    result = [self.moc executeFetchRequest:fetchRequest error:&error];
    
    MainSystem *mainSystem = nil;
    if ([result count] == 0) {
        mainSystem = (MainSystem *)[NSEntityDescription insertNewObjectForEntityForName:@"MainSystem" inManagedObjectContext:self.moc];
        [self setUserDefaultsObject:mainSystem.GUID forKey:@"mainSystemGUID"];
        [self.moc save:&error];
        if (error) NSLog(@"%@",[error localizedDescription]);
        
    } else { 
        mainSystem = [result lastObject];
        //[fetchRequest release];
        //[self createCountrySpecificCodesInCoreDataForSender:sender andMainSystem:mainSystem];
        
    }
    
    //NSAssert(mainSystem != nil,@"main system don't found");
    
    // CREATE STUFF,COMPANY AND CARRIER
    //NSString *authorizedStuffGUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"authorizedUserGUID"];

    CompanyStuff *authorizedUser = [self authorization];
    
    if (authorizedUser) {
        [fetchRequest release];
        return mainSystem;
    }
//#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE) || defined (SNOW_SERVER) || defined (SNOW_MOBILE)
    __block NSPredicate *predicate = nil;

//#if defined (SNOW_SERVER)
    predicate = [NSPredicate predicateWithFormat:@"(email == %@) AND (password == %@)",@"you@email",@"you password"];

//#else
//    predicate = [NSPredicate predicateWithFormat:@"(email == %@) AND (password == %@)",@"8D9F-415C-82EE@21780-0003B13E42CF2A8F",@"259F69DB34D4"];
//#endif
    entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    result = [self.moc executeFetchRequest:fetchRequest error:&error];
    if ([result count] > 1) NSLog(@"WARNING  more than 2 stuff");
    
    CompanyStuff *stuff = nil;
    CurrentCompany *company = nil;
    
    if ([result count] == 0) { 
        
        // don't find a company stuff, try to find company
//#if defined (SNOW_SERVER)
//        predicate = [NSPredicate predicateWithFormat:@"(name == %@)",@"E1FA4F2D"];
//
//#else
        predicate = [NSPredicate predicateWithFormat:@"(name == %@)",@"you company"];

//#endif

        entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        result = [self.moc executeFetchRequest:fetchRequest error:&error];
        if ([result count] > 1) NSLog(@"WARNING  more than 2 you company");
        
        if ([result count] == 0) { 
            // conmpany don't found
            company = (CurrentCompany *)[NSEntityDescription 
                                         insertNewObjectForEntityForName:@"CurrentCompany" 
                                         inManagedObjectContext:self.moc];
//#if defined (SNOW_SERVER)
//
//            company.name = @"E1FA4F2D";
//            company.isVisibleForCommunity = [NSNumber numberWithBool:NO];
//#else
            company.name = @"you company";

//#endif

        } else company = [result lastObject];
        
        @synchronized(self) {
            stuff = (CompanyStuff *)[NSEntityDescription 
                                     insertNewObjectForEntityForName:@"CompanyStuff" 
                                     inManagedObjectContext:self.moc];
//#if defined (SNOW_SERVER)
//            stuff.firstName = @"you first name";
//            stuff.lastName = @"you last name";
//            stuff.email = @"8D9F-415C-82EE@21780-0003B13E42CF2A8F";
//            stuff.password = @"259F69DB34D4";
//
//#else

            stuff.firstName = @"you first name";
            stuff.lastName = @"you last name";
            stuff.email = @"you@email";
            stuff.password = @"you password";
//#endif
    
            NSString *keyAofAuthorized = @"authorizedUserGUID";
            
#if defined(SNOW_CLIENT_APPSTORE)
            keyAofAuthorized = @"authorizedUserGUIDclient";
#endif
            
            [self setUserDefaultsObject:stuff.GUID forKey:keyAofAuthorized];
            company.companyAdminGUID = stuff.GUID;
            stuff.currentCompany = company;
        }
    } else 
    {
        stuff = [result lastObject];
        company = stuff.currentCompany;
    }
    
    NSAssert(stuff != nil,@"stuff don't found");
    NSAssert(company != nil,@"company don't found");

    
    predicate = [NSPredicate predicateWithFormat:@"(name == %@)",@"you first carrier"];
    entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectIDResultType];
    [fetchRequest setPredicate:predicate];
    result = [self.moc executeFetchRequest:fetchRequest error:&error];
    
    Carrier *carrier = nil;
    if ([result count] == 0) { 
        carrier = (Carrier *)[NSEntityDescription 
                              insertNewObjectForEntityForName:@"Carrier" 
                              inManagedObjectContext:self.moc];
        carrier.name = @"you first carrier";
        carrier.companyStuff = stuff;
    } else carrier = [result lastObject];
    
    NSAssert(carrier != nil,@"company don't found");
    
    [fetchRequest release], fetchRequest = nil;
    [self finalSave:self.moc];

    [self createCountrySpecificCodesInCoreDataForMainSystem:mainSystem];

    [self finalSave:self.moc];
//#endif
    
    return mainSystem;
}

#pragma mark -
#pragma mark NSURLConnection methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    downloadSize = [[NSNumber alloc] initWithLongLong:[response expectedContentLength]];
    //NSLog(@"didReceiveResponse:%@ bytes of data",downloadSize);

//    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
//        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObject:@"web download is started"]];
//    }
    [self updateUIwithMessage:@"server download is started" withObjectID:nil withLatestMessage:NO error:NO];

    [receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:[receivedData length]] doubleValue] / [self.downloadSize doubleValue]];
//    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
//        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObjects:@"web download progress",percentDone,nil]];
//    }
    //NSLog(@"Processing! Received %@ percent bytes of data",percentDone);

    [self updateUIwithMessage:@"server download progress" andProgressPercent:percentDone withObjectID:nil];

    [receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
//    [receivedData release];
    downloadCompleted = YES;
//    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
//        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObject:[NSString stringWithFormat:@"web download failed with error:%@",[error localizedDescription]]]];
//    }
    [self updateUIwithMessage:[NSString stringWithFormat:@"download error:%@",[error localizedDescription]] withObjectID:nil withLatestMessage:NO error:YES];
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"Succeeded! Received %@ bytes of data",[NSNumber numberWithUnsignedInteger:[receivedData length]]);
    // release the connection, and the data object
    downloadCompleted = YES;
//    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
//        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObject:@"web download is started"]];
//    }
    [self updateUIwithMessage:@"server download is finished" withObjectID:nil withLatestMessage:NO error:NO];
    [connection release];
//    [receivedData release];
}
// credential area
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    //NSLog(@"can auth");
    //BOOL result = [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    //NSLog(@"auth:%@",result ? @"YES" : @"NO");
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    //NSLog(@"challenge");
    //    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    NSString *user = [NSString stringWithFormat:@"%c%s%@", 'a', "le", @"x"];
    NSString *password = [NSString stringWithFormat:@"%c%s%c%@", 'A', "87AE19C-FEBB", '-', @"4C4C-A534-3CD036ED072A"];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:user
                                                             password:password
                                                          persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    
    
    //    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    
}



-(NSDictionary *) getJSONAnswerForFunction:(NSString *)function withJSONRequest:(NSMutableDictionary *)request;
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainSystem" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    NSArray *result = [self.moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    MainSystem *mainSystem = [result lastObject];
    if (!mainSystem) [self updateUIwithMessage:@"main system not found" withObjectID:nil withLatestMessage:NO error:YES];
    [request setValue:mainSystem.GUID forKey:@"mainSystemGUID"];
    [request setValue:@"hash" forKey:@"hash"];
    downloadCompleted = NO;
//    receivedData = [[NSMutableData alloc] init];
    receivedData = [[NSMutableData data] retain]; 
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
//        NSError *error = nil;
        NSError *error = nil;

        NSString *jsonStringForReturn = [request JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
        if (error) NSLog(@"CLIENT CONTROLLER: json decoding error:%@ in function:%@",[error localizedDescription],function);
        //NSLog(@"CLIENT CONTROLLER: SEND:%@",jsonStringForReturn);

        NSData *bodyData = [jsonStringForReturn dataUsingEncoding:NSUTF8StringEncoding];
        NSData *dataForBody = [[[NSData alloc] initWithData:bodyData] autorelease];
        //NSLog(@"CLIENT CONTROLLER: string lenght is:%@ bytes",[NSNumber numberWithUnsignedInteger:[dataForBody length]]);
        
        NSString *functionString = [NSString stringWithFormat:@"/%@",function];
        
        NSURL *urlForRequest = [NSURL URLWithString:functionString relativeToURL:mainServer];
        
        NSMutableURLRequest *requestToServer = [NSMutableURLRequest requestWithURL:urlForRequest];
        
        [requestToServer setHTTPMethod:@"POST"];
        
        [requestToServer setHTTPBody:dataForBody];
        
        
        //NSLog(@"Is%@ main thread", ([NSThread isMainThread] ? @"" : @" NOT"));
        //        NSString *user = [NSString stringWithFormat:@"%c%s%@", 'a', "le", @"x"];
        //        NSString *password = [NSString stringWithFormat:@"%c%s%@", 'M', "anu", @"al"];
        //        
        //        NSURLCredential *credential = [NSURLCredential credentialWithUser:user
        //                                                                 password:password
        //                                                              persistence:NSURLCredentialPersistenceForSession];
        ////        NSString *host = [NSString stringWithFormat:@"%c%s%@%c%c%s%@", 's', "now.", @"ix", 'c', '.', "u", @"a"];
        //        NSString *host = [NSString stringWithFormat:@"127.0.0.1"];
        //
        //        NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc]
        //                                                 initWithHost:host
        //                                                 port:8081
        //                                                 protocol:@"https"
        //                                                 realm:nil
        //                                                 authenticationMethod:nil];
        //        
        //        
        //        [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential
        //                                                            forProtectionSpace:protectionSpace];
        //        [protectionSpace release];
//     dispatch_async(dispatch_get_main_queue(), ^(void) { 
//        receivedData = [[NSMutableData alloc] init];

        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestToServer delegate:self startImmediately:YES];
        if (!connection) NSLog(@"failedToCreate");
    });
//    });
    
    while (!downloadCompleted) { 
        
        sleep(1); 
        //NSLog(@"waiting for completed"); 
    }
    NSData *receivedResult = [[NSData alloc] initWithData:receivedData];
    [receivedData release];

    NSString *answer = [[NSString alloc] initWithData:receivedResult encoding:NSUTF8StringEncoding];
    //NSLog(@"CLIENT CONTROLLER: ANSWER:%@",answer);
    
    //[receivedData release];
    JSONDecoder *jkitDecoder = [JSONDecoder decoder];

    NSDictionary *finalResult = [jkitDecoder objectWithUTF8String:(const unsigned char *)[answer UTF8String] length:[answer length] error:&error];
    [receivedData setData:[NSData data]];
    //NSLog(@"finalResult:%@",finalResult);

    if (error) { 
        NSLog(@"CLIENT CONTROLLER: failed to decode answer with error:%@",[error localizedDescription]);
        return nil;
    }
    return finalResult;
}
#pragma mark -
#pragma mark Login methods
-(BOOL)checkIfCurrentAdminCanLogin;
{
    CompanyStuff *admin = [self authorization];
    
    NSMutableDictionary *prepeareForJSONRequest = [[NSMutableDictionary alloc] init];
    [prepeareForJSONRequest setValue:admin.email forKey:@"authorizedUserEmail"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"authorizedUserPassword"];

    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"LoginUser" withJSONRequest:prepeareForJSONRequest];
    [prepeareForJSONRequest release];

    NSString *result = [receivedObject valueForKey:@"result"];
    if ([result isEqualToString:@"done"]) return YES;
    else return NO;
    
}

#pragma mark -
#pragma mark GetCompaniesList methods

-(void)getCompaniesListWithImmediatelyStart:(BOOL)isImmediatelyStart;
{
    //    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
    //        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObject:@"get companies start"]];
    //    }
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastGraphUpdatingTime"];
    if (lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] > 360 || isImmediatelyStart) {
        
        CompanyStuff *currentAdmin = [self authorization];
        
        NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
        
        [self updateUIwithMessage:@"get companies started" withObjectID:nil withLatestMessage:NO error:NO];
        
        NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"GetCompaniesList" withJSONRequest:prepeareForJSONRequest];
        
        NSLog(@"CLIENT CONTROLLER: get companies received:%@",receivedObject);
        
        [self updateUIwithMessage:@"get companies processing" withObjectID:nil withLatestMessage:NO error:NO];
        
        NSArray *companiesList = [receivedObject valueForKey:@"companiesList"];

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        __block NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        __block NSError *error = nil;
        __block NSMutableArray *allLocalCompanies = [NSMutableArray arrayWithArray:[self.moc executeFetchRequest:fetchRequest error:&error]];

        
        [companiesList enumerateObjectsUsingBlock:^(NSDictionary *companyInfo, NSUInteger idx, BOOL *stop) {
            NSString *objectGUID = [companyInfo valueForKey:@"GUID"];
            NSDictionary *companyAdmin = [companyInfo valueForKey:@"companyStuff"];
            NSString *adminGUID = [companyAdmin valueForKey:@"GUID"];
            NSMutableDictionary *clearCompanyInfo = [NSMutableDictionary dictionaryWithDictionary:companyInfo];
            [clearCompanyInfo removeObjectForKey:@"companyStuff"];
            
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc];
//            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
//            [fetchRequest setPredicate:predicate];
//            NSError *error = nil;
//            NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
            NSArray *fetchedObjects = [allLocalCompanies filteredArrayUsingPredicate:predicate];
            if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
            CurrentCompany *companyForChanges = nil;
        
            
            if ([fetchedObjects count] == 0) {
                // only if we create company, this mean's that this company from external server, not local
                companyForChanges = (CurrentCompany *)[NSEntityDescription 
                                                       insertNewObjectForEntityForName:@"CurrentCompany" 
                                                       inManagedObjectContext:self.moc];
                [self setValuesFromDictionary:clearCompanyInfo anObject:companyForChanges];
                
                NSMutableDictionary *clientInfo = [NSMutableDictionary dictionaryWithCapacity:0];
                [clientInfo setValue:@"external server" forKey:@"update"];
                [[NSUserDefaults standardUserDefaults] setObject:clientInfo forKey:companyForChanges.GUID];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            };
            if ([fetchedObjects count] == 1) { 
                companyForChanges = [fetchedObjects lastObject];
                [self setValuesFromDictionary:clearCompanyInfo anObject:companyForChanges];
                [allLocalCompanies removeObject:companyForChanges];
            };
            if (![companyForChanges.GUID isEqualToString:currentAdmin.currentCompany.GUID]) {
                // all company list updates need only if company not current
                
                CompanyStuff *admin = nil;
                entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc];
                [fetchRequest setEntity:entity];
                predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",adminGUID];
                [fetchRequest setPredicate:predicate];
                fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
                if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
                
                if ([fetchedObjects count] == 0 && adminGUID) { 
                    admin = (CompanyStuff *)[NSEntityDescription 
                                             insertNewObjectForEntityForName:@"CompanyStuff" 
                                             inManagedObjectContext:self.moc];
                    
                };
                
                if ([fetchedObjects count] == 1) { 
                    admin = [fetchedObjects lastObject];
                };
                // don't update password to nil for current admin
                if (admin && admin != currentAdmin) { 
                    admin.currentCompany = companyForChanges;
                    [self setValuesFromDictionary:companyAdmin anObject:admin];
                    //NSLog(@"CLIENT CONTROLLER: admin with email:%@ was updated",admin.email);
                    
                }
                
                
                // final updates for both objects
                
                //NSLog(@"status for company:%@",[[NSUserDefaults standardUserDefaults] objectForKey:companyForChanges.GUID]);
            } else NSLog(@"Don't do updates for company:%@ and guid:%@",companyForChanges.name,companyForChanges.GUID);
            //NSLog(@"finalUpdateForCompany:%@ withAdmin:%@",companyForChanges,admin);
            //[fetchRequest release];
        }];
        
        NSMutableArray *idsForRemove = [NSMutableArray array];
        
        [allLocalCompanies enumerateObjectsUsingBlock:^(CurrentCompany *companyForRemoving, NSUInteger idx, BOOL *stop) {
            if (companyForRemoving.objectID != currentAdmin.currentCompany.objectID) { 
                [idsForRemove addObject:companyForRemoving.objectID];
                NSLog(@"CLIENT CONTROLLER: company %@ is not on server and will removing",companyForRemoving.name);
            }
        }];
        
        [idsForRemove enumerateObjectsUsingBlock:^(NSManagedObjectID *idForRemove, NSUInteger idx, BOOL *stop) {
            [self.moc deleteObject:[self.moc objectWithID:idForRemove]];
        }];
        
        
        [self finalSave:self.moc];
        [self updateUIwithMessage:@"get companies finish" withObjectID:nil withLatestMessage:YES error:YES];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastGraphUpdatingTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}
#pragma mark -
#pragma mark GetObjects methods
-(void) makeUpdatesForEvents:(NSArray *)eventsExternal;
{
    __block MainSystem *mainSystem = [self getMainSystem];
    NSUInteger idx = 0;
    for (NSDictionary *eventData in eventsExternal) {
//    [eventsExternal enumerateObjectsUsingBlock:^(NSDictionary *eventData, NSUInteger idx, BOOL *stop) {
        NSNumber *percent = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:[eventsExternal count]]doubleValue]];
        [sender performSelector:@selector(setPercentDone:) withObject:percent];
        [sender performSelector:@selector(updateProgessInfoWithPercent:) withObject:percent];

        NSString *eventGUID = [eventData valueForKey:@"GUID"];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",eventGUID];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        
        [fetchRequest release];
        Events *findedEvent = [fetchedObjects lastObject];
        if (!findedEvent) { 
            //NSLog(@"CLIENT CONTROLLER: warning, event not found for data:%@",eventData);
            findedEvent = (Events *)[NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:self.moc];
            findedEvent.mainSystem = mainSystem;
        }
        [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedEvent.GUID];
        
        [self setValuesFromDictionary:eventData anObject:findedEvent];
        idx++;
        
    };
    
//    NSSet *allEvents = mainSystem.events;
//    [allEvents enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
//        NSLog(@"Object:%@",obj);
//    }];
    
//    NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
//    NSAutoreleasePool *poolForEvents = [[NSAutoreleasePool alloc] init];
//
//    for (id event in eventsExternal) {
//        //[eventsExternal enumerateObjectsWithOptions:NSSortConcurrent usingBlock:^(id event, NSUInteger idx, BOOL *stop) {
//        NSNumber *percent = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:[eventsExternal count]]doubleValue]];
//        [sender performSelector:@selector(setPercentDone:) withObject:percent];
//        [sender performSelector:@selector(updateProgessInfoWithPercent:) withObject:percent];
//
//        
//        //NSString *date = [event valueForKey:@"date"];
//        NSString *dateAlarm = [event valueForKey:@"dateAlarm"];
//        NSString *name = [event valueForKey:@"name"];
//        NSString *necessaryData = [event valueForKey:@"necessaryData"];
//        NSString *countryName = [name stringByReplacingOccurrencesOfString:@"countriesEvent_" withString:@""];
//        
//        NSDate *dateNew = [formatterDate dateFromString:dateAlarm];
//        
//        NSDate *dateAlarmNew = [[NSDate alloc] initWithTimeInterval:-475200 sinceDate:dateNew];
//        
//        dateAlarm = nil;
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date == %@) AND (name == %@) AND (necessaryData == %@)",dateNew,countryName,necessaryData];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:self.moc];
//        NSFetchRequest *fetchRequestForEvents = [[NSFetchRequest alloc] init];
//        [fetchRequestForEvents setEntity:entity];
//        [fetchRequestForEvents setResultType:NSManagedObjectIDResultType];
//        [fetchRequestForEvents setPredicate:predicate];
//        NSUInteger eventsResult = [self.moc countForFetchRequest:fetchRequestForEvents error:nil];
//        if (eventsResult == 0) { 
//            Events *newEvent = (Events *)[NSEntityDescription 
//                                          insertNewObjectForEntityForName:@"Events" 
//                                          inManagedObjectContext:self.moc];
//            newEvent.name = countryName;
//            newEvent.date = dateNew;
//            newEvent.dateAlarm = dateAlarmNew;
//            newEvent.necessaryData = necessaryData;
//            //NSLog(@"%@/%@",[mainSystem class],newEvent);
//            newEvent.mainSystem = mainSystem;
//            
//        }
//        [fetchRequestForEvents release];
//        
//        [dateNew release];
//        [dateAlarmNew release];
//        [poolForEvents drain],poolForEvents = nil;
//        //pool = [[NSAutoreleasePool alloc] init];
//        poolForEvents = [[NSAutoreleasePool alloc] init];
//        idx++;
//        //}];
//    }
//    [formatterDate release];
//    [eventsExternal release];
//    [poolForEvents drain],poolForEvents = nil;

    //[self setValuesFromDictionary:destinationData anObject:findedDestination];
//    sleep(2);
//    [self finalSave:moc];
    
}
-(void) makeUpdatesForCodesvsDestinationsList:(NSDictionary *)codeData withDestination:(NSManagedObject *)destination;
{
    NSString *destinationGUID = [codeData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CodesvsDestinationsList" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    CodesvsDestinationsList *findedCode = [fetchedObjects lastObject];
    if (!findedCode) { 
        NSLog(@"CLIENT CONTROLLER: warning, code not found and will created");
        findedCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:moc];
        //        findedDestination.carrier = carrier;
    }
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedCode.GUID];
    
    [self setValuesFromDictionary:codeData anObject:findedCode];
    
    //    sleep(2);
    //    [self finalSave:moc];
    
}


-(void) makeUpdatesForInvoiceAndPayments:(NSDictionary *)invoiceAndPaymentData withFinancial:(Financial *)financial;
{
    NSString *destinationGUID = [invoiceAndPaymentData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoicesAndPayments" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    InvoicesAndPayments *findedInvoiceAndPayment = [fetchedObjects lastObject];
    if (!findedInvoiceAndPayment) { 
        NSLog(@"CLIENT CONTROLLER: warning, findedInvoiceAndPayment not found and will created");
        findedInvoiceAndPayment = (InvoicesAndPayments *)[NSEntityDescription insertNewObjectForEntityForName:@"InvoicesAndPayments" inManagedObjectContext:moc];
        findedInvoiceAndPayment.financial = financial;
    }
    NSMutableDictionary *invoiceAndPaymentDataClean = [NSMutableDictionary dictionaryWithDictionary:invoiceAndPaymentData];

    entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSArray *companyStuffs = [invoiceAndPaymentData valueForKey:@"companyStuff"];
    NSDictionary *companyStuff = companyStuffs.lastObject;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",[companyStuff valueForKey:@"GUID"]];
    [fetchRequest setPredicate:predicate];
    
    fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));

    if (fetchedObjects.count == 0) NSLog(@"CLIENT CONTROLLER: warning, company stuff not found for invoice:%@",invoiceAndPaymentData);
    else {
        CompanyStuff *findedStuff = fetchedObjects.lastObject;
        findedInvoiceAndPayment.companyStuff = findedStuff;
    }
    
    entity = [NSEntityDescription entityForName:@"CompanyAccounts" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSArray *companyAccounts = [invoiceAndPaymentData valueForKey:@"companyAccounts"];
    NSDictionary *companyAccount = companyAccounts.lastObject;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",[companyAccount valueForKey:@"GUID"]];
    [fetchRequest setPredicate:predicate];
    
    fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    if (fetchedObjects.count == 0) NSLog(@"CLIENT CONTROLLER: warning, company account not found for invoice:%@",invoiceAndPaymentData);
    else {
        CompanyAccounts *findedAccount = fetchedObjects.lastObject;
        findedInvoiceAndPayment.companyAccounts = findedAccount;
    }
    
    [fetchRequest release];

    [invoiceAndPaymentDataClean removeObjectForKey:@"companyStuff"];
    [invoiceAndPaymentDataClean removeObjectForKey:@"companyAccounts"];
    
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedInvoiceAndPayment.GUID];
    [self setValuesFromDictionary:invoiceAndPaymentDataClean anObject:findedInvoiceAndPayment];
    
    //    sleep(2);
    //    [self finalSave:moc];
    
}

-(void) makeUpdatesForFinancial:(NSDictionary *)financialData withCarrier:(Carrier *)carrier;
{
    NSString *financialGUID = [financialData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Financial" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",financialGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    Financial *findedFinancial = [fetchedObjects lastObject];
    if (!findedFinancial) { 
        NSLog(@"CLIENT CONTROLLER: warning, financial not found and will created");
        findedFinancial = (Financial *)[NSEntityDescription insertNewObjectForEntityForName:@"Financial" inManagedObjectContext:moc];
        findedFinancial.carrier = carrier;
    }
    NSMutableDictionary *financialDataClean = [NSMutableDictionary dictionaryWithDictionary:financialData];

    NSArray *invoiceAndPayments = [financialData valueForKey:@"invoiceAndPayments"];
    NSSet *currentInvoiceAndPayments = findedFinancial.invoicesAndPayments;
    __block NSMutableSet *currentInvoiceAndPaymentsMutable = [currentInvoiceAndPayments mutableCopy];
    
    [invoiceAndPayments enumerateObjectsUsingBlock:^(NSDictionary *invoiceAndPaymentData, NSUInteger idx, BOOL *stop) {
        [currentInvoiceAndPaymentsMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[invoiceAndPaymentData valueForKey:@"GUID"]]];
        [self makeUpdatesForInvoiceAndPayments:invoiceAndPaymentData withFinancial:findedFinancial];
    }];
    [currentInvoiceAndPaymentsMutable enumerateObjectsUsingBlock:^(InvoicesAndPayments *invoiceAndPaymentForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: InvoicesAndPayments in financial will removed with amount:%@ number:%@",invoiceAndPaymentForDelete.amountOurSide,invoiceAndPaymentForDelete.number);
        
        if (invoiceAndPaymentForDelete.isDeleted != YES) [moc deleteObject:invoiceAndPaymentForDelete];
        //sleep(5);
    }];
    [financialDataClean removeObjectForKey:@"invoiceAndPayments"];

    
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedFinancial.GUID];
    
    [self setValuesFromDictionary:financialDataClean anObject:findedFinancial];

    //    sleep(2);
    //    [self finalSave:moc];
    
}

-(void) makeUpdatesForDestinationListTargets:(NSDictionary *)destinationData withCarrier:(Carrier *)carrier;
{
    NSString *destinationGUID = [destinationData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListTargets" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    DestinationsListTargets *findedDestination = [fetchedObjects lastObject];
    if (!findedDestination) { 
        NSLog(@"CLIENT CONTROLLER: warning, destination target list not found and will created");
        findedDestination = (DestinationsListTargets *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListTargets" inManagedObjectContext:moc];
        findedDestination.carrier = carrier;
    }
    NSMutableDictionary *destinationDataClean = [NSMutableDictionary dictionaryWithDictionary:destinationData];

    
    NSArray *codesvsDestinationsList = [destinationData valueForKey:@"codesvsDestinationsList"];
    NSSet *currentCodesvsDestinationsList = findedDestination.codesvsDestinationsList;
    __block NSMutableSet *currentCodesvsDestinationsListMutable = [currentCodesvsDestinationsList mutableCopy];
    
    [codesvsDestinationsList enumerateObjectsUsingBlock:^(NSDictionary *codeData, NSUInteger idx, BOOL *stop) {
        [currentCodesvsDestinationsListMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[codeData valueForKey:@"GUID"]]];
        [self makeUpdatesForCodesvsDestinationsList:codeData withDestination:findedDestination];
    }];
    [currentCodesvsDestinationsListMutable enumerateObjectsUsingBlock:^(CodesvsDestinationsList *codeForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: codeForDelete in destination target list will removed with country:%@ specific:%@ code:%@",codeForDelete.country,codeForDelete.specific,codeForDelete.code);
        
        if (codeForDelete.isDeleted != YES) [moc deleteObject:codeForDelete];
        //sleep(5);
    }];
    [destinationDataClean removeObjectForKey:@"codesvsDestinationsList"];


    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedDestination.GUID];
    
    [self setValuesFromDictionary:destinationDataClean anObject:findedDestination];

    //    sleep(2);
    //    [self finalSave:moc];
    
}

-(void) makeUpdatesForDestinationListWeBuyResults:(NSDictionary *)resultData withDestinationListWeBuyTesting:(DestinationsListWeBuyTesting *)destinationsListWeBuyTesting;
{
    NSString *destinationGUID = [resultData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuyResults" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    DestinationsListWeBuyResults *findedResult = [fetchedObjects lastObject];
    if (!findedResult) { 
        NSLog(@"CLIENT CONTROLLER: warning, destination we buy testing result not found and will created");
        findedResult = (DestinationsListWeBuyResults *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListWeBuyResults" inManagedObjectContext:moc];
        findedResult.destinationsListWeBuyTesting = destinationsListWeBuyTesting;
    }
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedResult.GUID];
    
    [self setValuesFromDictionary:resultData anObject:findedResult];
    
    //    sleep(2);
    //    [self finalSave:moc];
    
}

-(void) makeUpdatesForDestinationListWeBuyTesting:(NSDictionary *)testingData withDestinationListWeBuy:(DestinationsListWeBuy *)destinationsListWeBuy;
{
    NSString *destinationGUID = [testingData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuyTesting" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    DestinationsListWeBuyTesting *findedTesting = [fetchedObjects lastObject];
    if (!findedTesting) { 
        NSLog(@"CLIENT CONTROLLER: warning, destination we buy testing not found and will created");
        findedTesting = (DestinationsListWeBuyTesting *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListWeBuyTesting" inManagedObjectContext:moc];
        findedTesting.destinationsListWeBuy = destinationsListWeBuy;
    }
    NSMutableDictionary *testingDataClean = [NSMutableDictionary dictionaryWithDictionary:testingData];

    
    NSArray *destinationsListWeBuyResults = [testingData valueForKey:@"destinationsListWeBuyResults"];
    NSSet *currentDestinationsListWeBuyResults = findedTesting.destinationsListWeBuyResults;
    __block NSMutableSet *currentDestinationsListWeBuyResultsMutable = [currentDestinationsListWeBuyResults mutableCopy];
    
    [destinationsListWeBuyResults enumerateObjectsUsingBlock:^(NSDictionary *resultData, NSUInteger idx, BOOL *stop) {
        [currentDestinationsListWeBuyResultsMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[resultData valueForKey:@"GUID"]]];
        [self makeUpdatesForDestinationListWeBuyResults:resultData withDestinationListWeBuyTesting:findedTesting];
    }];
    [currentDestinationsListWeBuyResultsMutable enumerateObjectsUsingBlock:^(DestinationsListWeBuyResults *resultsForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: DestinationsListWeBuyResults in destination we buy will removed with number:%@ ",resultsForDelete.dstnum);
        if (resultsForDelete.isDeleted != YES) [moc deleteObject:resultsForDelete];
        //sleep(5);
    }];
    [testingDataClean removeObjectForKey:@"destinationsListWeBuyResults"];

    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedTesting.GUID];
    
    [self setValuesFromDictionary:testingDataClean anObject:findedTesting];

    //    sleep(2);
    //    [self finalSave:moc];
    
}

-(void) makeUpdatesForDestinationListWeBuy:(NSDictionary *)destinationData withCarrier:(Carrier *)carrier;
{
    NSString *destinationGUID = [destinationData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuy" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    DestinationsListWeBuy *findedDestination = [fetchedObjects lastObject];
    if (!findedDestination) { 
        NSLog(@"CLIENT CONTROLLER: warning, destination we buy was not found and will created");
        findedDestination = (DestinationsListWeBuy *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListWeBuy" inManagedObjectContext:moc];
        findedDestination.carrier = carrier;
    }
    NSMutableDictionary *destinationDataClean = [NSMutableDictionary dictionaryWithDictionary:destinationData];

//    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedDestination.GUID];
//    
//    [self setValuesFromDictionary:destinationData anObject:findedDestination];

    NSArray *codesvsDestinationsList = [destinationData valueForKey:@"codesvsDestinationsList"];
    NSSet *currentCodesvsDestinationsList = findedDestination.codesvsDestinationsList;
    __block NSMutableSet *currentCodesvsDestinationsListMutable = [currentCodesvsDestinationsList mutableCopy];
    
    [codesvsDestinationsList enumerateObjectsUsingBlock:^(NSDictionary *codeData, NSUInteger idx, BOOL *stop) {
        [currentCodesvsDestinationsListMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[codeData valueForKey:@"GUID"]]];
        [self makeUpdatesForCodesvsDestinationsList:codeData withDestination:findedDestination];
    }];
    [currentCodesvsDestinationsListMutable enumerateObjectsUsingBlock:^(CodesvsDestinationsList *codeForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: codeForDelete in destination we buy will removed with country:%@ specific:%@ code:%@",codeForDelete.country,codeForDelete.specific,codeForDelete.code);
        
        if (codeForDelete.isDeleted != YES) [moc deleteObject:codeForDelete];
        //sleep(5);
    }];
    [destinationDataClean removeObjectForKey:@"codesvsDestinationsList"];


    NSArray *destinationsListWeBuyTesting = [destinationData valueForKey:@"destinationsListWeBuyTesting"];
    NSSet *currentDestinationsListWeBuyTesting = findedDestination.destinationsListWeBuyTesting;
    __block NSMutableSet *currentDestinationsListWeBuyTestingMutable = [currentDestinationsListWeBuyTesting mutableCopy];
    
    [destinationsListWeBuyTesting enumerateObjectsUsingBlock:^(NSDictionary *codeData, NSUInteger idx, BOOL *stop) {
        [currentDestinationsListWeBuyTestingMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[codeData valueForKey:@"GUID"]]];
        [self makeUpdatesForDestinationListWeBuyTesting:codeData withDestinationListWeBuy:findedDestination];
    }];
    [currentDestinationsListWeBuyTestingMutable enumerateObjectsUsingBlock:^(DestinationsListWeBuyTesting *testingForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: DestinationsListWeBuyTesting in destination we buy will removed with number list:%@ ",testingForDelete.dstnums);
        
        if (testingForDelete.isDeleted != YES) [moc deleteObject:testingForDelete];
        //sleep(5);
    }];
    [destinationDataClean removeObjectForKey:@"destinationsListWeBuyTesting"];

    [self setValuesFromDictionary:destinationDataClean anObject:findedDestination];
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedDestination.GUID];
    

    
    //    sleep(2);
    
}

-(void) makeUpdatesForDestinationListForSale:(NSDictionary *)destinationData withCarrier:(Carrier *)carrier;
{
    NSString *destinationGUID = [destinationData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListForSale" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    DestinationsListForSale *findedDestination = [fetchedObjects lastObject];
    if (!findedDestination) { 
        NSLog(@"CLIENT CONTROLLER: warning, destination for sale not found and will created");
        findedDestination = (DestinationsListForSale *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListForSale" inManagedObjectContext:moc];
        findedDestination.carrier = carrier;
    }
    NSMutableDictionary *destinationDataClean = [NSMutableDictionary dictionaryWithDictionary:destinationData];

//    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedDestination.GUID];
//    
//    [self setValuesFromDictionary:destinationData anObject:findedDestination];
    
    NSArray *codesvsDestinationsList = [destinationData valueForKey:@"codesvsDestinationsList"];
    NSSet *currentCodesvsDestinationsList = findedDestination.codesvsDestinationsList;
    __block NSMutableSet *currentCodesvsDestinationsListMutable = [currentCodesvsDestinationsList mutableCopy];
    
    [codesvsDestinationsList enumerateObjectsUsingBlock:^(NSDictionary *codeData, NSUInteger idx, BOOL *stop) {
        [currentCodesvsDestinationsListMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[codeData valueForKey:@"GUID"]]];
        [self makeUpdatesForCodesvsDestinationsList:codeData withDestination:findedDestination];
    }];
    [currentCodesvsDestinationsListMutable enumerateObjectsUsingBlock:^(CodesvsDestinationsList *codeForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: codeForDelete in destination for sale will removed with country:%@ specific:%@ code:%@",codeForDelete.country,codeForDelete.specific,codeForDelete.code);
        
        if (codeForDelete.isDeleted != YES) [moc deleteObject:codeForDelete];
        //sleep(5);
    }];
    [destinationDataClean removeObjectForKey:@"codesvsDestinationsList"];

    [self setValuesFromDictionary:destinationDataClean anObject:findedDestination];
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedDestination.GUID];

    //    sleep(2);
    //    [self finalSave:moc];
    
}

-(void) makeUpdatesForCarrierStuff:(NSDictionary *)carrierStuffData withCarrier:(Carrier *)carrier;
{
    NSString *destinationGUID = [carrierStuffData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CarrierStuff" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    CarrierStuff *findedStuff = [fetchedObjects lastObject];
    if (!findedStuff) { 
        NSLog(@"CLIENT CONTROLLER: warning, CarrierStuff not found and will created");
        findedStuff = (CarrierStuff *)[NSEntityDescription insertNewObjectForEntityForName:@"CarrierStuff" inManagedObjectContext:moc];
        findedStuff.carrier = carrier;
    }
    
    
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedStuff.GUID];
    
    [self setValuesFromDictionary:carrierStuffData anObject:findedStuff];
    
    //    sleep(2);
    //    [self finalSave:moc];
    
}

-(void) makeUpdatesForDestinationPushList:(NSDictionary *)destinationData withCarrier:(Carrier *)carrier;
{
    NSString *destinationGUID = [destinationData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListPushList" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",destinationGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    DestinationsListPushList *findedDestination = [fetchedObjects lastObject];
    if (!findedDestination) { 
        NSLog(@"CLIENT CONTROLLER: warning, destination push list not found and will created");
        findedDestination = (DestinationsListPushList *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListPushList" inManagedObjectContext:moc];
        findedDestination.carrier = carrier;
    }
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedDestination.GUID];

    [self setValuesFromDictionary:destinationData anObject:findedDestination];

//    sleep(2);
//    [self finalSave:moc];

}

-(void) makeUpdatesForCarrier:(NSDictionary *)carrierData withCompanyStuff:(CompanyStuff *)companyStuff
{
    NSString *carrierGUID = [carrierData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",carrierGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    Carrier *findedCarrier = [fetchedObjects lastObject];
    if (!findedCarrier) { 
        NSLog(@"CLIENT CONTROLLER: warning, carrier not found for company:%@ user:%@ withName:%@ and will created",companyStuff.currentCompany.name,companyStuff.email,[carrierData valueForKey:@"name"]);
        findedCarrier = (Carrier *)[NSEntityDescription 
                                          insertNewObjectForEntityForName:@"Carrier" 
                                          inManagedObjectContext:moc];
        findedCarrier.companyStuff = companyStuff;
    }
    NSMutableDictionary *carrierDataClean = [NSMutableDictionary dictionaryWithDictionary:carrierData];

    //    sleep(2);
//    [self finalSave:moc];


    NSArray *destinationsPushList = [carrierData valueForKey:@"destinationsListPushList"];
    NSSet *currentDestinationsPushList = findedCarrier.destinationsListPushList;
    __block NSMutableSet *currentDestinationsPushListMutable = [currentDestinationsPushList mutableCopy];

    [destinationsPushList enumerateObjectsUsingBlock:^(NSDictionary *destinstionData, NSUInteger idx, BOOL *stop) {
        [currentDestinationsPushListMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[destinstionData valueForKey:@"GUID"]]];
        [self makeUpdatesForDestinationPushList:destinstionData withCarrier:findedCarrier];
    }];
    [currentDestinationsPushListMutable enumerateObjectsUsingBlock:^(DestinationsListPushList *destinationForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: destination push list will removed with country:%@ specific:%@",destinationForDelete.country,destinationForDelete.specific);

        if (destinationForDelete.isDeleted != YES) [moc deleteObject:destinationForDelete];
        //sleep(5);
    }];
    [carrierDataClean removeObjectForKey:@"destinationsListPushList"];
    
    NSArray *carrierStuff = [carrierData valueForKey:@"carrierStuff"];
    NSSet *currentCarrierStuff = findedCarrier.carrierStuff;
    __block NSMutableSet *currentCarrierStuffsMutable = [currentCarrierStuff mutableCopy];
    
    [carrierStuff enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        [currentCarrierStuffsMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[data valueForKey:@"GUID"]]];
        [self makeUpdatesForCarrierStuff:data withCarrier:findedCarrier];
    }];
    [currentCarrierStuffsMutable enumerateObjectsUsingBlock:^(CarrierStuff *stuffForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: carrier staff will removed with firstName:%@ email list:%@",stuffForDelete.firstName,stuffForDelete.emailList);
        
        if (stuffForDelete.isDeleted != YES) [moc deleteObject:stuffForDelete];
        //sleep(5);
    }];
    [carrierDataClean removeObjectForKey:@"carrierStuff"];

    NSArray *destinationsListWeBuy = [carrierData valueForKey:@"destinationsListWeBuy"];
    NSSet *currentDestinationsListWeBuy = findedCarrier.destinationsListWeBuy;
    __block NSMutableSet *currentDestinationsListWeBuyMutable = [currentDestinationsListWeBuy mutableCopy];
    
    [destinationsListWeBuy enumerateObjectsUsingBlock:^(NSDictionary *destinstionData, NSUInteger idx, BOOL *stop) {
        [currentDestinationsListWeBuyMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[destinstionData valueForKey:@"GUID"]]];
        [self makeUpdatesForDestinationListWeBuy:destinstionData withCarrier:findedCarrier];
        
        NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:destinationsListWeBuy.count] doubleValue]];
        [self updateUIwithMessage:@"progress for destinations we buy" andProgressPercent:percentDone withObjectID:nil];

    }];
    [currentDestinationsListWeBuyMutable enumerateObjectsUsingBlock:^(DestinationsListWeBuy *destinationForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: destinationsListWeBuy will removed with country:%@ specific:%@",destinationForDelete.country,destinationForDelete.specific);
        
        if (destinationForDelete.isDeleted != YES) [moc deleteObject:destinationForDelete];
        //sleep(5);
    }];
    [carrierDataClean removeObjectForKey:@"destinationsListWeBuy"];

    
    NSArray *destinationsListForSale = [carrierData valueForKey:@"destinationsListForSale"];
    NSSet *currentDestinationsListForSale = findedCarrier.destinationsListForSale;
    __block NSMutableSet *currentDestinationsListForSaleMutable = [currentDestinationsListForSale mutableCopy];
    
    [destinationsListForSale enumerateObjectsUsingBlock:^(NSDictionary *destinstionData, NSUInteger idx, BOOL *stop) {
        [currentDestinationsListForSaleMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[destinstionData valueForKey:@"GUID"]]];
        [self makeUpdatesForDestinationListForSale:destinstionData withCarrier:findedCarrier];
        
        NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:destinationsListForSale.count] doubleValue]];
        [self updateUIwithMessage:@"progress for destinations for sale" andProgressPercent:percentDone withObjectID:nil];

    }];
    [currentDestinationsListForSaleMutable enumerateObjectsUsingBlock:^(DestinationsListForSale *destinationForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: destinationsListForSale will removed with country:%@ specific:%@",destinationForDelete.country,destinationForDelete.specific);
        
        if (destinationForDelete.isDeleted != YES) [moc deleteObject:destinationForDelete];
        //sleep(5);
    }];
    [carrierDataClean removeObjectForKey:@"destinationsListForSale"];

    
    NSArray *destinationsListTargets = [carrierData valueForKey:@"destinationsListTargets"];
    NSSet *currentDestinationsListTargets = findedCarrier.destinationsListTargets;
    __block NSMutableSet *currentDestinationsListTargetsMutable = [currentDestinationsListTargets mutableCopy];
    
    [destinationsListTargets enumerateObjectsUsingBlock:^(NSDictionary *destinstionData, NSUInteger idx, BOOL *stop) {
        [currentDestinationsListTargetsMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[destinstionData valueForKey:@"GUID"]]];
        [self makeUpdatesForDestinationListTargets:destinstionData withCarrier:findedCarrier];
    }];
    [currentDestinationsListTargetsMutable enumerateObjectsUsingBlock:^(DestinationsListTargets *destinationForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: destinationsListTargets will removed with country:%@ specific:%@",destinationForDelete.country,destinationForDelete.specific);
        
        if (destinationForDelete.isDeleted != YES) [moc deleteObject:destinationForDelete];
        //sleep(5);
    }];
    [carrierDataClean removeObjectForKey:@"destinationsListTargets"];

    
    NSArray *financial = [carrierData valueForKey:@"financial"];
    NSSet *currentFinancial = findedCarrier.financial;
    __block NSMutableSet *currentFinancialMutable = [currentFinancial mutableCopy];
    
    [financial enumerateObjectsUsingBlock:^(NSDictionary *destinstionData, NSUInteger idx, BOOL *stop) {
        [currentFinancialMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[destinstionData valueForKey:@"GUID"]]];
        [self makeUpdatesForFinancial:destinstionData withCarrier:findedCarrier];
        
        NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:financial.count] doubleValue]];
        [self updateUIwithMessage:@"progress for financial" andProgressPercent:percentDone withObjectID:nil];
    }];
    [currentFinancialMutable enumerateObjectsUsingBlock:^(Financial *financialForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: financial will removed with name:%@",financialForDelete.name);
        
        if (financialForDelete.isDeleted != YES) [moc deleteObject:financialForDelete];
        //sleep(5);
    }];
    [carrierDataClean removeObjectForKey:@"financial"];

    [self setValuesFromDictionary:carrierDataClean anObject:findedCarrier];
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedCarrier.GUID];

//    sleep(2);
    [self finalSave:moc];
    [currentDestinationsListWeBuyMutable release];
}

-(void) makeUpdatesForCompanyStuff:(NSDictionary *)stuffData withCurrentCompany:(CurrentCompany *)currentCompany;
{
    NSString *stuffGUID = [stuffData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",stuffGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    CompanyStuff *findedStuff = [fetchedObjects lastObject];
    if (!findedStuff) { 
        NSLog(@"CLIENT CONTROLLER: warning, stuff not found and will be created with email:%@",[stuffData valueForKey:@"email"]);
        findedStuff = (CompanyStuff *)[NSEntityDescription 
                                                  insertNewObjectForEntityForName:@"CompanyStuff" 
                                                  inManagedObjectContext:self.moc];
        findedStuff.currentCompany = currentCompany;
    }

    NSMutableDictionary *stuffDataClean = [NSMutableDictionary dictionaryWithDictionary:stuffData];
    [stuffDataClean removeObjectForKey:@"carrier"];
    [self setValuesFromDictionary:stuffDataClean anObject:findedStuff];
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedStuff.GUID];

//    sleep(2);
//    [self finalSave:moc];

    
    if (![findedStuff.currentCompany.GUID isEqualToString:currentCompany.GUID]) {
        NSLog(@"CLIENT CONTROLLER: warning, relationship was changed for stuff");
    }
    CompanyStuff *currentAdmin = [self authorization];

    if ([currentAdmin.isRegistrationDone boolValue] == YES) {
        
        NSArray *carriers = [stuffData valueForKey:@"carrier"];
        NSSet *currentCarriers = findedStuff.carrier;
        __block NSMutableSet *currentCarriersMutable = [currentCarriers mutableCopy];
        [carriers enumerateObjectsUsingBlock:^(NSDictionary *carrierData, NSUInteger idx, BOOL *stop) {
            NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:carriers.count] doubleValue]];

            [self updateUIwithMessage:[NSString stringWithFormat:@"carrier data progress:%@",[carrierData valueForKey:@"name"]] andProgressPercent:percentDone withObjectID:nil];

            [currentCarriersMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[carrierData valueForKey:@"GUID"]]];
            [self makeUpdatesForCarrier:carrierData withCompanyStuff:findedStuff];
        }];
        [currentCarriersMutable enumerateObjectsUsingBlock:^(Carrier *carrierForDelete, BOOL *stop) {
            NSLog(@"CLIENT CONTROLLER:warning, carrier with name:%@ will removed bcs it no longer in server graph for admin with email:%@",carrierForDelete.name,findedStuff.email);
            if (carrierForDelete.isDeleted != YES) [moc deleteObject:carrierForDelete];
        }];
        [currentCarriersMutable release];
    } else NSLog(@"CLIENT CONTROLLER: all entities bellow companyStuff accesseble only for approved users. Unapprove user with email:%@ isRegistrationDone:%@",currentAdmin.email, currentAdmin.isRegistrationDone);
//    sleep(2);
//
//    [self finalSave:moc];


}

-(void) makeUpdatesForOperationNecessaryToApprove:(NSDictionary *)operationData withCurrentCompany:(CurrentCompany *)currentCompany;
{
    
    NSString *operationDataGUID = [operationData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OperationNecessaryToApprove" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",operationDataGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    OperationNecessaryToApprove *findedOperation = [fetchedObjects lastObject];
    if (!findedOperation) { 
        NSLog(@"CLIENT CONTROLLER: warning, OperationNecessaryToApprove not found and will created");
        findedOperation = (OperationNecessaryToApprove *)[NSEntityDescription 
                                       insertNewObjectForEntityForName:@"OperationNecessaryToApprove" 
                                       inManagedObjectContext:moc];
        findedOperation.currentCompany = currentCompany;
        
    }

    [self setValuesFromDictionary:operationData anObject:findedOperation];

//    sleep(2);
//    [self finalSave:moc];

}
-(void) makeUpdatesForCompanyAccounts:(NSDictionary *)companyAccountData withCurrentCompany:(CurrentCompany *)currentCompany;
{
    
    NSString *companuAccountDataGUID = [companyAccountData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyAccounts" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",companuAccountDataGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    CompanyAccounts *findedAccount = [fetchedObjects lastObject];
    if (!findedAccount) { 
        NSLog(@"CLIENT CONTROLLER: warning, CompanyAccounts not found and will created");
        findedAccount = (CompanyAccounts *)[NSEntityDescription 
                                                          insertNewObjectForEntityForName:@"CompanyAccounts" 
                                                          inManagedObjectContext:moc];
        findedAccount.currentCompany = currentCompany;
        
    }
    
    [self setValuesFromDictionary:companyAccountData anObject:findedAccount];
    
    //    sleep(2);
    //    [self finalSave:moc];
    
}


-(void) makeUpdatesForCurrentCompany:(NSDictionary *)companyData;
{
    NSString *companyGUID = [companyData valueForKey:@"GUID"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",companyGUID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    CurrentCompany *findedCompany = [fetchedObjects lastObject];
    if (!findedCompany) { 
        //NSLog(@"CLIENT CONTROLLER: warning, company not found");
        if (companyData) {
            NSLog(@"CLIENT CONTROLLER: warning, company was created");

            findedCompany = (CurrentCompany *)[NSEntityDescription 
                                                        insertNewObjectForEntityForName:@"CurrentCompany" 
                                                        inManagedObjectContext:moc];
        } else return;
    }
    NSMutableDictionary *companyDataClean = [NSMutableDictionary dictionaryWithDictionary:companyData];
    [companyDataClean removeObjectForKey:@"companyStuff"];
    [companyDataClean removeObjectForKey:@"companyAccounts"];
    [companyDataClean removeObjectForKey:@"operationNecessaryToApprove"];

    [self setValuesFromDictionary:companyDataClean anObject:findedCompany];

    NSArray *companyAccounts = [companyData valueForKey:@"companyAccounts"];
    NSSet *currentCompanyAccounts = findedCompany.companyAccounts;
    __block NSMutableSet *currentCompanyAccountsMutable = [currentCompanyAccounts mutableCopy];
    for (NSDictionary *companyAccountData in companyAccounts) {
        NSString *guid = [companyAccountData valueForKey:@"GUID"];
        [currentCompanyAccountsMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",guid]];
        [self makeUpdatesForCompanyAccounts:companyAccountData withCurrentCompany:findedCompany];
    };
    [currentCompanyAccountsMutable enumerateObjectsUsingBlock:^(CompanyAccounts *accountForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: accountForDelete will removed with name:%@",accountForDelete.name);
        if (accountForDelete.isDeleted != YES) [moc deleteObject:accountForDelete];
    }];
    [currentCompanyAccountsMutable release];

    [self finalSave:moc];

    // before we will mark it as finish, we must to check if company really have admin 
//    CompanyStuff *currentAdmin = [self authorization];
//    NSSet *companyStuffs = findedCompany.companyStuff;
//    NSSet *companyStuffsFiltered = [companyStuffs filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"GUID == %@",currentAdmin.GUID]];
//    if ([companyStuffsFiltered count] == 1) [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"finish" forKey:@"update"] forKey:findedCompany.GUID];
//    else [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"external server" forKey:@"update"] forKey:findedCompany.GUID];

//    sleep(2);
//    
//    [self finalSave:moc];
    NSArray *companyStuff = [companyData valueForKey:@"companyStuff"];
    NSSet *currentStuffs = findedCompany.companyStuff;
    __block NSMutableSet *currentStuffsMutable = [currentStuffs mutableCopy];
    for (NSDictionary *stuffData in companyStuff) {
//    [companyStuff enumerateObjectsUsingBlock:^(NSDictionary *stuffData, NSUInteger idx, BOOL *stop) {
        //if (stuffData) { 
            NSString *guid = [stuffData valueForKey:@"GUID"];
            [currentStuffsMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",guid]];
            [self makeUpdatesForCompanyStuff:stuffData withCurrentCompany:findedCompany];
        //} else NSLog(@"CLIENT CONTROLLER: warning, company data:%@ don't have stuff guid for local stuff data:%@",companyData,currentStuffs);
    };
    [currentStuffsMutable enumerateObjectsUsingBlock:^(CompanyStuff *stuffForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER: stuff will removed with email:%@",stuffForDelete.email);
        if (stuffForDelete.isDeleted != YES) [moc deleteObject:stuffForDelete];
    }];
    [currentStuffsMutable release];
    sleep(2);

//    [self finalSave:moc];
//    [currentStuffsMutable release];
    
    NSArray *operations = [companyData valueForKey:@"operationNecessaryToApprove"];
    NSSet *currentOperations = findedCompany.operationNecessaryToApprove;
    __block NSMutableSet *currentOperationsMutable = [currentOperations mutableCopy];
    //NSLog(@"CLIENT CONTROLLER: operations before:%@",currentOperationsMutable);
    [operations enumerateObjectsUsingBlock:^(NSDictionary *operationData, NSUInteger idx, BOOL *stop) {
        [currentOperationsMutable filterUsingPredicate:[NSPredicate predicateWithFormat:@"GUID != %@",[operationData valueForKey:@"GUID"]]];
        [self makeUpdatesForOperationNecessaryToApprove:operationData withCurrentCompany:findedCompany];
    }];
    //NSLog(@"CLIENT CONTROLLER: operations after:%@",currentOperationsMutable);
    [currentOperationsMutable enumerateObjectsUsingBlock:^(OperationNecessaryToApprove *operationForDelete, BOOL *stop) {
        NSLog(@"CLIENT CONTROLLER:warning, operation for guid:%@ will removed bcs it no longer in server graph",operationForDelete.forGUID);
        if (operationForDelete.isDeleted != YES) [moc deleteObject:operationForDelete];
    }];
    
//    sleep(2);
//    [self finalSave:moc];
    
    [self setUserDefaultsObject:[NSDictionary dictionaryWithObject:@"registered" forKey:@"update"] forKey:findedCompany.GUID];


}

-(NSString *)getAllObjectsForEntity:(NSString *)entityName immediatelyStart:(BOOL)isImmediatelyStart isUserAuthorized:(BOOL)isUserAuthorized;
{
    CompanyStuff *admin = [self authorization];
    if (isUserAuthorized) admin.isRegistrationDone = [NSNumber numberWithBool:YES];
    
//    if ([admin.isRegistrationDone boolValue] == NO) {
//        [self updateUIwithMessage:@"Current company admin still not approve you." withObjectID:admin.objectID withLatestMessage:YES error:YES];
//        return @"Current company admin still not approve you.";
//    }
    
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastGraphUpdatingTime"];
    NSNumber *isCurrentUpdateProcessing = [[NSUserDefaults standardUserDefaults] objectForKey:@"isCurrentUpdateProcessing"];
    if (lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] > 60 || isImmediatelyStart) {
        // give chanse to write all previous changes to disk
        if (isImmediatelyStart) { 
            if (!isCurrentUpdateProcessing) [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isCurrentUpdateProcessing"];
            else {
                while ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isCurrentUpdateProcessing"] boolValue]) {
                    NSLog(@"we are waiting while other job finish");
                    sleep(4);
                }
            }
            sleep(2);
        }
        NSLog(@"CLIENT CONTROLLER: get all objects started..");

        [self updateUIwithMessage:@"get all objects start" withObjectID:nil withLatestMessage:NO error:NO];
        
        NSMutableDictionary *prepeareForJSONRequest = [[NSMutableDictionary alloc] init];
        [prepeareForJSONRequest setValue:admin.email forKey:@"authorizedUserEmail"];
        [prepeareForJSONRequest setValue:admin.password forKey:@"authorizedUserPassword"];
        [prepeareForJSONRequest setValue:admin.currentCompany.GUID forKey:@"objectGUID"];
        [prepeareForJSONRequest setValue:entityName forKey:@"objectEntity"];
        [prepeareForJSONRequest setValue:[NSNumber numberWithBool:YES] forKey:@"isIncludeSubEntities"];
        [prepeareForJSONRequest setValue:[NSNumber numberWithBool:NO] forKey:@"isIncludeAllObjects"];
        //NSLog(@"CLIENT CONTROLLER: GetObjects sent:%@",prepeareForJSONRequest);
        
        NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"GetObjects" withJSONRequest:prepeareForJSONRequest];
        [prepeareForJSONRequest release];
        if (receivedObject) {
            [self updateUIwithMessage:@"get all objects processing" withObjectID:nil withLatestMessage:NO error:NO];
            
            //NSLog(@"CLIENT CONTROLLER: GetObjects Received:%@",receivedObject);
            NSString *error = [receivedObject valueForKey:@"error"];
            if (error) {  
                [self updateUIwithMessage:error withObjectID:nil withLatestMessage:NO error:YES];
                return error;
            } else {
                // here is update internal graph
                if ([entityName isEqualToString:@"CurrentCompany"]) { 
                    NSString *allObjectsString = [receivedObject valueForKey:@"objects"];
                    NSData *allObjectsData = [self dataWithBase64EncodedString:allObjectsString];
                    NSDictionary *listObjects = [NSKeyedUnarchiver unarchiveObjectWithData:allObjectsData];
                    
                    //NSArray *listObjects = [receivedObject valueForKey:@"objects"];
                    //NSDictionary *objects = [receivedObject valueForKey:@"objects"];//[listObjects lastObject];
                    [self makeUpdatesForCurrentCompany:listObjects];
                }
                if ([entityName isEqualToString:@"CompanyStuff"]) {
                    NSString *allObjectsString = [receivedObject valueForKey:@"objects"];
                    NSData *allObjectsData = [self dataWithBase64EncodedString:allObjectsString];
                    NSDictionary *listObjects = [NSKeyedUnarchiver unarchiveObjectWithData:allObjectsData];
                    
                    //NSArray *listObjects = [receivedObject valueForKey:@"objects"];
                    //                NSDictionary *objects = [receivedObject valueForKey:@"objects"];//[listObjects lastObject];
                    [self makeUpdatesForCompanyStuff:listObjects withCurrentCompany:admin.currentCompany];
                }
                if ([entityName isEqualToString:@"Carrier"]) { 
                    //NSArray *listObjects = [receivedObject valueForKey:@"objects"];
                    //NSDictionary *objects = [receivedObject valueForKey:@"objects"];//[listObjects lastObject];
                    NSString *allObjectsString = [receivedObject valueForKey:@"objects"];
                    NSData *allObjectsData = [self dataWithBase64EncodedString:allObjectsString];
                    NSDictionary *listObjects = [NSKeyedUnarchiver unarchiveObjectWithData:allObjectsData];
                    
                    [self makeUpdatesForCarrier:listObjects withCompanyStuff:admin];
                }
                if ([entityName isEqualToString:@"Events"]) {
                    NSString *allObjectsString = [receivedObject valueForKey:@"objects"];
                    NSData *allObjectsData = [self dataWithBase64EncodedString:allObjectsString];
                    NSArray *listObjects = [NSKeyedUnarchiver unarchiveObjectWithData:allObjectsData];
                    [self makeUpdatesForEvents:listObjects];
                }
            }
            
            [self finalSave:self.moc];
            [self updateUIwithMessage:@"get all objects finish" withObjectID:nil withLatestMessage:YES error:NO];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastGraphUpdatingTime"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else { 
        NSLog(@"CLIENT CONTROLLER: i'm sorry, get all objects was not started.. last update time:%@ and processing:%@",lastUpdate,isCurrentUpdateProcessing);
        return @"timeout";
    }
    return nil;
}

#pragma mark -
#pragma mark GetObjects new guids methods
-(NSDictionary *) getJSONAnswerForFunctionVersionTwo:(NSString *)function 
                                     withJSONRequest:(NSMutableDictionary *)request;
{
    //    receivedData = [[NSMutableData alloc] init];
    [self updateUIwithMessage:@"server download is started" withObjectID:nil withLatestMessage:NO error:NO];
    NSDictionary *finalResultAlloc = [[NSMutableDictionary alloc] init];
    @autoreleasepool {
        
        
        NSError *error = nil;
        
        NSString *jsonStringForReturn = [request JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
        if (error) NSLog(@"CLIENT CONTROLLER: json decoding error:%@ in function:%@",[error localizedDescription],function);
        NSData *bodyData = [jsonStringForReturn dataUsingEncoding:NSUTF8StringEncoding];
        NSData *dataForBody = [[[NSData alloc] initWithData:bodyData] autorelease];
        //NSLog(@"CLIENT CONTROLLER: string lenght is:%@ bytes",[NSNumber numberWithUnsignedInteger:[dataForBody length]]);
        NSString *functionString = [NSString stringWithFormat:@"/%@",function];
        NSURL *urlForRequest = [NSURL URLWithString:functionString relativeToURL:mainServer];
        NSMutableURLRequest *requestToServer = [NSMutableURLRequest requestWithURL:urlForRequest];
        [requestToServer setHTTPMethod:@"POST"];
        [requestToServer setHTTPBody:dataForBody];
        [requestToServer setTimeoutInterval:600];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[urlForRequest host]];
        
        NSData *receivedResult = [NSURLConnection sendSynchronousRequest:requestToServer returningResponse:nil error:&error];
        
        if (error) {
            NSLog(@"CLIENT CONTROLLER: getJSON answer error download:%@",[error localizedDescription]);
            [self updateUIwithMessage:[error localizedDescription] withObjectID:nil withLatestMessage:YES error:NO];
            return nil;
        }
        NSString *answer = [[NSString alloc] initWithData:receivedResult encoding:NSUTF8StringEncoding];
        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        NSDictionary *finalResult = [jkitDecoder objectWithUTF8String:(const unsigned char *)[answer UTF8String] length:[answer length] error:&error];
        [finalResultAlloc setValuesForKeysWithDictionary:finalResult];
        
        [answer release];
        [self updateUIwithMessage:@"server download is finished" withObjectID:nil withLatestMessage:NO error:NO];
        
        if (error) NSLog(@"CLIENT CONTROLLER: getJSON answer failed to decode answer with error:%@",[error localizedDescription]);
    }
    NSDictionary *finalResultToReturn = [NSDictionary dictionaryWithDictionary:finalResultAlloc];
    [finalResultAlloc release];
    
    return finalResultToReturn;

}

-(NSArray *)getAllObjectsListWithEntityForList:(NSString *)entityForList 
                            withMainObjectGUID:(NSString *)mainObjectGUID 
                          withMainObjectEntity:(NSString *)mainObjectEntity 
                                     withAdmin:(CompanyStuff *)admin  
                                  withDateFrom:(NSDate *)dateFrom 
                                    withDateTo:(NSDate *)dateTo;
{
    NSMutableDictionary *prepeareForJSONRequest = [[NSMutableDictionary alloc] init];
    [prepeareForJSONRequest setValue:admin.email forKey:@"authorizedUserEmail"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"authorizedUserPassword"];
    [prepeareForJSONRequest setValue:entityForList forKey:@"entityForList"];
    [prepeareForJSONRequest setValue:mainObjectGUID forKey:@"mainObjectGUID"];
    [prepeareForJSONRequest setValue:mainObjectEntity forKey:@"mainObjectEntity"];
    [prepeareForJSONRequest setValue:dateFrom.description forKey:@"dateFrom"];
    [prepeareForJSONRequest setValue:dateTo.description forKey:@"dateTo"];

    NSDictionary *receivedObject = nil;
    while (receivedObject == nil) {
        receivedObject = [self getJSONAnswerForFunctionVersionTwo:@"GetObjectsList" withJSONRequest:prepeareForJSONRequest];
        if (!receivedObject) sleep(5);
    }
    
    [prepeareForJSONRequest release];
    if (receivedObject) return [receivedObject valueForKey:@"allGUIDs"];
    else return nil;
    
}

-(NSArray *)getAllObjectsListWithGUIDs:(NSArray *)guids 
                            withEntity:(NSString *)entity 
                             withAdmin:(CompanyStuff *)admin
{
    if (guids.count > 0) {
        //NSMutableDictionary *receivedObject = [[NSMutableDictionary alloc] init];
        NSMutableArray *finalListObjectsMutable = [[NSMutableArray alloc] init];

        @autoreleasepool {
            NSMutableDictionary *prepeareForJSONRequest = [[NSMutableDictionary alloc] init];
            [prepeareForJSONRequest setValue:admin.email forKey:@"authorizedUserEmail"];
            [prepeareForJSONRequest setValue:admin.password forKey:@"authorizedUserPassword"];
            [prepeareForJSONRequest setValue:entity forKey:@"entity"];
            [prepeareForJSONRequest setValue:guids forKey:@"allGUIDs"];
            
            //    NSDictionary *receivedObject = [self getJSONAnswerForFunctionVersionTwo:@"GetObjectsWithGUIDs" withJSONRequest:prepeareForJSONRequest];
            //NSDictionary *receivedObject = nil;
            NSDictionary *receivedResult = nil;
            while (!receivedResult) {
                receivedResult = [self getJSONAnswerForFunctionVersionTwo:@"GetObjectsWithGUIDs" withJSONRequest:prepeareForJSONRequest];
            }
            //[receivedObject setValuesForKeysWithDictionary:receivedResult];

            //NSLog(@"CLIENT CONTROLLER: receivedObject:%@",receivedResult);

            [prepeareForJSONRequest release];
            //        }
            //        if (receivedObject.count > 0) {
            //            @autoreleasepool {
            
            NSString *error;
            NSString *allObjectsString = [receivedResult valueForKey:@"objects"];
            NSData *allObjectsData = [self dataWithBase64EncodedString:allObjectsString];
            //        NSArray *listObjects = [NSKeyedUnarchiver unarchiveObjectWithData:allObjectsData];
            NSPropertyListFormat format;  
            NSArray *decodedObjects = [NSPropertyListSerialization propertyListFromData:allObjectsData mutabilityOption:0 format:&format errorDescription:&error];
            [finalListObjectsMutable addObjectsFromArray:decodedObjects];
            if (error) NSLog(@"SERVER CONTRORLER: allObjectsSerializationFailed:%@ format:%luu",error,format);
            //NSLog(@"CLIENT CONTROLLER: guids:%@",guids);
            
            //NSLog(@"CLIENT CONTROLLER: decodedObjects:%@",decodedObjects);
        }
        NSArray *finalListObjects = [NSArray arrayWithArray:finalListObjectsMutable];
        [finalListObjectsMutable release];
        //[receivedObject release];

        return finalListObjects;
//        } else { 
//            [receivedObject release];
//            return nil;
//        }
    } else return  nil;
}

-(NSArray *) updateGraphForObjects:(NSArray *)allObjects 
                        withEntity:(NSString *)entityFor 
                         withAdmin:(CompanyStuff *)admin 
                    withRootObject:(NSManagedObject *)rootObject
             isEveryTenPercentSave:(BOOL)isEveryTenPercentSave;
{
    //NSArray *allObjects = [self getAllObjectsListWithGUIDs:guids withEntity:entityFor withAdmin:admin];
    // RETURN UPDATED IDs
    __block NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityFor inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    __block NSArray *fetchedObjects = nil;
    NSMutableArray *allUpdatedIDs = [NSMutableArray array];
    NSUInteger allObjectsCount = allObjects.count;
    
    [allObjects enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {

        NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:allObjectsCount] doubleValue]];
        [self updateUIwithMessage:[NSString stringWithFormat:@"progress for update graph:%@",entityFor] andProgressPercent:percentDone withObjectID:nil];
        
        NSString *guid = [obj valueForKey:@"GUID"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",guid];
        [fetchRequest setPredicate:predicate];
        fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects.count > 0) {
            
            NSManagedObject *oldObject = fetchedObjects.lastObject;
            //NSLog(@"CLIENT CONTROLLER: object with entity:%@ will UPDATE and new GUID:%@ oldGUID:%@ objectsFinded:%lu",entityFor,guid,[oldObject valueForKey:@"GUID"],fetchedObjects.count);
//            if ([entityFor isEqualToString:@"CodesvsDestinationsList"]) {
//                NSLog(@"CLIENT CONTROLLER: object with entity:%@ will UPDATE and new GUID:%@ oldGUID:%@ country:%@ specific:%@ destination GUID:%@",entityFor,guid,[oldObject valueForKey:@"GUID"],[oldObject valueForKey:@"country"],[oldObject valueForKey:@"specific"],[oldObject valueForKeyPath:@"destinationsListForSale.GUID"]);
// 
//            } else NSLog(@"CLIENT CONTROLLER: object with entity:%@ will UPDATE and new GUID:%@ oldGUID:%@ objectsFinded:%lu",entityFor,guid,[oldObject valueForKey:@"GUID"],fetchedObjects.count);

                
            [oldObject setValuesForKeysWithDictionary:obj];
            [allUpdatedIDs addObject:guid];
        } else {
            __block NSString *keyForRootObject = nil;
            NSDictionary *allRelationShips = entity.relationshipsByName;
            [allRelationShips enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSRelationshipDescription *obj, BOOL *stop) {
                if ([obj.destinationEntity.name isEqualToString:rootObject.entity.name]) {
                    keyForRootObject = key;
                    *stop = YES;
                }
            }];
            if (keyForRootObject) {
                NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entityFor inManagedObjectContext:moc];
                [newObject setValuesForKeysWithDictionary:obj];
                
                [newObject setValue:rootObject forKey:keyForRootObject];
                [allUpdatedIDs addObject:guid];
//                if ([entityFor isEqualToString:@"CodesvsDestinationsList"]) {
//                    NSLog(@"CLIENT CONTROLLER: object with entity:%@ will CREATE and new GUID:%@ oldGUID:%@ country:%@ specific:%@ destination GUID:%@",entityFor,guid,[newObject valueForKey:@"GUID"],[newObject valueForKey:@"country"],[newObject valueForKey:@"specific"],[newObject valueForKeyPath:@"destinationsListForSale.GUID"]);
//                    
//                } else NSLog(@"CLIENT CONTROLLER: object with entity:%@ will CREATE and new GUID:%@ oldGUID:%@ objectsFinded:%lu",entityFor,guid,[newObject valueForKey:@"GUID"],fetchedObjects.count);


            } else { 
                
                NSLog(@"CLIENT CONTROLLER: >>>>>>>>>>>>warning! object with entity:%@ and allRelationShips:%@ ",entityFor,allRelationShips);
            }
            //NSLog(@"CLIENT CONTROLLER: object with entity:%@ will CREATE",entityFor);

        }
        
        if (isEveryTenPercentSave && (allObjectsCount > 100) && (idx % allObjectsCount * 0.1 == 0)) [self finalSave:moc],NSLog(@">>>>>>>updateGraphForObjects SAVED");

    }];
    return allUpdatedIDs;
    
}

-(void) updateLocalGraphFromSnowEnterpriseServerForCarrierID:(NSManagedObjectID *)carrierID
                                              withDateFrom:(NSDate *)dateFrom 
                                                withDateTo:(NSDate *)dateTo
                                                 withAdmin:(CompanyStuff *)admin;
{
    //////////////////////////////// FOR SALE BLOCK 
    Carrier *carrier = (Carrier *)[self.moc objectWithID:carrierID];
    
    NSArray *allGUIDsForSale = [self getAllObjectsListWithEntityForList:@"DestinationsListForSale" withMainObjectGUID:carrier.GUID withMainObjectEntity:@"Carrier" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
    NSArray *allObjectsForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsForSale withEntity:@"DestinationsListForSale" withAdmin:admin];
    if (allGUIDsForSale && allObjectsForGUIDS) {
        
        NSArray *updatedForSaleIDs = [self updateGraphForObjects:allObjectsForGUIDS withEntity:@"DestinationsListForSale" withAdmin:admin withRootObject:carrier  isEveryTenPercentSave:NO];
        [self finalSave:moc];
        
        NSUInteger forSaleCount = allGUIDsForSale.count;
        
        [allGUIDsForSale enumerateObjectsUsingBlock:^(NSString *forSaleGUID, NSUInteger idx, BOOL *stop) {
            // for sale update start
            NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:forSaleCount] doubleValue]];
            [self updateUIwithMessage:@"progress for destinations for sale" andProgressPercent:percentDone withObjectID:nil];
            
            NSError *error = nil;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListForSale" inManagedObjectContext:self.moc];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",forSaleGUID];
            [fetchRequest setPredicate:predicate];
            NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
            DestinationsListForSale *findedDestination = fetchedObjects.lastObject;
            [fetchRequest release];
            
            if (findedDestination) {
                //////////////////////////////// CODES BLOCK 
                NSArray *allGUIDsCodes = [self getAllObjectsListWithEntityForList:@"CodesvsDestinationsList" withMainObjectGUID:findedDestination.GUID withMainObjectEntity:@"DestinationsListForSale" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                NSArray *allObjectsCodesForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsCodes withEntity:@"CodesvsDestinationsList" withAdmin:admin];
                if (allGUIDsCodes && allObjectsCodesForGUIDS) {
                    __block NSArray *updatedCodesIDs = [self updateGraphForObjects:allObjectsCodesForGUIDS withEntity:@"CodesvsDestinationsList" withAdmin:admin withRootObject:findedDestination  isEveryTenPercentSave:NO];
                    [self finalSave:moc];
                    NSSet *currentCodes = findedDestination.codesvsDestinationsList;
                    // remove objects which was not on server
                    [currentCodes enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, BOOL *stop) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",code.GUID];
                        NSArray *filteredCodesIDs = [updatedCodesIDs filteredArrayUsingPredicate:predicate];
                        if (filteredCodesIDs.count == 0) {
                            [moc deleteObject:code];
                            NSLog(@"CLIENT CONTROLLER: >>>>>>> code:%@ country:%@ specific:%@ not on server and will removed",code.code,code.country,code.specific);
                        }
                    }];
                }
                //////////////////////////////// PER HOUR STAT BLOCK 
                NSArray *allGUIDsPerHour = [self getAllObjectsListWithEntityForList:@"DestinationPerHourStat" withMainObjectGUID:findedDestination.GUID withMainObjectEntity:@"DestinationsListForSale" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                NSArray *allObjectsPerHourForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsPerHour withEntity:@"DestinationPerHourStat" withAdmin:admin];
                if (allGUIDsPerHour && allObjectsPerHourForGUIDS) {
                    
                    NSArray *updatedPerHourIDs = [self updateGraphForObjects:allObjectsPerHourForGUIDS withEntity:@"DestinationPerHourStat" withAdmin:admin withRootObject:findedDestination  isEveryTenPercentSave:NO];
                    [self finalSave:moc];
                    // remove objects which was not on server
                    NSSet *currentPerHourStat = findedDestination.destinationPerHourStat;
                    [currentPerHourStat enumerateObjectsUsingBlock:^(DestinationPerHourStat *perHour, BOOL *stop) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",perHour.GUID];
                        NSArray *filteredPerHourIDs = [updatedPerHourIDs filteredArrayUsingPredicate:predicate];
                        if (filteredPerHourIDs.count == 0) {
                            [moc deleteObject:perHour];
                            NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",perHour.entity.name);
                        }
                    }];
                }
            } else NSLog(@"CLIENT CONTROLLER: warning destinations for sale NOT FOUND for guid:%@",forSaleGUID);
        }];
        // remove objects which was not on server
        NSSet *allDestinationsForSale = carrier.destinationsListForSale;
        [allDestinationsForSale enumerateObjectsUsingBlock:^(DestinationsListForSale *destination, BOOL *stop) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",destination.GUID];
            NSArray *filteredForSaleIDs = [updatedForSaleIDs filteredArrayUsingPredicate:predicate];
            if (filteredForSaleIDs.count == 0) {
                [moc deleteObject:destination];
                NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",destination.entity.name);
            }
        }];
    }
    /////////////////////////////// WE BUY BLOCK 
    NSArray *allGUIDsWeBuy = [self getAllObjectsListWithEntityForList:@"DestinationsListWeBuy" withMainObjectGUID:carrier.GUID withMainObjectEntity:@"Carrier" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
    allObjectsForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsWeBuy withEntity:@"DestinationsListWeBuy" withAdmin:admin];
    if (allGUIDsWeBuy && allObjectsForGUIDS) {
        
        NSArray *updatedWeBuyIDs = [self updateGraphForObjects:allObjectsForGUIDS withEntity:@"DestinationsListWeBuy" withAdmin:admin withRootObject:carrier  isEveryTenPercentSave:NO];
        [self finalSave:moc];
        NSUInteger weBuyCount = allGUIDsWeBuy.count;
        
        [allGUIDsWeBuy enumerateObjectsUsingBlock:^(NSString *weBuyGUID, NSUInteger idx, BOOL *stop) {
            NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:weBuyCount] doubleValue]];
            [self updateUIwithMessage:@"progress for destinations we buy" andProgressPercent:percentDone withObjectID:nil];
            NSError *error = nil;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuy" inManagedObjectContext:self.moc];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",weBuyGUID];
            [fetchRequest setPredicate:predicate];
            NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
            DestinationsListWeBuy *findedDestination = fetchedObjects.lastObject;
            [fetchRequest release];
            
            if (findedDestination) {
                //////////////////////////////// CODES BLOCK 
                NSArray *allGUIDsCodes = [self getAllObjectsListWithEntityForList:@"CodesvsDestinationsList" withMainObjectGUID:findedDestination.GUID withMainObjectEntity:@"DestinationsListForSale" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                NSArray *allObjectsCodesForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsCodes withEntity:@"CodesvsDestinationsList" withAdmin:admin];
                if (allGUIDsCodes && allObjectsCodesForGUIDS) {
                    __block NSArray *updatedCodesIDs = [self updateGraphForObjects:allObjectsCodesForGUIDS withEntity:@"CodesvsDestinationsList" withAdmin:admin withRootObject:findedDestination  isEveryTenPercentSave:NO];
                    [self finalSave:moc];
                    NSSet *currentCodes = findedDestination.codesvsDestinationsList;
                    // remove objects which was not on server
                    [currentCodes enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, BOOL *stop) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",code.GUID];
                        NSArray *filteredCodesIDs = [updatedCodesIDs filteredArrayUsingPredicate:predicate];
                        if (filteredCodesIDs.count == 0) {
                            [moc deleteObject:code];
                            NSLog(@"CLIENT CONTROLLER: >>>>>>> code:%@ country:%@ specific:%@ not on server and will removed",code.code,code.country,code.specific);
                        }
                    }];
                }
                //////////////////////////////// PER HOUR STAT BLOCK 
                NSArray *allGUIDsPerHour = [self getAllObjectsListWithEntityForList:@"DestinationPerHourStat" withMainObjectGUID:findedDestination.GUID withMainObjectEntity:@"DestinationsListForSale" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                NSArray *allObjectsPerHourForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsPerHour withEntity:@"DestinationPerHourStat" withAdmin:admin];
                if (allGUIDsPerHour && allObjectsPerHourForGUIDS) {
                    
                    NSArray *updatedPerHourIDs = [self updateGraphForObjects:allObjectsPerHourForGUIDS withEntity:@"DestinationPerHourStat" withAdmin:admin withRootObject:findedDestination  isEveryTenPercentSave:NO];
                    [self finalSave:moc];
                    // remove objects which was not on server
                    NSSet *currentPerHourStat = findedDestination.destinationPerHourStat;
                    [currentPerHourStat enumerateObjectsUsingBlock:^(DestinationPerHourStat *perHour, BOOL *stop) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",perHour.GUID];
                        NSArray *filteredPerHourIDs = [updatedPerHourIDs filteredArrayUsingPredicate:predicate];
                        if (filteredPerHourIDs.count == 0) {
                            [moc deleteObject:perHour];
                            NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",perHour.entity.name);
                        }
                    }];
                }
                
            } else NSLog(@"CLIENT CONTROLLER: warning destinations we buy NOT FOUND for guid:%@",weBuyGUID);
        }];
        // remove objects which was not on server
        NSSet *allDestinationsWeBuy = carrier.destinationsListWeBuy;
        [allDestinationsWeBuy enumerateObjectsUsingBlock:^(DestinationsListWeBuy *destination, BOOL *stop) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",destination.GUID];
            NSArray *filteredWeBuyIDs = [updatedWeBuyIDs filteredArrayUsingPredicate:predicate];
            if (filteredWeBuyIDs.count == 0) {
                [moc deleteObject:destination];
                NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",destination.entity.name);
            }
        }];
    }

}

-(void) updateLocalGraphFromSnowEnterpriseServerWithDateFrom:(NSDate *)dateFrom 
                                                  withDateTo:(NSDate *)dateTo
                               withIncludeCarrierSubentities:(BOOL)isIncludeCarrierSubentities;

{
    CompanyStuff *admin = [self authorization];
    CurrentCompany *currentCompany = admin.currentCompany;
    
    // update admin list:
    NSArray *allGUIDs = [self getAllObjectsListWithEntityForList:@"CompanyStuff" withMainObjectGUID:currentCompany.GUID withMainObjectEntity:@"CurrentCompany" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
    NSArray *allObjectsForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDs withEntity:@"CompanyStuff" withAdmin:admin];
    if (allGUIDs && allObjectsForGUIDS) {
        NSArray *updatedStuffIDs = [self updateGraphForObjects:allObjectsForGUIDS withEntity:@"CompanyStuff" withAdmin:admin withRootObject:currentCompany isEveryTenPercentSave:NO];
        [self finalSave:moc]; 
        // update carrier list:
        NSMutableArray *stuffIDsWhichWasUpdated = [NSMutableArray array];
        [allGUIDs enumerateObjectsUsingBlock:^(NSString *stuffGUID, NSUInteger idx, BOOL *stop) {
            
            // stuff update start
            NSError *error = nil;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",stuffGUID];
            [fetchRequest setPredicate:predicate];
            NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
            CompanyStuff *stuff = fetchedObjects.lastObject;
            [fetchRequest release];
            [stuffIDsWhichWasUpdated addObject:stuff.objectID];
            //NSLog(@"CLIENT CONTROLLER:>>>>>>> stuff start update:%@",stuff.email);
            
            //////////////////////////////// CARRIERS BLOCK 
            
            NSArray *allGUIDsCarrier = [self getAllObjectsListWithEntityForList:@"Carrier" withMainObjectGUID:stuff.GUID withMainObjectEntity:@"CompanyStuff" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
            NSArray *allObjectsForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsCarrier withEntity:@"Carrier" withAdmin:admin];
            if (allGUIDsCarrier && allObjectsForGUIDS) {
                
                NSArray *updatedCarrierIDs = [self updateGraphForObjects:allObjectsForGUIDS withEntity:@"Carrier" withAdmin:admin withRootObject:stuff  isEveryTenPercentSave:NO];
                [self finalSave:moc];
                sleep(1);
                
                NSUInteger carriersCount = allGUIDsCarrier.count;
                
                NSMutableArray *carrierIDsWhichWasUpdated = [NSMutableArray array];
                
                [allGUIDsCarrier enumerateObjectsUsingBlock:^(NSString *carrierGUID, NSUInteger idx, BOOL *stop) {        
                    // carrier update start
                    NSError *error = nil;
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc];
                    [fetchRequest setEntity:entity];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",carrierGUID];
                    [fetchRequest setPredicate:predicate];
                    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
                    Carrier *carrier = fetchedObjects.lastObject;
                    [fetchRequest release];
                    
                    [carrierIDsWhichWasUpdated addObject:carrier.objectID];
                    
                    NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:carriersCount] doubleValue]];
                    [self updateUIwithMessage:[NSString stringWithFormat:@"carrier data progress:%@",carrier.name] andProgressPercent:percentDone withObjectID:nil];
                    NSLog(@"CLIENT CONTROLLER:>>>>>>> carrier start update:%@",carrier.name);
                    if (isIncludeCarrierSubentities) [self updateLocalGraphFromSnowEnterpriseServerForCarrierID:carrier.objectID withDateFrom:dateFrom withDateTo:dateTo withAdmin:admin];
/*                    //////////////////////////////// FOR SALE BLOCK 
                    NSArray *allGUIDsForSale = [self getAllObjectsListWithEntityForList:@"DestinationsListForSale" withMainObjectGUID:carrier.GUID withMainObjectEntity:@"Carrier" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                    NSArray *allObjectsForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsForSale withEntity:@"DestinationsListForSale" withAdmin:admin];
                    if (allGUIDsForSale && allObjectsForGUIDS) {
                        
                        NSArray *updatedForSaleIDs = [self updateGraphForObjects:allObjectsForGUIDS withEntity:@"DestinationsListForSale" withAdmin:admin withRootObject:carrier  isEveryTenPercentSave:NO];
                        [self finalSave:moc];
                        
                        NSUInteger forSaleCount = allGUIDsForSale.count;
                        
                        [allGUIDsForSale enumerateObjectsUsingBlock:^(NSString *forSaleGUID, NSUInteger idx, BOOL *stop) {
                            // for sale update start
                            NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:forSaleCount] doubleValue]];
                            [self updateUIwithMessage:@"progress for destinations for sale" andProgressPercent:percentDone withObjectID:nil];
                            
                            NSError *error = nil;
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                            NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListForSale" inManagedObjectContext:self.moc];
                            [fetchRequest setEntity:entity];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",forSaleGUID];
                            [fetchRequest setPredicate:predicate];
                            NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
                            DestinationsListForSale *findedDestination = fetchedObjects.lastObject;
                            [fetchRequest release];
                            
                            if (findedDestination) {
                                //////////////////////////////// CODES BLOCK 
                                NSArray *allGUIDsCodes = [self getAllObjectsListWithEntityForList:@"CodesvsDestinationsList" withMainObjectGUID:findedDestination.GUID withMainObjectEntity:@"DestinationsListForSale" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                                NSArray *allObjectsCodesForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsCodes withEntity:@"CodesvsDestinationsList" withAdmin:admin];
                                if (allGUIDsCodes && allObjectsCodesForGUIDS) {
                                    __block NSArray *updatedCodesIDs = [self updateGraphForObjects:allObjectsCodesForGUIDS withEntity:@"CodesvsDestinationsList" withAdmin:admin withRootObject:findedDestination  isEveryTenPercentSave:NO];
                                    [self finalSave:moc];
                                    NSSet *currentCodes = findedDestination.codesvsDestinationsList;
                                    // remove objects which was not on server
                                    [currentCodes enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, BOOL *stop) {
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",code.GUID];
                                        NSArray *filteredCodesIDs = [updatedCodesIDs filteredArrayUsingPredicate:predicate];
                                        if (filteredCodesIDs.count == 0) {
                                            [moc deleteObject:code];
                                            NSLog(@"CLIENT CONTROLLER: >>>>>>> code:%@ country:%@ specific:%@ not on server and will removed",code.code,code.country,code.specific);
                                        }
                                    }];
                                }
                                //////////////////////////////// PER HOUR STAT BLOCK 
                                NSArray *allGUIDsPerHour = [self getAllObjectsListWithEntityForList:@"DestinationPerHourStat" withMainObjectGUID:findedDestination.GUID withMainObjectEntity:@"DestinationsListForSale" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                                NSArray *allObjectsPerHourForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsPerHour withEntity:@"DestinationPerHourStat" withAdmin:admin];
                                if (allGUIDsPerHour && allObjectsPerHourForGUIDS) {
                                    
                                    NSArray *updatedPerHourIDs = [self updateGraphForObjects:allObjectsPerHourForGUIDS withEntity:@"DestinationPerHourStat" withAdmin:admin withRootObject:findedDestination  isEveryTenPercentSave:NO];
                                    [self finalSave:moc];
                                    // remove objects which was not on server
                                    NSSet *currentPerHourStat = findedDestination.destinationPerHourStat;
                                    [currentPerHourStat enumerateObjectsUsingBlock:^(DestinationPerHourStat *perHour, BOOL *stop) {
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",perHour.GUID];
                                        NSArray *filteredPerHourIDs = [updatedPerHourIDs filteredArrayUsingPredicate:predicate];
                                        if (filteredPerHourIDs.count == 0) {
                                            [moc deleteObject:perHour];
                                            NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",perHour.entity.name);
                                        }
                                    }];
                                }
                            } else NSLog(@"CLIENT CONTROLLER: warning destinations for sale NOT FOUND for guid:%@",forSaleGUID);
                        }];
                        // remove objects which was not on server
                        NSSet *allDestinationsForSale = carrier.destinationsListForSale;
                        [allDestinationsForSale enumerateObjectsUsingBlock:^(DestinationsListForSale *destination, BOOL *stop) {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",destination.GUID];
                            NSArray *filteredForSaleIDs = [updatedForSaleIDs filteredArrayUsingPredicate:predicate];
                            if (filteredForSaleIDs.count == 0) {
                                [moc deleteObject:destination];
                                NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",destination.entity.name);
                            }
                        }];
                    }
                    /////////////////////////////// WE BUY BLOCK 
                    NSArray *allGUIDsWeBuy = [self getAllObjectsListWithEntityForList:@"DestinationsListWeBuy" withMainObjectGUID:carrier.GUID withMainObjectEntity:@"Carrier" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                    allObjectsForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsWeBuy withEntity:@"DestinationsListWeBuy" withAdmin:admin];
                    if (allGUIDsWeBuy && allObjectsForGUIDS) {
                        
                        NSArray *updatedWeBuyIDs = [self updateGraphForObjects:allObjectsForGUIDS withEntity:@"DestinationsListWeBuy" withAdmin:admin withRootObject:carrier  isEveryTenPercentSave:NO];
                        [self finalSave:moc];
                        NSUInteger weBuyCount = allGUIDsWeBuy.count;
                        
                        [allGUIDsWeBuy enumerateObjectsUsingBlock:^(NSString *weBuyGUID, NSUInteger idx, BOOL *stop) {
                            NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:weBuyCount] doubleValue]];
                            [self updateUIwithMessage:@"progress for destinations we buy" andProgressPercent:percentDone withObjectID:nil];
                            NSError *error = nil;
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                            
                            NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuy" inManagedObjectContext:self.moc];
                            [fetchRequest setEntity:entity];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",weBuyGUID];
                            [fetchRequest setPredicate:predicate];
                            NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
                            DestinationsListWeBuy *findedDestination = fetchedObjects.lastObject;
                            [fetchRequest release];
                            
                            if (findedDestination) {
                                //////////////////////////////// CODES BLOCK 
                                NSArray *allGUIDsCodes = [self getAllObjectsListWithEntityForList:@"CodesvsDestinationsList" withMainObjectGUID:findedDestination.GUID withMainObjectEntity:@"DestinationsListForSale" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                                NSArray *allObjectsCodesForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsCodes withEntity:@"CodesvsDestinationsList" withAdmin:admin];
                                if (allGUIDsCodes && allObjectsCodesForGUIDS) {
                                    __block NSArray *updatedCodesIDs = [self updateGraphForObjects:allObjectsCodesForGUIDS withEntity:@"CodesvsDestinationsList" withAdmin:admin withRootObject:findedDestination  isEveryTenPercentSave:NO];
                                    [self finalSave:moc];
                                    NSSet *currentCodes = findedDestination.codesvsDestinationsList;
                                    // remove objects which was not on server
                                    [currentCodes enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, BOOL *stop) {
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",code.GUID];
                                        NSArray *filteredCodesIDs = [updatedCodesIDs filteredArrayUsingPredicate:predicate];
                                        if (filteredCodesIDs.count == 0) {
                                            [moc deleteObject:code];
                                            NSLog(@"CLIENT CONTROLLER: >>>>>>> code:%@ country:%@ specific:%@ not on server and will removed",code.code,code.country,code.specific);
                                        }
                                    }];
                                }
                                //////////////////////////////// PER HOUR STAT BLOCK 
                                NSArray *allGUIDsPerHour = [self getAllObjectsListWithEntityForList:@"DestinationPerHourStat" withMainObjectGUID:findedDestination.GUID withMainObjectEntity:@"DestinationsListForSale" withAdmin:admin withDateFrom:dateFrom withDateTo:dateTo];
                                NSArray *allObjectsPerHourForGUIDS = [self getAllObjectsListWithGUIDs:allGUIDsPerHour withEntity:@"DestinationPerHourStat" withAdmin:admin];
                                if (allGUIDsPerHour && allObjectsPerHourForGUIDS) {
                                    
                                    NSArray *updatedPerHourIDs = [self updateGraphForObjects:allObjectsPerHourForGUIDS withEntity:@"DestinationPerHourStat" withAdmin:admin withRootObject:findedDestination  isEveryTenPercentSave:NO];
                                    [self finalSave:moc];
                                    // remove objects which was not on server
                                    NSSet *currentPerHourStat = findedDestination.destinationPerHourStat;
                                    [currentPerHourStat enumerateObjectsUsingBlock:^(DestinationPerHourStat *perHour, BOOL *stop) {
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",perHour.GUID];
                                        NSArray *filteredPerHourIDs = [updatedPerHourIDs filteredArrayUsingPredicate:predicate];
                                        if (filteredPerHourIDs.count == 0) {
                                            [moc deleteObject:perHour];
                                            NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",perHour.entity.name);
                                        }
                                    }];
                                }
                                
                            } else NSLog(@"CLIENT CONTROLLER: warning destinations we buy NOT FOUND for guid:%@",weBuyGUID);
                        }];
                        // remove objects which was not on server
                        NSSet *allDestinationsWeBuy = carrier.destinationsListWeBuy;
                        [allDestinationsWeBuy enumerateObjectsUsingBlock:^(DestinationsListWeBuy *destination, BOOL *stop) {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",destination.GUID];
                            NSArray *filteredWeBuyIDs = [updatedWeBuyIDs filteredArrayUsingPredicate:predicate];
                            if (filteredWeBuyIDs.count == 0) {
                                [moc deleteObject:destination];
                                NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",destination.entity.name);
                            }
                        }];
                    }
 */                   
                }];
                // remove objects which was not on server
                NSSet *allCarriers = stuff.carrier;
                [allCarriers enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",carrier.GUID];
                    NSArray *filteredCarrierIDs = [updatedCarrierIDs filteredArrayUsingPredicate:predicate];
                    if (filteredCarrierIDs.count == 0) {
                        [moc deleteObject:carrier];
                        NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",carrier.entity.name);
                    }
                }];
            }
        }];
        
        // remove objects which was not on server
        NSSet *allStuff = currentCompany.companyStuff;
        [allStuff enumerateObjectsUsingBlock:^(CompanyStuff *stuff, BOOL *stop) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",stuff.GUID];
            NSArray *filteredStuffIDs = [updatedStuffIDs filteredArrayUsingPredicate:predicate];
            if (filteredStuffIDs.count == 0) {
                [moc deleteObject:stuff];
                NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",stuff.entity.name);
            }
        }];
        [self finalSave:moc];
    }

    
}

#pragma mark -
#pragma mark PutObject methods
-(NSArray *)prepareNecessaryDataForObjectWithID:(NSManagedObjectID *)objectID
{
    NSManagedObject *object = [self.moc objectWithID:objectID];
    NSString *entity = [[objectID entity] name];
    
    NSDictionary *relationShipsByName = [[object entity] relationshipsByName];
    __block NSString *relationShipName = nil;
    [relationShipsByName enumerateKeysAndObjectsUsingBlock:^(id key, NSRelationshipDescription *relationshipDescription, BOOL *stop) {
        if (![relationshipDescription isToMany]) {
            relationShipName = [relationshipDescription name];
        }

    }];

    NSDictionary *rootObjectToAdd = nil;
    if (relationShipName) {
        NSManagedObject *rootObject = [object valueForKey:relationShipName];
        NSString *rootEntity = [[rootObject entity] name];
        NSString *guid = [rootObject valueForKey:@"GUID"];
        rootObjectToAdd = [NSDictionary dictionaryWithObjectsAndKeys:guid,rootEntity, nil];
    }
    
    NSDictionary *objectDictionary = [self dictionaryFromObject:object];
    NSDictionary *objectToAdd = [NSDictionary dictionaryWithObjectsAndKeys:objectDictionary,entity, nil];
    
    return [NSArray arrayWithObjects:objectToAdd,rootObjectToAdd, nil];
}

-(void)putObjectWithTimeoutWithIDs:(NSArray *)objectIDs mustBeApproved:(BOOL)isMustBeApproved;

{
    
    [self updateUIwithMessage:@"put object start" withObjectID:[objectIDs lastObject] withLatestMessage:NO error:NO];

    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    CompanyStuff *admin = [self authorization];
    
    if (!admin) {
        [self updateUIwithMessage:@"Sorry, a main configuration don't created, please wait little time." withObjectID:[objectIDs lastObject] withLatestMessage:YES error:YES];
        return;
    }
    
    NSString *email = admin.email ;
    
    if ([email isEqualToString:@"you@email"]) {
        [self updateUIwithMessage:@"default email not allowed, please start registration." withObjectID:[objectIDs lastObject] withLatestMessage:YES error:YES];
        return;
    }
    
    [prepeareForJSONRequest setValue:admin.email forKey:@"authorizedUserEmail"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"authorizedUserPassword"];
    [prepeareForJSONRequest setValue:[NSNumber numberWithBool:isMustBeApproved] forKey:@"isMustBeApproved"];
    
    NSMutableArray *allObjects = [NSMutableArray array];
    [objectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
        [allObjects addObject:[self prepareNecessaryDataForObjectWithID:objectID]];
    }];

    [prepeareForJSONRequest setValue:allObjects forKey:@"necessaryData"];
    NSLog(@"CLIENT CONTROLLER PutObject Sent:%@ ",prepeareForJSONRequest);

    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"PutObject" withJSONRequest:prepeareForJSONRequest];
    NSLog(@"CLIENT CONTROLLER PutObject Received:%@",receivedObject);
    if (receivedObject) {
        [self updateUIwithMessage:@"put object processing"  withObjectID:[objectIDs lastObject] withLatestMessage:NO error:NO];
        
        
        NSString *error = [[[receivedObject valueForKey:@"result"] lastObject] valueForKey:@"error"];
        if (error) [self updateUIwithMessage:error withObjectID:[objectIDs lastObject] withLatestMessage:YES error:YES];
        else {
            
            // here is handle result
            NSArray *results = [receivedObject valueForKey:@"result"];
            [results enumerateObjectsUsingBlock:^(NSDictionary *result, NSUInteger idx, BOOL *stop) {
                NSString *error = [result valueForKey:@"error"];
                if (!error) {
                    NSManagedObject *updatedObject = [self.moc objectWithID:[objectIDs objectAtIndex:idx]];
                    NSDictionary *status = [NSDictionary dictionaryWithObject:@"registered" forKey:@"update"];
                    NSString *guidForStatus = [updatedObject valueForKey:@"GUID"];
                    if (guidForStatus) [self setUserDefaultsObject:status forKey:guidForStatus];
                    else NSLog(@"CLIENT CONTROLLER: warning, result:%@ don't have GUID to update inside system",result);
                    //NSLog(@"CLIENT CONTROLLER:updated object:%@ for guid:%@ with object:%@",[[NSUserDefaults standardUserDefaults] objectForKey:[updatedObject valueForKey:@"GUID"]],[updatedObject valueForKey:@"GUID"],updatedObject);
                    
                    
                } else {
                    [self updateUIwithMessage:error withObjectID:[objectIDs lastObject] withLatestMessage:NO error:YES];
                    return;
                }
                NSString *operation = [result valueForKey:@"operation"];
                if (!error && [operation isEqualToString:@"login"]) {
                    //NSLog(@"stuff before changes:%@",admin);
                    NSString *objectGUID = [result valueForKey:@"objectGUID"];
                    
                    // bcs we don't have passwords in companies list, but admin's there is presend, we must using password which was using for auth
                    NSString *localPassword = admin.password;
                    CompanyStuff *newAdmin = [self authorization];
                    newAdmin.password = localPassword;
                    
                    //NSLog(@"stuff after changes:%@",[self authorization]);
                    
                    //NSLog(@"CLIENT CONTROLLER: get all objects result:%@",[self getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES]);
                    //[self finalSave:self.moc];
                    NSString *keyAofAuthorized = @"authorizedUserGUID";
                    
#if defined(SNOW_CLIENT_APPSTORE)
                    keyAofAuthorized = @"authorizedUserGUIDclient";
#endif
                    
                    [self setUserDefaultsObject:objectGUID forKey:keyAofAuthorized];
                    
                }
            }];
            [self updateUIwithMessage:@"put object finish" withObjectID:[objectIDs lastObject] withLatestMessage:YES error:NO];
        }
        
        [self finalSave:self.moc];
    } //else [self updateUIwithMessage:@"put object failed" withObjectID:[objectIDs lastObject] withLatestMessage:YES error:YES];
}

#pragma mark -
#pragma mark RemoveObject methods

-(void)removeObjectWithID:(NSManagedObjectID *)objectID;
{
    [self updateUIwithMessage:@"remove object start" withObjectID:objectID withLatestMessage:NO error:NO];
    
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    CompanyStuff *admin = [self authorization];
    [prepeareForJSONRequest setValue:admin.email forKey:@"authorizedUserEmail"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"authorizedUserPassword"];
    NSManagedObject *object = [self.moc objectWithID:objectID];
//    if (object.isFault) {
//        NSLog(@"CLIENT CONTROLLER: warning, object to send is fault't");
//        return;
//    }
    [prepeareForJSONRequest setValue:[object valueForKey:@"GUID"] forKey:@"objectGUID"];
    [prepeareForJSONRequest setValue:[[object entity] name] forKey:@"objectEntity"];
    NSLog(@"CLIENT CONTROLLER RemoveObject Sent:%@",prepeareForJSONRequest);
    
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"RemoveObject" withJSONRequest:prepeareForJSONRequest];
    NSLog(@"CLIENT CONTROLLER RemoveObject Received:%@",receivedObject);
    [self updateUIwithMessage:@"remove object processing"  withObjectID:objectID withLatestMessage:NO error:NO];
    NSString *error = [receivedObject valueForKey:@"error"];
    if (error) { 
        [self updateUIwithMessage:error withObjectID:objectID withLatestMessage:YES error:YES];
    }
    else {
        //NSLog(@"object deleted:%@",[self.moc objectWithID:objectID]);
        //[self.moc deleteObject:[self.moc objectWithID:objectID]];
        [self updateUIwithMessage:@"remove object finish" withObjectID:objectID withLatestMessage:YES error:NO];

    }
    [self finalSave:self.moc];

}



@end
