//
//  MyClass.m
//  snow
//
//  Created by Oleksii Vynogradov on 04.09.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "CurrentCompany.h"
#import "CompanyAccounts.h"
#import "CompanyStuff.h"
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

#import "ServerController.h"
#import "JSONKit.h"
static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };


//@interface ServerController()
//
//
//
//@end


@implementation ServerController

@synthesize moc,delegate;

- (id)init
{
    self = [super init];
    if (self) {
        delegate = (desctopDelegate *)[[NSApplication sharedApplication] delegate];
        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        //[moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        //[moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];

        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
    [moc release];

    [super dealloc];
    
}
- (void)importerDidSave:(NSNotification *)saveNotification {
    NSManagedObjectContext *mainMoc = [delegate managedObjectContext];
    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                              withObject:saveNotification
                           waitUntilDone:NO];

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
            continue;
        } 
        
        [object setValue:obj forKey:key];
    }
    [formatter release];
}


-(NSDictionary *) clearNullKeysForDictionary:(NSDictionary *)dictionary
{
    __block NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //NSLog(@"clearance was start:%@ for class:%@",obj,NSStringFromClass([obj class]));

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

// BLOCK RECURSIVE START
-(NSDictionary *)forDestinationsListForSale:(DestinationsListForSale *)destinationForSale;
{
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    [finalData addEntriesFromDictionary:[self dictionaryFromObject:destinationForSale]];
    
    NSSet *destinationForSaleCodesList = destinationForSale.codesvsDestinationsList;
    NSMutableArray *allDestinationsListWeBuyCodesList = [NSMutableArray array];
    [destinationForSaleCodesList enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, BOOL *stop) {
        [allDestinationsListWeBuyCodesList addObject:[self dictionaryFromObject:code]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allDestinationsListWeBuyCodesList] forKey:@"codesvsDestinationsList"];
        
    return finalData;

}

-(NSDictionary *)forDestinationsListWeBuyTesting:(DestinationsListWeBuyTesting *)destinationsListWeBuyTesting;
{
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    [finalData addEntriesFromDictionary:[self dictionaryFromObject:destinationsListWeBuyTesting]];
    
    NSSet *destinationsListWeBuyResults = destinationsListWeBuyTesting.destinationsListWeBuyResults;
    NSMutableArray *allDestinationsListWeBuyResults = [NSMutableArray array];
    [destinationsListWeBuyResults enumerateObjectsUsingBlock:^(DestinationsListWeBuyResults *result, BOOL *stop) {
        [allDestinationsListWeBuyResults addObject:[self dictionaryFromObject:result]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allDestinationsListWeBuyResults] forKey:@"destinationsListWeBuyResults"];
    
    return finalData;

}

-(NSDictionary *)forDestinationsListWeBuy:(DestinationsListWeBuy *)destinationsListWeBuy;
{
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    [finalData addEntriesFromDictionary:[self dictionaryFromObject:destinationsListWeBuy]];
    
    NSSet *destinationsListWeBuyCodesList = destinationsListWeBuy.codesvsDestinationsList;
    NSMutableArray *alldestinationsListWeBuyCodesList = [NSMutableArray array];
    [destinationsListWeBuyCodesList enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, BOOL *stop) {
        [alldestinationsListWeBuyCodesList addObject:[self dictionaryFromObject:code]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:alldestinationsListWeBuyCodesList] forKey:@"codesvsDestinationsList"];
    
    NSSet *destinationsListWeBuyTesting = destinationsListWeBuy.destinationsListWeBuyTesting;
    NSMutableArray *alldestinationsListWeBuyTesting = [NSMutableArray array];
    [destinationsListWeBuyTesting enumerateObjectsUsingBlock:^(DestinationsListWeBuyTesting *testing, BOOL *stop) {
        [alldestinationsListWeBuyTesting addObject:[self forDestinationsListWeBuyTesting:testing]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:alldestinationsListWeBuyTesting] forKey:@"destinationsListWeBuyTesting"];
    
    return finalData;
    
}

-(NSDictionary *)forDestinationsListTargets:(DestinationsListTargets *)destinationTarget;
{
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    [finalData addEntriesFromDictionary:[self dictionaryFromObject:destinationTarget]];
    
    NSSet *destinationTargetCodesList = destinationTarget.codesvsDestinationsList;
    NSMutableArray *allDestinationTargetCodesList = [NSMutableArray array];
    [destinationTargetCodesList enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, BOOL *stop) {
        [allDestinationTargetCodesList addObject:[self dictionaryFromObject:code]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allDestinationTargetCodesList] forKey:@"codesvsDestinationsList"];
    
    return finalData;
    
}
-(NSDictionary *)forInvoicesAndPayments:(InvoicesAndPayments *)invoicesAndPayments;
{
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    [finalData addEntriesFromDictionary:[self dictionaryFromObject:invoicesAndPayments]];
    
    CompanyStuff *stuff = invoicesAndPayments.companyStuff;
//    NSMutableArray *allinvoiceAndPayments = [NSMutableArray array];
//    [allinvoiceAndPayments addObject:[self dictionaryFromObject:stuff]];
    CompanyAccounts *account = invoicesAndPayments.companyAccounts;
    
    [finalData setValue:[NSArray arrayWithObject:[self dictionaryFromObject:stuff]] forKey:@"companyStuff"];
    [finalData setValue:[NSArray arrayWithObject:[self dictionaryFromObject:account]] forKey:@"companyAccounts"];
    
    return finalData;

}

-(NSDictionary *)forFinancial:(Financial *)financial;
{
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    [finalData addEntriesFromDictionary:[self dictionaryFromObject:financial]];
    
    NSSet *invoiceAndPayments = financial.invoicesAndPayments;
    NSMutableArray *allinvoiceAndPayments = [NSMutableArray array];
    [invoiceAndPayments enumerateObjectsUsingBlock:^(InvoicesAndPayments *invoice, BOOL *stop) {
        [allinvoiceAndPayments addObject:[self forInvoicesAndPayments:invoice]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allinvoiceAndPayments] forKey:@"invoiceAndPayments"];
    
    return finalData;
    
}


-(NSDictionary *)forCarrier:(Carrier *)carrier;
{
    NSLog(@"SERVER CONTROLLER: start pack data for carrier:%@",carrier.name);
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    [finalData addEntriesFromDictionary:[self dictionaryFromObject:carrier]];
    
    NSSet *stuffDestinationsPushList = carrier.destinationsListPushList;
    NSMutableArray *allCarrierDestinationsPushList = [NSMutableArray array];
    [stuffDestinationsPushList enumerateObjectsUsingBlock:^(DestinationsListPushList *destinationToAdd, BOOL *stop) {
        [allCarrierDestinationsPushList addObject:[self dictionaryFromObject:destinationToAdd]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allCarrierDestinationsPushList] forKey:@"destinationsListPushList"];
    
    NSSet *carrierStuff = carrier.carrierStuff;
    NSMutableArray *allCarrierStuff = [NSMutableArray array];
    [carrierStuff enumerateObjectsUsingBlock:^(CarrierStuff *stuffToAdd, BOOL *stop) {
        [allCarrierStuff addObject:[self dictionaryFromObject:stuffToAdd]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allCarrierStuff] forKey:@"carrierStuff"];

    NSSet *destinationsListWeBuy = carrier.destinationsListWeBuy;
    NSMutableArray *alldestinationsListWeBuy = [NSMutableArray array];
    [destinationsListWeBuy enumerateObjectsUsingBlock:^(DestinationsListWeBuy *destinationWeBuy, BOOL *stop) {
        [alldestinationsListWeBuy addObject:[self forDestinationsListWeBuy:destinationWeBuy]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:alldestinationsListWeBuy] forKey:@"destinationsListWeBuy"];

    NSSet *destinationsListForSale = carrier.destinationsListForSale;
    NSMutableArray *alldestinationsListForSale = [NSMutableArray array];
    [destinationsListForSale enumerateObjectsUsingBlock:^(DestinationsListForSale *destinationForSale, BOOL *stop) {
        [alldestinationsListForSale addObject:[self forDestinationsListForSale:destinationForSale]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:alldestinationsListForSale] forKey:@"destinationsListForSale"];

    NSSet *destinationsListTargets = carrier.destinationsListTargets;
    NSMutableArray *alldestinationsListTargets = [NSMutableArray array];
    [destinationsListTargets enumerateObjectsUsingBlock:^(DestinationsListTargets *destinationTarget, BOOL *stop) {
        [alldestinationsListTargets addObject:[self forDestinationsListTargets:destinationTarget]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:alldestinationsListTargets] forKey:@"destinationsListTargets"];

    NSSet *financials = carrier.financial;
    NSMutableArray *allfinancials = [NSMutableArray array];
    [financials enumerateObjectsUsingBlock:^(Financial *financial, BOOL *stop) {
        [allfinancials addObject:[self forFinancial:financial]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allfinancials] forKey:@"financial"];

    
    return finalData;
}

-(NSDictionary *) forCompanyStuff:(CompanyStuff *)companyStuff;
{
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    
    //if ([companyStuff.isRegistrationDone boolValue] == YES) {
        [finalData addEntriesFromDictionary:[self dictionaryFromObject:companyStuff]];
        
        NSSet *stuffCarriers = companyStuff.carrier;
        NSMutableArray *allStuffCarriers = [NSMutableArray array];
        [stuffCarriers enumerateObjectsUsingBlock:^(Carrier *carrierToAdd, BOOL *stop) {
            [allStuffCarriers addObject:[self forCarrier:carrierToAdd]];
        }]; 
        [finalData setValue:[NSArray arrayWithArray:allStuffCarriers] forKey:@"carrier"];
    //} else NSLog(@"SERVER CONTROLLER: warning, stuff with email:%@ awaiting registration, return nothing",companyStuff.email);
        
    return finalData;
}

-(NSDictionary *) forOperationsNecessaryToApprove:(OperationNecessaryToApprove *)operation;
{
    return [self dictionaryFromObject:operation];
}

-(NSDictionary *) forCurrentCompany:(CurrentCompany *)company
{
    NSSet *companyStuffs = company.companyStuff;
    NSSet *operationsNecessaryToApprove = company.operationNecessaryToApprove;
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    
    [finalData addEntriesFromDictionary:[self dictionaryFromObject:company]];
    
    NSSet *companyAccounts = company.companyAccounts;

    NSMutableArray *allCompanyAccounts = [NSMutableArray array];
    [companyAccounts enumerateObjectsUsingBlock:^(CompanyAccounts *accountToAdd, BOOL *stop) {
        [allCompanyAccounts addObject:[self dictionaryFromObject:accountToAdd]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allCompanyAccounts] forKey:@"companyAccounts"];
    
    NSMutableArray *allCompanyStuff = [NSMutableArray array];
    [companyStuffs enumerateObjectsUsingBlock:^(CompanyStuff *stuffToAdd, BOOL *stop) {
        [allCompanyStuff addObject:[self forCompanyStuff:stuffToAdd]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allCompanyStuff] forKey:@"companyStuff"];
    
    NSMutableArray *allOperationsNecessaryToApprove = [NSMutableArray array];
    [operationsNecessaryToApprove enumerateObjectsUsingBlock:^(OperationNecessaryToApprove *operationsToAdd, BOOL *stop) {
        [allOperationsNecessaryToApprove addObject:[self forOperationsNecessaryToApprove:operationsToAdd]];
    }]; 
    [finalData setValue:[NSArray arrayWithArray:allOperationsNecessaryToApprove] forKey:@"operationNecessaryToApprove"];
    return finalData;
}
// BLOCK RECURSIVE STOP


//-(NSArray *) createForCompany:(CurrentCompany *)currentCompanyObject;
//{
//    // if u change graph for sync, u must change downloadExternalGraff
//    
//    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    //    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc];
//    //    [fetchRequest setEntity:entity];
//    //    
//    //    NSError *error = nil;
//    //    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
//    //    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
//    //    
//    //    [fetchRequest release];
//    
//    NSMutableArray *clearedCurrentCompany = [NSMutableArray array];
//    
//    //    [fetchedObjects enumerateObjectsWithOptions:NSSortStable usingBlock:^(CurrentCompany *currentCompanyObject, NSUInteger idx, BOOL *stop) {
//    NSMutableDictionary *currentCompany = [NSMutableDictionary dictionary];
//    NSArray *keys = [[[currentCompanyObject entity] attributesByName] allKeys];
//    NSDictionary *dict = [currentCompanyObject dictionaryWithValuesForKeys:keys];
//    //NSLog(@"TEST:%@",[[dict valueForKey:@"GUID"] class]);
//    
//    [currentCompany addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
//    NSSet *companyStuffs = currentCompanyObject.companyStuff;
//    //NSLog(@"companyStuff count is %@",[NSNumber numberWithUnsignedInteger:[companyStuffs count]]);
//    // NSLog(@"currentCompany:%@ have:\n",currentCompanyObject.name);
//    
//    NSMutableArray *clearedCompanyStuff = [NSMutableArray array];
//    [companyStuffs enumerateObjectsWithOptions:NSSortStable usingBlock:^(CompanyStuff *companyStuffObject, BOOL *stop) {
//        NSMutableDictionary *companyStuff = [NSMutableDictionary dictionary];
//        NSArray *keys = [[[companyStuffObject entity] attributesByName] allKeys];
//        NSDictionary *dict = [companyStuffObject dictionaryWithValuesForKeys:keys];
//        [companyStuff addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
//        
//        NSSet *carriers = companyStuffObject.carrier;
//        //NSLog(@"carriers count is %@",[NSNumber numberWithUnsignedInteger:[carriers count]]);
//        //NSLog(@"companyStuffs:email:%@ have:\n",companyStuffObject.email);
//        
//        NSMutableArray *clearedCarriers = [NSMutableArray array];
//        [carriers enumerateObjectsWithOptions:NSSortStable usingBlock:^(Carrier *carrierObject, BOOL *stop) {
//            NSMutableDictionary *carrier = [NSMutableDictionary dictionary];
//            NSArray *keys = [[[carrierObject entity] attributesByName] allKeys];
//            NSDictionary *dict = [carrierObject dictionaryWithValuesForKeys:keys];
//            
//            [carrier addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
//            
//            NSSet *destinationsListPushLists = carrierObject.destinationsListPushList;
//            //NSLog(@"destinationsListTargetss count is %@ for carrier:%@",[NSNumber numberWithUnsignedInteger:[destinationsListTargetss count]],carrierObject.name);
//            //NSLog(@"carrier:%@ have:\n",carrierObject.name);
//            
//            NSMutableArray *clearedDestinationsListPushList = [NSMutableArray array];
//            [destinationsListPushLists enumerateObjectsWithOptions:NSSortStable usingBlock:^(DestinationsListPushList *destinationsListPushListObject, BOOL *stop) {
//                //NSLog(@"DestinationsListPushList:%@/%@\n",destinationsListPushListObject.country,destinationsListPushListObject.specific);
//                
//                NSMutableDictionary *destinationsListPushList = [NSMutableDictionary dictionary];
//                NSArray *keys = [[[destinationsListPushListObject entity] attributesByName] allKeys];
//                NSDictionary *dict = [destinationsListPushListObject dictionaryWithValuesForKeys:keys];
//                [destinationsListPushList addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
//                //NSLog(@"destinationsListTargets %@",destinationsListTargets);
//                [clearedDestinationsListPushList addObject:destinationsListPushList];
//            }];
//            [carrier setValue:[NSArray arrayWithArray:clearedDestinationsListPushList] forKey:@"destinationsListPushList"];
//            [clearedCarriers addObject:carrier];
//        }];
//        [companyStuff setValue:[NSArray arrayWithArray:clearedCarriers] forKey:@"carrier"];
//        [clearedCompanyStuff addObject:[NSDictionary dictionaryWithDictionary:companyStuff]];
//    }];
//    [currentCompany setValue:[NSArray arrayWithArray:clearedCompanyStuff] forKey:@"companyStuff"];
//    [clearedCurrentCompany addObject:[NSDictionary dictionaryWithDictionary:currentCompany]];
//    //NSLog(@"TEST:%@",[[clearedCurrentCompany valueForKey:@"GUID"] class]);
//    //    }];
//    // NSLog(@"%@",clearedCurrentCompany);
//    return [NSArray arrayWithArray:clearedCurrentCompany];
//}
//

-(CompanyStuff *)authorizationForUserEmail:(NSString *)userEmail withPassword:(NSString *)userPassword
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(email == %@) and (password == %@)",userEmail,userPassword];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    
    CompanyStuff *final = [fetchedObjects lastObject];
    return final;
}


#pragma mark -
#pragma mark GetCompaniesList methods

-(NSArray *)createCompaniesList;
{
    __block NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    __block NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    NSMutableArray *clearedCurrentCompanyList = [NSMutableArray array];
    
    [fetchedObjects enumerateObjectsWithOptions:NSSortStable usingBlock:^(CurrentCompany *currentCompanyObject, NSUInteger idx, BOOL *stop) {
        if ([currentCompanyObject.isVisibleForCommunity boolValue] == YES) {
            NSError *error = nil;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carrier.companyStuff.currentCompany == %@",currentCompanyObject];
            entity = [NSEntityDescription entityForName:@"DestinationsListPushList" inManagedObjectContext:self.moc];
            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:predicate];
            NSUInteger result = [self.moc countForFetchRequest:fetchRequest error:&error];
            currentCompanyObject.destinationsPushListCount = [NSNumber numberWithUnsignedInteger:result];
            
            predicate = [NSPredicate predicateWithFormat:@"companyStuff.currentCompany == %@",currentCompanyObject];
            entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc];
            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:predicate];
            result = [self.moc countForFetchRequest:fetchRequest error:&error];
            currentCompanyObject.carriersCount = [NSNumber numberWithUnsignedInteger:result];
            
            predicate = [NSPredicate predicateWithFormat:@"currentCompany == %@",currentCompanyObject];
            entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc];
            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:predicate];
            result = [self.moc countForFetchRequest:fetchRequest error:&error];
            currentCompanyObject.stuffCount = [NSNumber numberWithUnsignedInteger:result];
            
            NSSet *companyStuff = currentCompanyObject.companyStuff;
            NSString *currentCompanyAdminGUID = currentCompanyObject.companyAdminGUID;
            
            
            NSSet *filteredStuff = [companyStuff filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"GUID == %@",currentCompanyAdminGUID]];
            CompanyStuff *admin = [filteredStuff anyObject];
            if (!admin) {
               // NSLog(@"SERVER CONTROLLER: admin not found (can't add) for GUID:%@ and currentStuffs:%@",currentCompanyAdminGUID,companyStuff);
            }
            
            
            NSMutableDictionary *currentCompany = [NSMutableDictionary dictionary];
//            NSArray *keys = [[[currentCompanyObject entity] attributesByName] allKeys];
//            NSDictionary *dict = [currentCompanyObject dictionaryWithValuesForKeys:keys];
            [currentCompany addEntriesFromDictionary:[self clearNullKeysForDictionary:[self dictionaryFromObject:currentCompanyObject]]];
            
            NSMutableDictionary *adminStuff = [NSMutableDictionary dictionary];
            NSArray *keys = [[[admin entity] attributesByName] allKeys];
            NSArray *keysFiltered = [keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != 'password'"]];
            NSDictionary *dict = [admin dictionaryWithValuesForKeys:keysFiltered];
            [adminStuff addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
            
            [currentCompany setValue:adminStuff forKey:@"companyStuff"];
            
            [clearedCurrentCompanyList addObject:currentCompany];
            
            
        } else {
            NSLog(@"SERVER CONTROLLER: company:%@ isVisibleForCommunity == NO",currentCompanyObject.name);
        }
    }];
    [fetchRequest release];
    return clearedCurrentCompanyList;
}

-(NSString *)loginWithEmail:(NSString *)email
               withPassword:(NSString *)password
               withSenderIP:(NSString *)senderIP
             withReceiverIP:(NSString *)receiverIP;
{
    CompanyStuff *user = [self authorizationForUserEmail:email withPassword:password];
    
    NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
    if (user) [finalJSONResult setValue:@"done" forKey:@"result"];
    else  [finalJSONResult setValue:@"failed" forKey:@"result"];
    [finalJSONResult setValue:@"hash" forKey:@"hash"];
    NSDictionary *forJSON = [NSDictionary dictionaryWithDictionary:finalJSONResult];
    NSError *error = nil;
    NSString *jsonStringForReturn = [forJSON JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
    
    return jsonStringForReturn;

}

-(NSString *)getCompaniesListwithSenderIP:(NSString *)senderIP
                           withReceiverIP:(NSString *)receiverIP;
{
    NSArray *companiesList = [self createCompaniesList];
    NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
    [finalJSONResult setValue:companiesList forKey:@"companiesList"];
    [finalJSONResult setValue:@"hash" forKey:@"hash"];
    NSDictionary *forJSON = [NSDictionary dictionaryWithDictionary:finalJSONResult];
    NSError *error = nil;
    NSString *jsonStringForReturn = [forJSON JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
    
    
    return jsonStringForReturn;
}

#pragma mark -
#pragma mark UpdateInternalGraph methods
//-(NSArray *) createMainDataForCompany:(CurrentCompany *)currentCompanyObject;
//{
//    // if u change graph for sync, u must change downloadExternalGraff
//    
//    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    //    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc];
//    //    [fetchRequest setEntity:entity];
//    //    
//    //    NSError *error = nil;
//    //    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
//    //    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
//    //    
//    //    [fetchRequest release];
//    
//    NSMutableArray *clearedCurrentCompany = [NSMutableArray array];
//    
//    //    [fetchedObjects enumerateObjectsWithOptions:NSSortStable usingBlock:^(CurrentCompany *currentCompanyObject, NSUInteger idx, BOOL *stop) {
//    NSMutableDictionary *currentCompany = [NSMutableDictionary dictionary];
//    NSArray *keys = [[[currentCompanyObject entity] attributesByName] allKeys];
//    NSDictionary *dict = [currentCompanyObject dictionaryWithValuesForKeys:keys];
//    //NSLog(@"TEST:%@",[[dict valueForKey:@"GUID"] class]);
//    
//    [currentCompany addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
//    NSSet *companyStuffs = currentCompanyObject.companyStuff;
//    //NSLog(@"companyStuff count is %@",[NSNumber numberWithUnsignedInteger:[companyStuffs count]]);
//    // NSLog(@"currentCompany:%@ have:\n",currentCompanyObject.name);
//    
//    NSMutableArray *clearedCompanyStuff = [NSMutableArray array];
//    [companyStuffs enumerateObjectsWithOptions:NSSortStable usingBlock:^(CompanyStuff *companyStuffObject, BOOL *stop) {
//        NSMutableDictionary *companyStuff = [NSMutableDictionary dictionary];
//        NSArray *keys = [[[companyStuffObject entity] attributesByName] allKeys];
//        NSDictionary *dict = [companyStuffObject dictionaryWithValuesForKeys:keys];
//        [companyStuff addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
//        
//        NSSet *carriers = companyStuffObject.carrier;
//        //NSLog(@"carriers count is %@",[NSNumber numberWithUnsignedInteger:[carriers count]]);
//        //NSLog(@"companyStuffs:email:%@ have:\n",companyStuffObject.email);
//        
//        NSMutableArray *clearedCarriers = [NSMutableArray array];
//        [carriers enumerateObjectsWithOptions:NSSortStable usingBlock:^(Carrier *carrierObject, BOOL *stop) {
//            NSMutableDictionary *carrier = [NSMutableDictionary dictionary];
//            NSArray *keys = [[[carrierObject entity] attributesByName] allKeys];
//            NSDictionary *dict = [carrierObject dictionaryWithValuesForKeys:keys];
//            
//            [carrier addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
//            
//            NSSet *destinationsListPushLists = carrierObject.destinationsListPushList;
//            //NSLog(@"destinationsListTargetss count is %@ for carrier:%@",[NSNumber numberWithUnsignedInteger:[destinationsListTargetss count]],carrierObject.name);
//            //NSLog(@"carrier:%@ have:\n",carrierObject.name);
//            
//            NSMutableArray *clearedDestinationsListPushList = [NSMutableArray array];
//            [destinationsListPushLists enumerateObjectsWithOptions:NSSortStable usingBlock:^(DestinationsListPushList *destinationsListPushListObject, BOOL *stop) {
//                //NSLog(@"DestinationsListPushList:%@/%@\n",destinationsListPushListObject.country,destinationsListPushListObject.specific);
//                
//                NSMutableDictionary *destinationsListPushList = [NSMutableDictionary dictionary];
//                NSArray *keys = [[[destinationsListPushListObject entity] attributesByName] allKeys];
//                NSDictionary *dict = [destinationsListPushListObject dictionaryWithValuesForKeys:keys];
//                [destinationsListPushList addEntriesFromDictionary:[self clearNullKeysForDictionary:dict]];
//                //NSLog(@"destinationsListTargets %@",destinationsListTargets);
//                [clearedDestinationsListPushList addObject:destinationsListPushList];
//            }];
//            [carrier setValue:[NSArray arrayWithArray:clearedDestinationsListPushList] forKey:@"destinationsListPushList"];
//            [clearedCarriers addObject:carrier];
//        }];
//        [companyStuff setValue:[NSArray arrayWithArray:clearedCarriers] forKey:@"carrier"];
//        [clearedCompanyStuff addObject:[NSDictionary dictionaryWithDictionary:companyStuff]];
//    }];
//    [currentCompany setValue:[NSArray arrayWithArray:clearedCompanyStuff] forKey:@"companyStuff"];
//    [clearedCurrentCompany addObject:[NSDictionary dictionaryWithDictionary:currentCompany]];
//    //NSLog(@"TEST:%@",[[clearedCurrentCompany valueForKey:@"GUID"] class]);
//    //    }];
//    // NSLog(@"%@",clearedCurrentCompany);
//    return [NSArray arrayWithArray:clearedCurrentCompany];
//}


-(NSString *)updateInternalGraphForUserEmail:(NSString *)userEmail 
                               withPassword:(NSString *)password                       
                               withSenderIP:(NSString *)senderIP
                             withReceiverIP:(NSString *)receiverIP;
{
    CompanyStuff *stuff = [self authorizationForUserEmail:userEmail withPassword:password];
    if (!stuff) {
        NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
        [finalJSONResult setValue:@"user authorization failed" forKey:@"error"];
        [finalJSONResult setValue:@"hash" forKey:@"hash"];
        NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:NULL];
        return jsonStringForReturn;
    }
    
    CurrentCompany *currentCompany = stuff.currentCompany;
    NSDictionary *mainData = [self forCurrentCompany:currentCompany];
    
    NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
    if (!mainData) [finalJSONResult setValue:@"objects not found" forKey:@"error"];
    else [finalJSONResult setValue:mainData forKey:@"currentCompany"];

    [finalJSONResult setValue:mainData forKey:@"currentCompany"];
    [finalJSONResult setValue:@"hash" forKey:@"hash"];
    NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:NULL];
    return jsonStringForReturn;
    
}
#pragma mark -
#pragma mark GetObjectsWithGUIDs methods
-(NSString *)getObjectsWithGUIDsForUserEmail:(NSString *)userEmail 
                                withPassword:(NSString *)password 
                                  withEntity:(NSString *)entity 
                                   withGUIDs:(NSArray *)guids
                                withSenderIP:(NSString *)senderIP
                              withReceiverIP:(NSString *)receiverIP;
{
    __block NSError *error = nil;
    NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entityFor = [NSEntityDescription entityForName:entity inManagedObjectContext:self.moc];
//    [fetchRequest setResultType:NSDictionaryResultType];
//    NSArray *attributes = entityFor.attributeKeys;
//    NSDictionary *allProperties = entityFor.propertiesByName;
//    NSMutableArray *finalProperties = [NSMutableArray array];
//    [attributes enumerateObjectsUsingBlock:^(NSString *attribute, NSUInteger idx, BOOL *stop) {
//        
//        [finalProperties addObject:[allProperties objectForKey:attribute]];
//    }];
//    [fetchRequest setReturnsDistinctResults:YES];
//    [fetchRequest setPropertiesToFetch:[NSArray arrayWithArray:finalProperties]];
    NSLog(@"SERVER CONTROLLER: guids:%@",guids);
    NSMutableArray *result = [NSMutableArray array];
    //[guids enumerateObjectsUsingBlock:^(NSString *guid, NSUInteger idx, BOOL *stop) 
    for (NSString *guid in guids) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityFor = [NSEntityDescription entityForName:entity inManagedObjectContext:moc];
        [fetchRequest setEntity:entityFor];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",guid];
        [fetchRequest setPredicate:predicate];
        NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        NSManagedObject *resultedObject = fetchedObjects.lastObject;
        //NSDictionary *dictionaryFromObject = [self dictionaryFromObject:resultedObject];
        NSArray *attributes = resultedObject.entity.attributeKeys;
        NSMutableDictionary *finalResult = [NSMutableDictionary dictionary];
        [attributes enumerateObjectsUsingBlock:^(NSString *attribute, NSUInteger idx, BOOL *stop) {
            [finalResult setValue:[resultedObject valueForKey:attribute] forKey:attribute];
        }];
        [result addObject:finalResult];
    }//];
     
    NSData *allArchivedObjects = [NSKeyedArchiver archivedDataWithRootObject:result];
    NSString *stringToPass = [self base64EncodingData:allArchivedObjects];

    [finalJSONResult setValue:stringToPass forKey:@"objects"];
    
    NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
    if (error) NSLog(@"SERVER CONTROLLER: GetObjectsWithGUIDs archive error:%@",[error localizedDescription]);
    return jsonStringForReturn;

}

#pragma mark -
#pragma mark GetObjectsList methods

-(NSString *)getObjectsListForUserEmail:(NSString *)userEmail 
                           withPassword:(NSString *)password 
                      withEntityForList:(NSString *)entityForList 
                     withMainObjectGUID:(NSString *)mainObjectGUID
                   withMainObjectEntity:(NSString *)mainObjectEntity
                           withDateFrom:(NSDate *)dateFrom
                             withDateTo:(NSDate *)dateTo
                           withSenderIP:(NSString *)senderIP
                         withReceiverIP:(NSString *)receiverIP;
{
    NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:mainObjectEntity inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = nil;
    if (dateFrom && dateTo) predicate = [NSPredicate predicateWithFormat:@"(GUID == %@) AND (modificationDate > %@) AND (modificationDate < %@)",mainObjectGUID,dateFrom,dateTo];
    else predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",mainObjectGUID];

    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    if (fetchedObjects.count > 0) {
        NSManagedObject *findedObject = fetchedObjects.lastObject;
        NSEntityDescription *entityDescr = findedObject.entity;
        NSDictionary *relationships = entityDescr.relationshipsByName;
        __block BOOL isEntityForListFound = NO;
        __block NSEntityDescription *destinationEntity = nil;
        __block NSString *relationshipNameForEntity = nil;
        
        [relationships enumerateKeysAndObjectsUsingBlock:^(NSString *relationshipName, NSRelationshipDescription *desc, BOOL *stop) {
            
            if ([desc.destinationEntity.name isEqualToString:entityForList]) {
                isEntityForListFound = YES;
                destinationEntity = desc.destinationEntity;
                relationshipNameForEntity = desc.inverseRelationship.name;
                *stop = YES;
            }
        }];
        
        if (destinationEntity) {
            [fetchRequest setEntity:destinationEntity];
            predicate = [NSPredicate predicateWithFormat:@"(%K == %@)",relationshipNameForEntity,findedObject];
            [fetchRequest setPredicate:predicate];
            [fetchRequest setResultType:NSDictionaryResultType];
            [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"GUID"]];
            fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
            NSMutableArray *allGUIDs = [NSMutableArray array];
            [fetchedObjects enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
                [allGUIDs addObject:[row valueForKey:@"GUID"]];
            }];
             
            [finalJSONResult setValue:allGUIDs forKey:@"allGUIDs"];
        } else [finalJSONResult setValue:@"destination entity not found" forKey:@"error"];
        
    } else [finalJSONResult setValue:@"main object not found" forKey:@"error"];
    
    
    [fetchRequest release];

    
    NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
    if (error) NSLog(@"SERVER CONTROLLER: GetObjectsList archive error:%@",[error localizedDescription]);
    return jsonStringForReturn;
    
}



#pragma mark -
#pragma mark GetObjects methods

-(NSDictionary *)getObjectWithGUID:(NSString *)guid 
                         andEntity:(NSString *)entityName 
                          andStuff:(CompanyStuff *)stuff
             includeAllSubentities:(BOOL)isIncludeAllSubentities;
{
    if (!stuff) return nil;
    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
    //    [fetchRequest setEntity:entity];
    //
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",guid];
    //    [fetchRequest setPredicate:predicate];
    //    
    //    NSError *error = nil;
    //    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    //    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    //    [fetchRequest release];
    
    if ([entityName isEqualToString:@"CurrentCompany"]) {
        //        CurrentCompany *findedCompany = [fetchedObjects lastObject];
        CurrentCompany *findedCompany = stuff.currentCompany;
        
        if (isIncludeAllSubentities) {
            NSDictionary *mainData = [self forCurrentCompany:findedCompany];
            return mainData;
        } else {
            return [self dictionaryFromObject:findedCompany];
        }
    }
    
    if ([entityName isEqualToString:@"CompanyStuff"]) {
        //        CompanyStuff *findedStuff = [fetchedObjects lastObject];
        CompanyStuff *findedStuff = stuff;
        
        if (isIncludeAllSubentities) {
            NSDictionary *mainData = [self forCompanyStuff:findedStuff];
            return mainData;
            
        } else {
            return [self dictionaryFromObject:findedStuff];
        }
    }
    
    if ([entityName isEqualToString:@"Carrier"]) {
        //        Carrier *findedCarrier = [fetchedObjects lastObject];
        NSSet *carriers = stuff.carrier;
        NSSet *filteredCarriers = [carriers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"GUID == %@",guid]];
        Carrier *findedCarrier = [filteredCarriers anyObject];
        if (!findedCarrier) {
            NSLog(@"SERVER CONTROLLER:really sorry, carrier not found");
            return nil;
            
        }
        if (isIncludeAllSubentities) {
            NSDictionary *mainData = [self forCarrier:findedCarrier];
            return mainData;
            
        } else {
            return [self dictionaryFromObject:findedCarrier];
        }
    }
    
    if ([entityName isEqualToString:@"DestinationsListPushList"]) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",guid];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        DestinationsListPushList *findedDestination = [fetchedObjects lastObject];
        if (!findedDestination) {
            NSLog(@"SERVER CONTROLLER:really sorry, destination not found");
            return nil;
            
        }
        
        if (isIncludeAllSubentities) {
            return [self dictionaryFromObject:findedDestination];
            
        } else {
            return [self dictionaryFromObject:findedDestination];
        }
    }
    return nil;
}

-(NSArray *)getAllObjectsforEntity:(NSString *)entityName 
                          andStuff:(CompanyStuff *)stuff;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    [fetchRequest release];
    
    
    if ([entityName isEqualToString:@"Events"]) {
        NSDate *currentDate = [NSDate date];
        NSDate *twoWeeksFromCurrentDate = [NSDate dateWithTimeIntervalSinceNow:+1209600];
        NSArray *filteredEvents = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(date > %@) AND (date < %@)",currentDate,twoWeeksFromCurrentDate]];
       if ([filteredEvents count] == 0) {
           NSLog(@"SERVER CONTROLLER:really sorry, request not from correct stuff:");
           return nil;
       } else
       {
           NSMutableArray *finalEvents = [NSMutableArray array];
           
           [filteredEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               NSArray *keys = [[[obj entity] attributesByName] allKeys];
               NSDictionary *dict = [obj dictionaryWithValuesForKeys:keys];
               [finalEvents addObject:[self clearNullKeysForDictionary:dict]];
           }];
           return [NSArray arrayWithArray:finalEvents];
       }
   }                                  
       
                                   
                                   
   if ([entityName isEqualToString:@"CurrentCompany"]) {
                                       // for CompanyStuff u can receive list only for subentities of stuff
        return nil;
    }
    
    if ([entityName isEqualToString:@"CompanyStuff"]) {
        // for CompanyStuff u can receive list only for subentities of stuff
        return nil;
    }
    
    if ([entityName isEqualToString:@"Carrier"]) {

        NSArray *filteredCarriers = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"companyStuff.GUID == %@",stuff.GUID]];
        if ([filteredCarriers count] == 0) {
            NSLog(@"SERVER CONTROLLER:really sorry, request not from correct stuff:");
            return nil;
        } else
        {
            NSMutableArray *finalCarriers = [NSMutableArray array];
            
            [filteredCarriers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *keys = [[[obj entity] attributesByName] allKeys];
                NSDictionary *dict = [obj dictionaryWithValuesForKeys:keys];
                [finalCarriers addObject:[self clearNullKeysForDictionary:dict]];
            }];
            return [NSArray arrayWithArray:finalCarriers];
        }
    }
    
    if ([entityName isEqualToString:@"DestinationsListPushList"]) {
        NSArray *filteredDestinations = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"carrier.companyStuff.GUID == %@",stuff.GUID]];
        if ([filteredDestinations count] == 0) {
            NSLog(@"SERVER CONTROLLER:really sorry, request not from correct stuff:");
            return nil;
        } else
        {
            NSMutableArray *finalDestinations = [NSMutableArray array];
            
            [filteredDestinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *keys = [[[obj entity] attributesByName] allKeys];
                NSDictionary *dict = [obj dictionaryWithValuesForKeys:keys];
                [finalDestinations addObject:[self clearNullKeysForDictionary:dict]];
            }];
            return [NSArray arrayWithArray:finalDestinations];
        }
    }
    
    if ([entityName isEqualToString:@"OperationNecessaryToApprove"]) {
        NSArray *filteredOperations = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"currentCompany.GUID == %@",stuff.currentCompany.GUID]];
        
        if ([filteredOperations count] == 0) {
            NSLog(@"SERVER CONTROLLER:really sorry, request not from correct stuff:");
            return nil;
        } else
        {
            NSMutableArray *finalOperations = [NSMutableArray array];
            
            [filteredOperations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *keys = [[[obj entity] attributesByName] allKeys];
                NSDictionary *dict = [obj dictionaryWithValuesForKeys:keys];
                [finalOperations addObject:[self clearNullKeysForDictionary:dict]];
            }];
            return [NSArray arrayWithArray:finalOperations];
        }
    }

    
    return nil;
}


-(NSString *)getObjectsForUserEmail:(NSString *)userEmail 
                      withPassword:(NSString *)password 
                     forObjectGUID:(NSString *)objectGUID
                   forObjectEntity:(NSString *)objectEntity 
         withIncludeAllSubentities:(BOOL)isIncludeAllSubentities
             withIncludeAllObjects:(BOOL)isIncludeAllObjects
                      withSenderIP:(NSString *)senderIP
                    withReceiverIP:(NSString *)receiverIP;
{
    if ([objectEntity isEqualToString:@"Events"]) {
        NSArray *allObjects = [self getAllObjectsforEntity:objectEntity andStuff:nil];
        NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
        NSData *allArchivedObjects = [NSKeyedArchiver archivedDataWithRootObject:allObjects];
        NSString *stringToPass = [self base64EncodingData:allArchivedObjects];

        
        if (!stringToPass) [finalJSONResult setValue:@"objects not found or can't decode" forKey:@"error"];
        else [finalJSONResult setValue:stringToPass forKey:@"objects"];
        //[stringToPass release];

        [finalJSONResult setValue:@"hash" forKey:@"hash"];
        NSError *error = nil;
        NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
        if (error) NSLog(@"SERVER CONTROLLER: get all objects error:%@",[error localizedDescription]);
        return jsonStringForReturn;
    }

    CompanyStuff *stuff = [self authorizationForUserEmail:userEmail withPassword:password];
    if (!stuff) {
        NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
        [finalJSONResult setValue:@"user authorization failed" forKey:@"error"];
        [finalJSONResult setValue:@"hash" forKey:@"hash"];
        NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:NULL];
        return jsonStringForReturn;
    }
    // it's just to make modification date for latest login
    stuff.toIP = receiverIP;
    stuff.fromIP = senderIP;
    [self finalSave:moc];
    //NSLog(@"SERVER CONTROLLER: updated:%@",stuff);
    
    if (isIncludeAllObjects) {
        NSArray *allObjects = [self getAllObjectsforEntity:objectEntity andStuff:stuff];
        NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
        NSData *allArchivedObjects = [NSKeyedArchiver archivedDataWithRootObject:allObjects];
        NSString *stringToPass = [self base64EncodingData:allArchivedObjects];

        if (!stringToPass) [finalJSONResult setValue:@"objects not found or can't archive" forKey:@"error"];
        else [finalJSONResult setValue:stringToPass forKey:@"objects"];
        [finalJSONResult setValue:@"hash" forKey:@"hash"];
        NSError *error = nil;
        NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
        if (error) NSLog(@"SERVER CONTROLLER: get all objects error:%@",[error localizedDescription]);
        return jsonStringForReturn;
    }
    
    if (isIncludeAllSubentities) {
        
        NSDictionary *objectData = [self getObjectWithGUID:objectGUID andEntity:objectEntity andStuff:stuff includeAllSubentities:YES];
        NSData *allArchivedObjects = [NSKeyedArchiver archivedDataWithRootObject:objectData];
        NSString *stringToPass = [self base64EncodingData:allArchivedObjects];

        NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
        if (!objectData) [finalJSONResult setValue:@"objects not found or can't archived" forKey:@"error"];
        else [finalJSONResult setValue:stringToPass forKey:@"objects"];
        [finalJSONResult setValue:@"hash" forKey:@"hash"];
        NSError *error = nil;
        NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
        if (error) NSLog(@"SERVER CONTROLLER: get all objects include subentities error:%@",[error localizedDescription]);
        return jsonStringForReturn;
    }

    NSDictionary *objectData = [self getObjectWithGUID:objectGUID andEntity:objectEntity andStuff:stuff includeAllSubentities:NO];
    
    NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
    if (!objectData) [finalJSONResult setValue:@"objects not found" forKey:@"error"];
    else [finalJSONResult setValue:objectData forKey:@"objects"];
    [finalJSONResult setValue:@"hash" forKey:@"hash"];
    NSError *error = nil;
    NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:&error];
    if (error) NSLog(@"SERVER CONTROLLER: get objects error:%@",[error localizedDescription]);
    return jsonStringForReturn;

}

#pragma mark -
#pragma mark PutObject methods
-(NSManagedObject *)objectForGUID:(NSString *)objectGUID forEntityName:(NSString *)entityName;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    if ([fetchedObjects count] == 1) return [fetchedObjects lastObject];
    else { 
        NSLog(@"SERVER CONTROLLER:%@ with GUID:%@ have more than one record",entityName,objectGUID);
        return [fetchedObjects lastObject];;
    }
}

-(NSDictionary *)processObject:(NSDictionary *)object 
                withRootObject:(NSDictionary *)rootObject 
                      forStuff:(CompanyStuff *)stuff 
                mustBeApproved:(BOOL)isMustBeApproved;
{
    
    NSArray *allKeys = [object allKeys];
    NSString *entityName = [allKeys lastObject];
    NSString *objectGUID = [[object valueForKey:entityName] valueForKey:@"GUID"];

    NSString *rootObjectEntityName = nil;
    NSString *rootObjectGUID = nil;
    
    if (rootObject) { 
        allKeys = [rootObject allKeys];
        rootObjectEntityName = [allKeys lastObject];
        rootObjectGUID = [rootObject valueForKey:rootObjectEntityName];
    }
    
    if ([entityName isEqualToString:@"CurrentCompany"]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        if ([fetchedObjects count] == 0) { 
            CurrentCompany *newCompany = (CurrentCompany *)[NSEntityDescription 
                                                            insertNewObjectForEntityForName:@"CurrentCompany" 
                                                            inManagedObjectContext:self.moc];
            newCompany.companyAdminGUID = stuff.GUID;
            stuff.currentCompany = newCompany;
            [self setValuesFromDictionary:[object valueForKey:entityName] anObject:newCompany];

            NSLog(@"SERVER CONTROLLER:new company:%@",newCompany.name);
            return [NSDictionary dictionaryWithObjectsAndKeys:@"new",@"operation",objectGUID,@"objectGUID",nil];
        } else if ([fetchedObjects count] == 1) { 

            CurrentCompany *findedCompany = [fetchedObjects lastObject];
            NSLog(@"SERVER CONTROLLER:updated company:%@",findedCompany.name);

            if ([stuff.GUID isEqualToString:findedCompany.companyAdminGUID]) {
                [self setValuesFromDictionary:[object valueForKey:entityName] anObject:findedCompany];
//                NSLog(@"SERVER CONTROLLER:updated company:%@",findedCompany.name);
                return [NSDictionary dictionaryWithObjectsAndKeys:@"updated",@"operation",nil];
            } else return [NSDictionary dictionaryWithObjectsAndKeys:@"you are not admin",@"error",objectGUID,@"objectGUID",nil];
            
            return [NSDictionary dictionaryWithObjectsAndKeys:@"updated",@"operation",nil];

        }  else return [NSDictionary dictionaryWithObjectsAndKeys:@"company have more than 2 records",@"error",objectGUID,@"objectGUID",nil];;
    }
    
    if ([entityName isEqualToString:@"CompanyStuff"]) {
        //if (!stuff) {
        NSDictionary *fullStuffInfo = [object valueForKey:entityName];
        NSString *email = [fullStuffInfo valueForKey:@"email"];
        if ([email isEqualToString:@"you@email"]) return [NSDictionary dictionaryWithObjectsAndKeys:@"default email not allowed for registration",@"error",objectGUID,@"objectGUID",nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        CurrentCompany *rootCompany = nil;
        if (stuff) rootCompany = stuff.currentCompany;
        else rootCompany = (CurrentCompany *)[self objectForGUID:rootObjectGUID forEntityName:rootObjectEntityName];
        
        if ([fetchedObjects count] == 0) {
            if (isMustBeApproved) {
                // this is a join request
                if (rootCompany) {
                    // before register, check if email is present
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
                    [fetchRequest setEntity:entity];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(email == %@)",email];
                    [fetchRequest setPredicate:predicate];
                    NSError *error = nil;
                    NSInteger emails = [self.moc countForFetchRequest:fetchRequest error:&error];
                    [fetchRequest release];
                    if (emails > 0) return [NSDictionary dictionaryWithObjectsAndKeys:@"email already registered",@"error",objectGUID,@"objectGUID",nil];
                    
                    CompanyStuff *newStuff = (CompanyStuff *)[NSEntityDescription 
                                                              insertNewObjectForEntityForName:@"CompanyStuff" 
                                                              inManagedObjectContext:self.moc];
                    
                    newStuff.currentCompany = rootCompany;
                    
                    newStuff.isRegistrationDone = [NSNumber numberWithBool:NO];
                    newStuff.isRegistrationProcessed = [NSNumber numberWithBool:YES];
                    [self setValuesFromDictionary:[object valueForKey:entityName] anObject:newStuff];
                    
                    OperationNecessaryToApprove *newOperation = (OperationNecessaryToApprove *)[NSEntityDescription 
                                                                                                insertNewObjectForEntityForName:@"OperationNecessaryToApprove" 
                                                                                                inManagedObjectContext:self.moc];
                    newOperation.forGUID = objectGUID;
                    newOperation.forEntity = entityName;
                    newOperation.currentCompany = rootCompany;
                    return [NSDictionary dictionaryWithObjectsAndKeys:@"new and waiting for appove",@"result",objectGUID,@"objectGUID",nil];
                } else return [NSDictionary dictionaryWithObjectsAndKeys:@"root company not found for approve",@"result",objectGUID,@"objectGUID",nil];
                
                
            } else { 
                if (stuff) {
                    // this is defenetely login, but login don't same guid in system, first setup need
                    return [NSDictionary dictionaryWithObjectsAndKeys:@"login",@"operation",stuff.GUID,@"objectGUID",nil];
                }
                // before register, check if email is present
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
                [fetchRequest setEntity:entity];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(email contains [cd] %@)",email];
                [fetchRequest setPredicate:predicate];
                NSError *error = nil;
                NSInteger emails = [self.moc countForFetchRequest:fetchRequest error:&error];
                [fetchRequest release];
                if (emails > 0) return [NSDictionary dictionaryWithObjectsAndKeys:@"email already registered",@"error",objectGUID,@"objectGUID",nil];
                if (rootCompany) {

                CompanyStuff *newStuff = (CompanyStuff *)[NSEntityDescription 
                                                          insertNewObjectForEntityForName:@"CompanyStuff" 
                                                          inManagedObjectContext:self.moc];
                newStuff.currentCompany = rootCompany;
                newStuff.isRegistrationDone = [NSNumber numberWithBool:YES];
                [self setValuesFromDictionary:[object valueForKey:entityName] anObject:newStuff];
                
                return [NSDictionary dictionaryWithObjectsAndKeys:@"new",@"operation",objectGUID,@"objectGUID",nil];
                } else return [NSDictionary dictionaryWithObjectsAndKeys:@"root company not found",@"error",objectGUID,@"objectGUID",nil];
            }
        }
        if ([fetchedObjects count] == 1) { 
            if (isMustBeApproved) {
                // in case of existing user are sending request to join, here is a right place:
                if (rootCompany) {
                    
                    stuff.isRegistrationDone = [NSNumber numberWithBool:NO];
                    stuff.isRegistrationProcessed = [NSNumber numberWithBool:YES];
                    stuff.currentCompany = rootCompany;
                    
                    OperationNecessaryToApprove *newOperation = (OperationNecessaryToApprove *)[NSEntityDescription 
                                                                                                insertNewObjectForEntityForName:@"OperationNecessaryToApprove" 
                                                                                                inManagedObjectContext:self.moc];
                    newOperation.forGUID = objectGUID;
                    newOperation.forEntity = entityName;
                    newOperation.currentCompany = rootCompany;
                    return [NSDictionary dictionaryWithObjectsAndKeys:@"registered and waiting for appove",@"result",objectGUID,@"objectGUID",nil];
                } else return [NSDictionary dictionaryWithObjectsAndKeys:@"root company not found for approve",@"result",objectGUID,@"objectGUID",nil];
                
            } else {
                // this is update
                CompanyStuff *findedStuff = [fetchedObjects lastObject];
                [self setValuesFromDictionary:[object valueForKey:entityName] anObject:findedStuff];
                if (![findedStuff.currentCompany.GUID isEqualToString:rootObjectGUID]){
                    // company was changed (may be improved to check if root company must be always connect with server version or not
                    CurrentCompany *rootCompanyForCheck = (CurrentCompany *)[self objectForGUID:rootObjectGUID forEntityName:rootObjectEntityName];
                    if (rootCompanyForCheck) {
                    findedStuff.currentCompany = rootCompanyForCheck;
                    rootCompanyForCheck.companyAdminGUID = findedStuff.GUID;
                    } else return [NSDictionary dictionaryWithObjectsAndKeys:@"root company not found for update",@"result",objectGUID,@"objectGUID",nil];
                }
                if (!stuff) return [NSDictionary dictionaryWithObjectsAndKeys:@"updated",@"operation",objectGUID,@"objectGUID",nil];
                else { 
                    // send login, bcs this is operation to approve, but check before (it may be particular update
                    if ([stuff isEqualTo:findedStuff]) {
                        return [NSDictionary dictionaryWithObjectsAndKeys:@"updated",@"operation",objectGUID,@"objectGUID",nil];
                    }
                    // ok common, this is approving operation, we must remove operationNecessaryToApprove
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OperationNecessaryToApprove" inManagedObjectContext:self.moc];
                    [fetchRequest setEntity:entity];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(forGUID == %@)",findedStuff.GUID];
                    [fetchRequest setPredicate:predicate];
                    NSError *error = nil;
                    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
                    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
                    [fetchRequest release];
                    OperationNecessaryToApprove *operation = [fetchedObjects lastObject];
                    if (!operation) return [NSDictionary dictionaryWithObjectsAndKeys:@"operation processing",@"error",objectGUID,@"objectGUID",nil];
                    [self.moc deleteObject:operation];
                    [self finalSave:self.moc];
                    
                    // and returning login make cause to read all graph oj objects to update system
                    return [NSDictionary dictionaryWithObjectsAndKeys:@"login",@"operation",stuff.GUID,@"objectGUID",nil];
                }
            }
            
            
        } 
        
        return [NSDictionary dictionaryWithObjectsAndKeys:@"stuff have more than 2 records",@"error",objectGUID,@"objectGUID",nil];
        
    }
    
    if ([entityName isEqualToString:@"Carrier"]) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        if ([fetchedObjects count] == 0) { 
            if (stuff) {
                Carrier *newCarrier = (Carrier *)[NSEntityDescription 
                                                  insertNewObjectForEntityForName:@"Carrier" 
                                                  inManagedObjectContext:self.moc];
                newCarrier.companyStuff = stuff;
                [self setValuesFromDictionary:[object valueForKey:entityName] anObject:newCarrier];
                return [NSDictionary dictionaryWithObjectsAndKeys:@"new",@"result",nil];
            } else return [NSDictionary dictionaryWithObjectsAndKeys:@"root stuff not found for new carrier",@"result",objectGUID,@"objectGUID",nil];
        }
        if ([fetchedObjects count] == 1) { 
            Carrier *findedCarrier = [fetchedObjects lastObject];
            
            if ([findedCarrier.companyStuff.GUID isEqualToString:stuff.GUID]) {
                [self setValuesFromDictionary:[object valueForKey:entityName] anObject:findedCarrier];
                return [NSDictionary dictionaryWithObjectsAndKeys:@"updated",@"operation",nil];
            } else return [NSDictionary dictionaryWithObjectsAndKeys:@"you are not owner of this carrier",@"error",objectGUID,@"objectGUID",nil];
        } 
        
        return [NSDictionary dictionaryWithObjectsAndKeys:@"carrier have more than 2 records",@"error",objectGUID,@"objectGUID",nil];;
    }
    
    if ([entityName isEqualToString:@"DestinationsListPushList"]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        //NSLog(@"Fetched object:%@",fetchedObjects);
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        if ([fetchedObjects count] == 0) { 
            // NEW DESTINATION
//            DestinationsListPushList *newDestination = (DestinationsListPushList *)[NSEntityDescription 
//                                                                                    insertNewObjectForEntityForName:@"DestinationsListPushList" 
//                                                                                    inManagedObjectContext:self.moc];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:rootObjectEntityName inManagedObjectContext:self.moc];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",rootObjectGUID];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
            [fetchRequest release];
            if ([fetchedObjects count] == 0) { 
                return [NSDictionary dictionaryWithObjectsAndKeys:@"root carrier not found",@"error",objectGUID,@"objectGUID",nil];;
            }
            if ([fetchedObjects count] == 1) { 
                Carrier *findedCarrier = [fetchedObjects lastObject];
                if (findedCarrier) {
                    DestinationsListPushList *newDestination = (DestinationsListPushList *)[NSEntityDescription 
                                                                                            insertNewObjectForEntityForName:@"DestinationsListPushList" 
                                                                                            inManagedObjectContext:self.moc];
                    
                    newDestination.carrier = findedCarrier;
                    [self setValuesFromDictionary:[object valueForKey:entityName] anObject:newDestination];
                    return [NSDictionary dictionaryWithObjectsAndKeys:@"new",@"operation",objectGUID,@"objectGUID",nil];
                } else return [NSDictionary dictionaryWithObjectsAndKeys:@"root carrier not found for new destination",@"result",objectGUID,@"objectGUID",nil];
            } 
            
            return [NSDictionary dictionaryWithObjectsAndKeys:@"carrier for destination have more than 2 records",@"error",objectGUID,@"objectGUID",nil];;
        }
        if ([fetchedObjects count] == 1) { 
            // UPDATED DESTINATION
            DestinationsListPushList *findedDestination = [fetchedObjects lastObject];
            
            if ([findedDestination.carrier.companyStuff.GUID isEqualToString:stuff.GUID]) {
                [self setValuesFromDictionary:[object valueForKey:entityName] anObject:findedDestination];
                if (![findedDestination.carrier.GUID isEqualToString:rootObjectGUID])
                {
                    // ops, relationship was changed, we must do a same on server
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:rootObjectEntityName inManagedObjectContext:self.moc];
                    [fetchRequest setEntity:entity];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",rootObjectGUID];
                    [fetchRequest setPredicate:predicate];
                    NSError *error = nil;
                    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
                    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
                    [fetchRequest release];
                    if ([fetchedObjects count] == 0) { 
                        return [NSDictionary dictionaryWithObjectsAndKeys:@"root carrier not found",@"error",objectGUID,@"objectGUID",nil];;
                    }
                    if ([fetchedObjects count] == 1) { 
                        Carrier *findedCarrier = [fetchedObjects lastObject];
                        if (findedCarrier) {
                            NSLog(@"SERVER CONTROLLER: destination change root carrier %@ >>>>> %@ ",findedDestination.carrier.name,findedCarrier.name);
                            findedDestination.carrier = findedCarrier;
                            
                            [self finalSave:moc];
                        } else return [NSDictionary dictionaryWithObjectsAndKeys:@"root carrier not found for updated destination",@"result",objectGUID,@"objectGUID",nil];
                        
                    } 
                    
                }
                return [NSDictionary dictionaryWithObjectsAndKeys:@"updated",@"result",nil];
            } else return [NSDictionary dictionaryWithObjectsAndKeys:@"you are not owner",@"error",objectGUID,@"objectGUID",nil];
        } 
        
        return [NSDictionary dictionaryWithObjectsAndKeys:@"destination have more than 2 records",@"error",objectGUID,@"objectGUID",nil];;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@"something wrong, maybe entity not pickuped",@"error",objectGUID,@"objectGUID",nil];
}
   
    
-(NSString *)putObjectForUserEmail:(NSString *)userEmail 
                     withPassword:(NSString *)password
                withNecessaryData:(NSArray *)necessaryData
                   mustBeApproved:(BOOL)isMustBeApproved   
                     withSenderIP:(NSString *)senderIP
                   withReceiverIP:(NSString *)receiverIP;

{
    CompanyStuff *stuff = [self authorizationForUserEmail:userEmail withPassword:password];
//    if (!stuff) {
//        NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
//        [finalJSONResult setValue:@"user authorization failed" forKey:@"error"];
//        [finalJSONResult setValue:@"hash" forKey:@"hash"];
//        NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:NULL];
//        return jsonStringForReturn;
//    }
    __block NSMutableArray *result = [NSMutableArray array];
//    [necessaryData enumerateObjectsUsingBlock:^(NSArray *necessaryDataOnce, NSUInteger idx, BOOL *stop) {
    for (NSArray *necessaryDataOnce in necessaryData) {
        NSDictionary *object = [necessaryDataOnce objectAtIndex:0];
        NSDictionary *rootObject = nil;
        if ([necessaryDataOnce count] > 1) {
            rootObject = [necessaryDataOnce objectAtIndex:1];
        }
        NSDictionary *resultOnce = [self processObject:object withRootObject:rootObject forStuff:stuff mustBeApproved:isMustBeApproved];
        [result addObject:resultOnce];
    };
    
//    NSDictionary *object = [necessaryData objectAtIndex:0];
//    NSDictionary *rootObject = [necessaryData objectAtIndex:1];
//    
//    NSDictionary *result = [self processObject:object withRootObject:rootObject forStuff:stuff mustBeApproved:isMustBeApproved];
    NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
    [finalJSONResult setValue:result forKey:@"result"];
    [finalJSONResult setValue:@"hash" forKey:@"hash"];
    NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:NULL];

    sleep(1);
    [self finalSave:self.moc];
    sleep(1);

    return jsonStringForReturn;

}

#pragma mark -
#pragma mark RemoveObject methods

-(NSDictionary *)removeObjectWithGUID:(NSString *)objectGUID 
                           withEntity:(NSString *)entityName 
                             forStuff:(CompanyStuff *)stuff
{
    if ([entityName isEqualToString:@"CurrentCompany"]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        if ([fetchedObjects count] == 0) { 
            return [NSDictionary dictionaryWithObjectsAndKeys:@"company for removing not found",@"error",nil];        
        }
        if ([fetchedObjects count] == 1) { 
            CurrentCompany *findedCompany = [fetchedObjects lastObject];
            
            if ([stuff.GUID isEqualToString:findedCompany.companyAdminGUID]) {
                if ([stuff.currentCompany.objectID isEqualTo:findedCompany.objectID]) {
                    return [NSDictionary dictionaryWithObjectsAndKeys:@"you can't remove root company",@"error",nil];                    
                } else {
                    [self.moc deleteObject:findedCompany];
                    [self finalSave:self.moc];
                    return nil;
                }
                
            } else return [NSDictionary dictionaryWithObjectsAndKeys:@"you are not admin",@"error",nil];
        } 
        
        return [NSDictionary dictionaryWithObjectsAndKeys:@"company have more than 2 records",@"error",nil];;
    }
    
    if ([entityName isEqualToString:@"CompanyStuff"]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        if ([fetchedObjects count] == 0) { 
            return [NSDictionary dictionaryWithObjectsAndKeys:@"stuff for removing not found",@"error",nil];        
        }
        if ([fetchedObjects count] == 1) { 
            CompanyStuff *findedStuff = [fetchedObjects lastObject];
            if ([findedStuff.GUID isEqualToString:stuff.GUID]) {
                return [NSDictionary dictionaryWithObjectsAndKeys:@"you can't remove yourself",@"error",nil];
            }
        } 
        
        return [NSDictionary dictionaryWithObjectsAndKeys:@"company have more than 2 records",@"error",nil];;
    }
    
    if ([entityName isEqualToString:@"Carrier"]) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        if ([fetchedObjects count] == 0) { 
            return [NSDictionary dictionaryWithObjectsAndKeys:@"carrier for removing not found",@"error",nil];        
        }
        if ([fetchedObjects count] == 1) { 
            Carrier *findedCarrier = [fetchedObjects lastObject];
            
            if ([findedCarrier.companyStuff.GUID isEqualToString:stuff.GUID]) {
                NSLog(@"SERVER CONTROLLER: removing carrier:%@",findedCarrier.name);
                [self.moc deleteObject:findedCarrier];
                [self finalSave:self.moc];

                return nil;
            } else return [NSDictionary dictionaryWithObjectsAndKeys:@"you are not owner of this carrier",@"error",nil];
        } 
        
        [fetchedObjects enumerateObjectsUsingBlock:^(Carrier *findedCarrier, NSUInteger idx, BOOL *stop) {
            if ([findedCarrier.companyStuff.GUID isEqualToString:stuff.GUID]) { 
                NSLog(@"SERVER CONTROLLER: removing carrier:%@",findedCarrier.name);
                [self.moc deleteObject:findedCarrier];
            }
        }];
        
        return [NSDictionary dictionaryWithObjectsAndKeys:@"carrier have more than 1 records",@"error",nil];;
    }
    
    if ([entityName isEqualToString:@"DestinationsListPushList"]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",objectGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        if ([fetchedObjects count] == 0) {
            return [NSDictionary dictionaryWithObjectsAndKeys:@"destination for removing not found",@"error",nil];        
         }
        if ([fetchedObjects count] == 1) { 
            // UPDATED DESTINATION
            DestinationsListPushList *findedDestination = [fetchedObjects lastObject];
            
            if ([findedDestination.carrier.companyStuff.GUID isEqualToString:stuff.GUID]) {
                [self.moc deleteObject:findedDestination];
                [self finalSave:self.moc];

                return nil;
            } else return [NSDictionary dictionaryWithObjectsAndKeys:@"you are not owner of this destination",@"error",nil];
        } 
        
        return [NSDictionary dictionaryWithObjectsAndKeys:@"destination have more than 2 records",@"error",nil];;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@"something wrong, maybe entity not pickuped",@"error",nil];
}

-(NSString *)removeObjectWithGUID:(NSString *)objectGUID 
                  forObjectEntity:(NSString *)objectEntity 
                      forUserEmail:(NSString *)userEmail 
                     withPassword:(NSString *)password                       
                     withSenderIP:(NSString *)senderIP
                   withReceiverIP:(NSString *)receiverIP;
{
    CompanyStuff *stuff = [self authorizationForUserEmail:userEmail withPassword:password];
    if (!stuff) {
        NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
        [finalJSONResult setValue:@"user authorization failed" forKey:@"error"];
        [finalJSONResult setValue:@"hash" forKey:@"hash"];
        NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:NULL];
        return jsonStringForReturn;
    }
    
    NSDictionary *result = [self removeObjectWithGUID:objectGUID withEntity:objectEntity forStuff:stuff];
    NSMutableDictionary *finalJSONResult = [NSMutableDictionary dictionaryWithCapacity:0];
    [finalJSONResult setValuesForKeysWithDictionary:result];
    [finalJSONResult setValue:@"hash" forKey:@"hash"];
    NSString *jsonStringForReturn = [finalJSONResult JSONStringWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:nil error:NULL];
    return jsonStringForReturn;

}


@end
