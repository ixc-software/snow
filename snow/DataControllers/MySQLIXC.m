
#import "MySQLIXC.h"
#import "desctopAppDelegate.h"
//#import "ProjectArrays.h"
#import "mysql.h"
#include <mach/mach_time.h>
#include <arpa/inet.h>
#include <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
//#import "GetExternalInfo.h"
#import "ProgressUpdateController.h"
#import "DatabaseConnections.h"
#import "CountrySpecificCodeList.h"
#import "CodesList.h"

#include "unistd.h"

@interface MySQLIXC (PrivateAPI)

- (BOOL)_isCurrentHostReachable;

@end

@implementation MySQLIXC


@synthesize queneNumber,connections,queryDone,carrierName,checkingMysqlQuery,connected,progress;//,sql,sqlPut;

- (id) init
{
    if ((self = [super init])) {
        //appDelegate = [[NSApplication sharedApplication] delegate];
        
    }
    return self;
}
- (id)initWithQuene:(NSUInteger)quene andCarrier:(NSManagedObjectID *)carrierID 
 withState:(BOOL)currentQueueStatus;
{
    if ((self = [super init])) {
        //appDelegate = [[NSApplication sharedApplication] delegate];
        [self setQueneNumber:quene];
        //_currentQueueStatus = currentQueueStatus;
        
    }
    return self;
}

- (id)initWithDelegate:(desctopAppDelegate *)delegate withProgress:(ProgressUpdateController *)_progress;
{
    if ((self = [super init])) {
        //appDelegate = delegate;
        if (_progress) {
            updateProgress = YES;
            self.progress = _progress;
        }
        else updateProgress = NO;
        
    }
    return self;
}


- (id)initWithQuene:(NSUInteger)quene andCarrier:(NSString *)_carrierName withProgress:(ProgressUpdateController *)_progress withDelegate:(GetExternalInfoOperation *)_getExternalInfoDelegate;
{
    if ((self = [super init])) {
        
//        getExternalInfoDelegate = _getExternalInfoDelegate;
        //appDelegate = [[NSApplication sharedApplication] delegate];
        [self setQueneNumber:quene];
        //_currentQueueStatus = currentQueueStatus;
        if (_progress) {
            updateProgress = YES;
            self.progress = _progress;
        }
        else updateProgress = NO;
        self.carrierName = _carrierName;
        
    }
    return self;
}
    
    
-(BOOL) reset;
{
    connected = NO;
    sleep(10);
    mysql_close(sql);
    mysql_close(sqlPut);
    return YES;
}

-(void)pingConnectionMainThread
{
    if (sql) mysql_ping(sql);
        
    if (sqlPut) mysql_ping(sqlPut);

}

/*-(void)pingConnection
{
    do {
        sleep(10);
        NSLog(@"MYSQL: ping");
        [self performSelectorOnMainThread:@selector(pingConnectionMainThread) withObject:nil waitUntilDone:YES];
    } while (self.connected);
}*/

-(BOOL) mysqlConnect
{
    // If no network is present, loop for a short period waiting for one to become available
    //if (self.sql) { unsigned int error = mysql_errno(self.sql); }
    
    /*while (![self _isCurrentHostReachable]) {
     int timer;
     timer++;
     sleep(2);
     NSLog(@"MYSQL: try checking connection timeout for queue:%@",[NSNumber numberWithUnsignedInteger:self.queneNumber]);
     //NSLog(@"MYSQL: queue status:%@",_currentQueueStatus);
     
     if (timer > 60) {
     NSLog(@"MYSQL: checking connection timeout for queue:%@ TIMEOUT",[NSNumber numberWithUnsignedInteger:self.queneNumber]);
     break;
     }
     }*/
    if (!sql || !sqlPut) {
        //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        for (NSDictionary *connection in connections)
        {
            //MYSQL newSql;
            if ([[connection valueForKey:@"selectionDirections"] intValue] == 0) {
                if (!sql) {
                    MYSQL *con;
                    con = mysql_init(NULL);
                    if (con == NULL) NSLog(@"MYSQL: Failed to initate connection");
                    my_bool reconnect = 1;
                    mysql_options(con, MYSQL_OPT_RECONNECT, &reconnect);
                    NSInteger connectionTimeout = 900; 
                    mysql_options(con, MYSQL_OPT_CONNECT_TIMEOUT, (const void *)&connectionTimeout);
                    mysql_options(con, MYSQL_OPT_WRITE_TIMEOUT, (const void *)&connectionTimeout);
                    mysql_options(con, MYSQL_OPT_READ_TIMEOUT, (const void *)&connectionTimeout);
                    
                    //mysql_options(newSql, CLIENT_INTERACTIVE, &reconnect);
                    
                    NSNumberFormatter *portTransfer = [[NSNumberFormatter alloc] init];
                    
                    const char *ip = [[connection valueForKey:@"ip"] UTF8String];
                    const char *login = [[connection valueForKey:@"login"] UTF8String];
                    const char *password = [[connection valueForKey:@"password"] UTF8String];
                    const char *database = [[connection valueForKey:@"database"] UTF8String];
                    unsigned int port = [[portTransfer numberFromString:[connection valueForKey:@"port"]] unsignedIntValue];
                    
                    
                    
                    sql = mysql_real_connect(con, ip , login, password, database, port, NULL, 0);
                    if (sql == NULL) { 
                        NSLog(@"MYSQL: Failed to connect database with error:%s\n for connection:%@",mysql_error(sql),connection); 
                        [portTransfer release];
                        return NO ;
                    }
                    [portTransfer release];
                }
                
            } else {
                if (!sqlPut) {
                    MYSQL *con;
                    con = mysql_init(NULL);
                    if (con == NULL) NSLog(@"MYSQL: Failed to initate connection");
                    my_bool reconnect = 1;
                    mysql_options(con, MYSQL_OPT_RECONNECT, &reconnect);
                    NSInteger connectionTimeout = 900; 
                    mysql_options(con, MYSQL_OPT_CONNECT_TIMEOUT, (const void *)&connectionTimeout);
                    mysql_options(con, MYSQL_OPT_WRITE_TIMEOUT, (const void *)&connectionTimeout);
                    mysql_options(con, MYSQL_OPT_READ_TIMEOUT, (const void *)&connectionTimeout);
                    

//                    sqlPut = mysql_init(NULL);
//                    if (sqlPut == NULL) NSLog(@"MYSQL: Failed to initate connection");
//                    my_bool reconnect = 1;
//                    mysql_options(sqlPut, MYSQL_OPT_RECONNECT, &reconnect);
//                    NSInteger connectionTimeout = 300; 
//                    mysql_options(sqlPut, MYSQL_OPT_CONNECT_TIMEOUT, (const void *)&connectionTimeout);
//                    mysql_options(sqlPut, MYSQL_OPT_WRITE_TIMEOUT, (const void *)&connectionTimeout);
//                    mysql_options(sqlPut, MYSQL_OPT_READ_TIMEOUT, (const void *)&connectionTimeout);
                    
                    //mysql_options(newSql, CLIENT_INTERACTIVE, &reconnect);
                    
                    NSNumberFormatter *portTransfer = [[NSNumberFormatter alloc] init];
                    
                    sqlPut = mysql_real_connect(con, [[connection valueForKey:@"ip"] UTF8String] , [[connection valueForKey:@"login"] UTF8String], [[connection valueForKey:@"password"] UTF8String], [[connection valueForKey:@"database"] UTF8String], [[portTransfer numberFromString:[connection valueForKey:@"port"]] unsignedIntValue], NULL, 0);
                    if (sqlPut == NULL) { 
                        NSLog(@"MYSQL: Failed to connect database with error:%s\n for connection:%@",mysql_error(sqlPut),connection); 
                        [portTransfer release];
                        return NO ;
                    }
                    //else NSLog(@"MYSQL: Carrier:%@ connect database DONE",carrierName); 
                    //if ([[connection valueForKey:@"selectionDirections"] intValue] == 0) if (!self.sql) self.sql = &newSql; else mysql_ping(self.sql);
                    //else {
                    //NSInteger connectionTimeout = 10; 
                    //mysql_options(newSql, MYSQL_OPT_CONNECT_TIMEOUT, (const void *)&connectionTimeout);
                    //self.sqlPut = newSql; 
                    //  if (!self.sqlPut) self.sqlPut = &newSql; else mysql_ping(self.sqlPut);
                    //}
                    [portTransfer release];
                }
            }
            
        }
        //[pool drain], pool = nil;

        connected = YES;

        //NSNumber *threadSafe = [NSNumber numberWithUnsignedInt:mysql_thread_safe()];
        //NSLog(@"MYSQL: thread safe is :%@",threadSafe);
        //[self performSelectorInBackground:@selector(pingConnection) withObject:nil];
    }  else {
        if (!sql) 
        {   unsigned long long pid = mysql_thread_id(sql);
            mysql_kill(sql, pid);
            mysql_ping(sql);
        }

    }
    
    
    return YES;
                
}


- (void)keepAlive:(NSTimer *)theTimer
{
    NSLog(@"MYSQL: ping was processed for queue:%@\n",[NSNumber numberWithUnsignedInteger:self.queneNumber]);
    //if (getExternalInfoDelegate.isCancelled == YES) NSLog(@"MYSQL: cancelled was pickup for queue %@\n",[NSNumber numberWithUnsignedInteger:self.queneNumber]);

    if (!sql) {
        if (![self mysqlConnect]){
            for (int attempt = 0;attempt <20;attempt++) if (![self mysqlConnect]) {
                NSLog(@"MYSQL: try make connection init timeout for queue:%@ attempt number %d",[NSNumber numberWithUnsignedInteger:self.queneNumber],attempt);
                continue;
            } else break;
        }
        return;
    }
    if (mysql_ping(sql)){
        unsigned int error = mysql_errno(sql);
        const char *errorChar = mysql_error(sql);
        NSLog(@"MYSQL:Cannot ping database: Error: %u.\n",error);
        if (error) NSLog(@"MYSQL:we pickup error: Error: %s.\n",errorChar);
    }
    //sleep (5);
    //[self performSelectorInBackground:@selector(keepAlive:) withObject:nil];
}


-(void)dealloc {
    
    //self.sql = nil;
    //self.sqlPut = nil;
    //self.qResult = nil;
    //getExternalInfoDelegate = nil;
    [progress release];
    //appDelegate = nil;
    [connections release];
    
    // Clean-up code here.
    //NSLog(@"This dealloc occurred in %@ (current object class %@) at line %d in file %s in function %s in pretty function %s",
    //      NSStringFromSelector(_cmd), NSStringFromClass([self class]), __LINE__, __FILE__, __FUNCTION__, __PRETTY_FUNCTION__);
    [super dealloc];
}
-(NSNumber *) deleteWithQuery:(NSString *)query;
{
    const char *cString = [query UTF8String]; 
    unsigned long long affectedRows = 0;
    
    if (sqlPut != NULL) { 
        mysql_query(sqlPut,cString); 
        affectedRows = mysql_affected_rows(sqlPut);
        if (affectedRows == 0) NSLog(@"MYSQL: Query: %@ was failed  with error:%s\n and error number:%d",query,mysql_error(sqlPut),mysql_errno(sqlPut));
    }
    else {
        [self mysqlConnect];
        if (sqlPut != NULL) {
            mysql_query(sqlPut,cString);
            affectedRows = mysql_affected_rows(sqlPut);
            if (affectedRows == 0) NSLog(@"MYSQL: Query: %@ was failed  with error:%s\n and error number:%d",query,mysql_error(sqlPut),mysql_errno(sqlPut));
        }
    }
    NSNumber *affectedRowsNumber = [NSNumber numberWithUnsignedLongLong:affectedRows];
    return affectedRowsNumber;
}


-(NSArray *) insertWithQuery:(NSString *)query;
{


    const char *cString = [query UTF8String]; 
    NSNumber *affectedRowsNum = nil;
    NSNumber *errorID = nil;
    NSNumber *insertIDNum = nil;
    
    //unsigned int insertID = 0;
    //unsigned long long affectedRows = 0;
    NSUInteger countOfAttempt = 0;
    
    Start:
    
    if (sqlPut != NULL) { 
        mysql_real_query(sqlPut,cString,strlen(cString));
        const char *mysqlInfo = mysql_info(sqlPut);
        if (!mysqlInfo) { 
            //NSLog(@"wrong Result is:%d",result);
            mysqlInfo = " X X X X";
        } else {
            
            NSString *mysqlInfoString = [NSString stringWithCString:mysqlInfo encoding:NSUTF8StringEncoding];
            NSArray *parsed = [mysqlInfoString componentsSeparatedByString:@" "];
            NSString *rowsMatched = [parsed objectAtIndex:2];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            affectedRowsNum = [formatter numberFromString:rowsMatched];
            [formatter release];
            //NSLog(@"Result is:%@ and affectedRow:%@",mysqlInfoString,affectedRowsNum);

        }
        if (!affectedRowsNum) {
            //this is insert, not update 
            unsigned long long affectedRows = mysql_affected_rows(sqlPut);
            affectedRowsNum = [NSNumber numberWithUnsignedLongLong:affectedRows];

            unsigned long long insertID = mysql_insert_id(sqlPut);
            
            if (insertID == 0 && affectedRows == 0)  {
                const char *err = mysql_error(sqlPut);
                NSString *mysqlErrorString = [NSString stringWithCString:err encoding:NSUTF8StringEncoding];
                unsigned int error_no = mysql_errno(sqlPut);
                unsigned int warning_count = mysql_warning_count(sqlPut);
                const char *state = mysql_sqlstate(sqlPut);
                NSString *mysqlStateString = [NSString stringWithCString:state encoding:NSUTF8StringEncoding];
                
                errorID = [NSNumber numberWithUnsignedInt:error_no];
                NSNumber *warning_countN = [NSNumber numberWithUnsignedInt:warning_count];

                NSLog(@"MYSQL:query %@ was failed  with error:%@\n and error number:%@ warning:%@ state:%@",query,mysqlErrorString,errorID,warning_countN,mysqlStateString);
            } else insertIDNum = [NSNumber numberWithUnsignedLongLong:insertID];
            //if (insertID == 0 && mysql_errno(self.sqlPut) != 0) NSLog(@"MYSQL: Insert: %@ was failed  with error:%s\n and error number:%d",query,mysql_error(self.sqlPut),mysql_errno(self.sqlPut));
        }

    }
        else {
            [self mysqlConnect];
            if (sqlPut != NULL) {
                int result = mysql_real_query(sqlPut,cString,strlen(cString));
                const char *mysqlInfo = mysql_info(sqlPut);
                if (!mysqlInfo) { 
                    NSLog(@"wrong Result is:%d",result);
                    mysqlInfo = " X X X X";
                } else {
                    
                    NSString *mysqlInfoString = [NSString stringWithCString:mysqlInfo encoding:NSUTF8StringEncoding];
                    NSArray *parsed = [mysqlInfoString componentsSeparatedByString:@" "];
                    NSString *rowsMatched = [parsed objectAtIndex:2];
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    affectedRowsNum = [formatter numberFromString:rowsMatched];
                    [formatter release];
                   // NSLog(@"Result is:%@ and affectedRow:%@",mysqlInfoString,affectedRowsNum);
                    
                }

                if (!affectedRowsNum) {
                    unsigned long long affectedRows = mysql_affected_rows(sqlPut);
                    affectedRowsNum = [NSNumber numberWithUnsignedLongLong:affectedRows];
                    //this is insert, not update 
                    //affectedRows = mysql_affected_rows(self.sqlPut);
                    unsigned long long insertID = mysql_insert_id(sqlPut);
                    
                    if (insertID == 0 && affectedRows == 0)  {
                        const char *err = mysql_error(sqlPut);
                        NSString *mysqlErrorString = [NSString stringWithCString:err encoding:NSUTF8StringEncoding];
                        unsigned int error_no = mysql_errno(sqlPut);
                        unsigned int warning_count = mysql_warning_count(sqlPut);
                        const char *state = mysql_sqlstate(sqlPut);
                        NSString *mysqlStateString = [NSString stringWithCString:state encoding:NSUTF8StringEncoding];
                        
                        errorID = [NSNumber numberWithUnsignedInt:error_no];
                        NSNumber *warning_countN = [NSNumber numberWithUnsignedInt:warning_count];
                        
                        NSLog(@"MYSQL:query %@ was failed  with error:%@\n and error number:%@ warning:%@ state:%@ ",query,mysqlErrorString,errorID,warning_countN,mysqlStateString);
                    } else insertIDNum = [NSNumber numberWithUnsignedLongLong:insertID];
                    //if (insertID == 0 && mysql_errno(self.sqlPut) != 0) NSLog(@"MYSQL: Insert: %@ was failed  with error:%s\n and error number:%d",query,mysql_error(self.sqlPut),mysql_errno(self.sqlPut));
                }
            }
        }
    countOfAttempt++;
    
    if (*mysql_error(sqlPut)) {
        const char *err = mysql_error(sqlPut);
        NSString *mysqlErrorString = [NSString stringWithCString:err encoding:NSUTF8StringEncoding];
        unsigned int error_id = mysql_errno(sqlPut);
        errorID = [NSNumber numberWithUnsignedInt:error_id];
       // NSLog(@"MYSQL:REPEAT query %@ was failed  with error:%@\n and error number:%@",query,mysqlErrorString,errorID);
        //1062 duplicate entry
        if ([errorID intValue] != 1062) { 
            NSLog(@"MYSQL:REPEAT query %@ was failed  with error:%@\n and error number:%@",query,mysqlErrorString,errorID);
            goto Start;
        }
    }
    
    //NSNumber *insertIDNum = [[[NSNumber alloc] initWithUnsignedInt:insertID] autorelease ];
    if (!insertIDNum) insertIDNum  = [NSNumber numberWithInt:0];
    if (!errorID) errorID  = [NSNumber numberWithInt:0];
    return [NSArray arrayWithObjects:insertIDNum,affectedRowsNum,errorID, nil];
}

-(NSArray *) fetchBinaryData:(NSString *)query;
{
    //progress
    /*if (updateProgress) {
        NSString *previousOperationName = self.progress.subOperationName;
        NSString *currentOperationName = [previousOperationName stringByAppendingString:@"[MYSQL]"];
        self.progress.subOperationName = currentOperationName;
    }*/
    const char *cString = [query UTF8String]; 
    unsigned int fieldIndex = 0;

    MYSQL_ROW row;
    MYSQL_FIELD *field;
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];

    if (sql != NULL) mysql_query(sql,cString);
        else {
            [self mysqlConnect];
            if (sql != NULL) mysql_query(sql,cString);
            else {
                [fields release];
                return nil;
            }
        }
    
    MYSQL_RES *qResult = mysql_store_result(sql);

    if (qResult != NULL) {
        unsigned int num_fields;
        //num_fields = mysql_num_fields(self.qResult);
        while((field = mysql_fetch_field(qResult)))
        {
            //printf("field name %s\n", field->name);
            NSString *fieldName = [NSString stringWithCString:field->name encoding:NSISOLatin1StringEncoding];
            NSNumber *typeOfField = [NSNumber numberWithUnsignedLong:field->type];
            NSDictionary *fieldDict = [NSDictionary dictionaryWithObjectsAndKeys:fieldName,@"fieldName",typeOfField,@"typeOfField", nil];
            [fields addObject:fieldDict];
            
        }
        num_fields = mysql_num_fields(qResult);

        
        //row = mysql_fetch_row(qResult);
        while ((row = mysql_fetch_row(qResult))) {
            
            NSMutableDictionary *rowDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            //unsigned long *lengths;
            //lengths = mysql_fetch_lengths(qResult);
            
            for (fieldIndex = 0; fieldIndex < num_fields ; fieldIndex++) {
                NSUInteger arrayIndex = [[NSNumber numberWithUnsignedInt:fieldIndex] unsignedIntegerValue];
                NSString *key = [[fields objectAtIndex:arrayIndex] valueForKey:@"fieldName"];
                //NSLog(@"%@",[[fields objectAtIndex:arrayIndex] valueForKey:@"typeOfField"]);

               // NSLog(@"%@",[NSNumber numberWithUnsignedInteger:lengths[i]]);
                
                NSString *base64 = nil;
                if (row[fieldIndex]) 
                {                
                    base64 = [NSString stringWithCString:row[fieldIndex] encoding:NSASCIIStringEncoding] ;
                    if ([[[fields objectAtIndex:arrayIndex] valueForKey:@"typeOfField"] intValue] == 252 )
                    {
                        // fix CTP bug in long blob text.
                        if ([key isEqualToString:@"log"]) { [rowDict setValue:base64 forKey:[NSString stringWithString:key]]; continue;} 

                        NSData *base64Data = [base64 dataUsingEncoding:NSASCIIStringEncoding];
                        const unsigned char *base64Bytes = [base64Data bytes];
                        NSMutableData *mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
                        NSUInteger lentext = [base64Data length];
                        unsigned long ixtext = 0;
                        unsigned char ch = 0;
                        //const unsigned char *base64Bytes = nil;
                        short i = 0, ixinbuf = 0;
                        BOOL flignore = NO;
                        BOOL flendtext = NO;
                        unsigned char inbuf[4], outbuf[3];


                        while( YES ) {
                            if( ixtext >= lentext ) break;
                            ch = base64Bytes[ixtext++];
                            flignore = NO;
                            
                            if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
                            else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
                            else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
                            else if( ch == '+' ) ch = 62;
                            else if( ch == '=' ) flendtext = YES;
                            else if( ch == '/' ) ch = 63;
                            else flignore = YES;
                            
                            if( ! flignore ) {
                                short ctcharsinbuf = 3;
                                BOOL flbreak = NO;
                                
                                if( flendtext ) {
                                    if( ! ixinbuf ) break;
                                    if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
                                    else ctcharsinbuf = 2;
                                    ixinbuf = 3;
                                    flbreak = YES;
                                }
                                
                                inbuf [ixinbuf++] = ch;
                                
                                if( ixinbuf == 4 ) {
                                    ixinbuf = 0;
                                    outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
                                    outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
                                    outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
                                    
                                    for( i = 0; i < ctcharsinbuf; i++ )
                                        [mutableData appendBytes:&outbuf[i] length:1];
                                }
                                
                                if( flbreak )  break;
                            }
                        }
                        [rowDict setValue:mutableData forKey:[NSString stringWithString:key]];
                    } else [rowDict setValue:base64 forKey:[NSString stringWithString:key]];

                } else {[rowDict setValue:[NSData data] forKey:[NSString stringWithString:key]]; continue;}

                //NSString *url = [NSString stringWithFormat:@"/Users/alex/test%@.ogg",[NSNumber numberWithInt: i]];
                //[mutableData writeToFile:url atomically:YES];

            }
            [result addObject:rowDict];
            [rowDict release];

        }
        mysql_free_result(qResult);
    } else { NSLog(@"MYSQL: Query: %@ was failed  with error:%s\n and error number:%d",query,mysql_error(sql),mysql_errno(sql)); }
    NSArray *finalResult = [NSArray arrayWithArray:result];
    [fields release];
    ////self.qResult = nil;
    
    return finalResult;
}

-(NSArray *) fetchNamedAllWith:(NSString *)query

{
    NSString *globalUID = [[NSString alloc] initWithString:[[NSProcessInfo processInfo] globallyUniqueString]];
    desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
    if (delegate.numberForSQLQueries > 3) [progress updateOperationNameForMsyqlQueryWaitingStart];
    while (delegate.numberForSQLQueries > 3)
    {
        sleep (2); 
        //NSLog (@"DESTINATIONS: operation waiting for finish heavy operation");  
    }
    @synchronized (delegate) {
        delegate.numberForSQLQueries += 1;
    }
    
    NSMutableArray *rows = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:0];
    
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @autoreleasepool {
        
        
        const char *cString = [query UTF8String]; 
        NSUInteger lentgh = [query length];
        unsigned int num_fields;
        unsigned long long num_rows;
        
        unsigned int fieldIndex = 0;
        MYSQL_FIELD *field;
        MYSQL_ROW row;
        
        for (int attempts = 0;attempts <20;attempts++) {
            //NSLog(@"MYSQL: Query: %@ was started",query);
            
            if (sql != NULL) mysql_real_query(sql,cString,lentgh); 
            else {
                [self mysqlConnect];
                if (sql != NULL) { 
                    
                    mysql_real_query(sql,cString,lentgh);
                }
                else continue;
            }
            //NSLog(@"MYSQL: Query: %@ was finished",query);
            
            MYSQL_RES *qResult = mysql_store_result(sql);
            //NSLog(@"MYSQL: Query: %@ result started",query);
            
            if (qResult != NULL) {
                //NSLog(@"MYSQL: Query: %@ mysql_fetch_field started",query);
                
                while((field = mysql_fetch_field(qResult)))
                {
                    //printf("field name %s\n", field->name);
                    [fields addObject:[NSString stringWithCString:field->name encoding:NSISOLatin1StringEncoding]];
                }
                num_fields = mysql_num_fields(qResult);
                num_rows = mysql_num_rows(qResult);
                NSNumber *numOfRows = [NSNumber numberWithUnsignedLongLong:num_rows];
                
                //int percent = 0;
                //NSLog(@"MYSQL: Query: %@ mysql_fetch_row started",query);
                
                while ((row = mysql_fetch_row(qResult))) {
                    //NSAutoreleasePool *poolCycle = [[NSAutoreleasePool alloc] init];
                    
                    NSMutableDictionary *rowDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    
                    for(fieldIndex = 0; fieldIndex < num_fields; fieldIndex++)  {
                        //printf("%s \n", row[fieldIndex] ? row[fieldIndex] : "NULL");
                        @autoreleasepool {
                            
                            
                            NSUInteger arrayIndex = [[NSNumber numberWithUnsignedInt:fieldIndex] unsignedIntegerValue];
                            NSString *key = [fields objectAtIndex:arrayIndex];
                            NSString *result = [NSString stringWithCString:(row[fieldIndex] ? row[fieldIndex] : "NULL") encoding:NSISOLatin1StringEncoding];
                            [rowDict setValue:result forKey:key];
                        }
                        //NSLog(@"Current rowDict:%@",rowDict);
                    }
                    
                    NSDictionary *rowDictFinal = [NSDictionary dictionaryWithDictionary:rowDict];
                    [rowDict release],rowDict = nil;
                    [rows addObject:rowDictFinal];
                    //[poolCycle drain], poolCycle = nil;
                    
                }
                
                
                //NSLog(@"MYSQL: Query: %@ mysql_fetch_row finished",query);
                
                if ([rows count] != [numOfRows unsignedIntegerValue]) {
                    NSLog(@"MYSQL: Query: %@ has fetch row  with error:%s\n Parameter numOfRows:%d\n Parameter [rows count]:%llu\n result:%@",query,mysql_error(sql),fieldIndex,num_rows,rows);
                }
                mysql_free_result(qResult);
                //NSLog(@"MYSQL: Query: %@ mysql_fetch_field finished",query);
                
                break;
            } else 
            {
                NSLog(@"MYSQL: Query: %@ was failed  with error:%s\n and error number:%d ",query,mysql_error(sql),mysql_errno(sql));
                //unsigned long long pid;
                if (sql) {
                    unsigned long long pid = mysql_thread_id(sql);
                    mysql_kill(sql, pid);
                    mysql_ping(sql);
                    NSLog(@"MYSQL:mysql_ping for carrier:%@ attempt number %d",carrierName,attempts);
                } else [self mysqlConnect];
                
                //if ([self mysqlConnect]) continue;
                //else NSLog(@"MYSQL: can't reconnect to mysql attempt number %d",attempts);
            }
            //NSLog(@"MYSQL: queue status:%@",_currentQueueStatus);
        }
        /*if (updateProgress) {
         //NSString *previousOperationName = self.progress.operationName;
         //NSString *currentOperationName = [previousOperationName stringByReplacingOccurrencesOfString:@"[MYSQL:" withString:@""];
         [self.progress updateOperationName:previousOperationName];
         }*/
        //[pool drain],pool = nil;
    }
    NSArray *resultArray = [NSArray arrayWithArray:rows];
    [rows release],rows = nil;
    [fields release],fields = nil;
    @synchronized (delegate) {
        delegate.numberForSQLQueries -= 1;
        [globalUID release];
    }
    [progress updateOperationNameForMsyqlQueryWaitingFinish];

    return resultArray;
}


-(NSArray *) carriersList;
{
    NSMutableArray *carriers = [NSMutableArray arrayWithCapacity:0];
    NSArray *companies = [self fetchNamedAllWith:@"select * from Users where rname = '7/7' or rname = '7/15' or rname = '15/15' or rname = '15/7' or rname = '30/15' or rname = '30/30' or rname = '7/3' or rname = '7/5' or rname = 'sv' or rname = '1/1EMS' or rname = 'druzhyni' or rname = 'minasyan'"]; 
    for (NSDictionary *company in companies)
    {
        NSString *companyName = [company valueForKey:@"company"];
        [carriers addObject:companyName];
    }
    NSArray *result = [NSArray arrayWithArray:carriers];
    return result;
}

-(NSArray *) destinationsListFor:(NSString *)carrier type:(int)type;
{
    NSArray *peersList = nil;
    NSMutableArray *priceList = [[NSMutableArray alloc] init];  
    @autoreleasepool {
        
        
        //NSLog(@"MYSQL: Start peersList for carrier:%@",carrier);
        if (type == 0) peersList = [NSArray arrayWithArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select InPeers.id,InIPAddresses.ip, InPeers.ruleSet,InIPAddresses.prefix,InIPAddresses.realPrefix,InPeers.yn from InPeers left join Users  using (uname)  left join InIPAddresses on InIPAddresses.uid=InPeers.id where company = '%@' group by InPeers.id,InIPAddresses.ip",carrier]]];
        //else peersList = [NSArray arrayWithArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select OutPeers.id,ruleSet, prefix, realprefix, yn from OutPeers left join Users  using (uname)  where company = '%@'",carrier]]];
        else peersList = [NSArray arrayWithArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select distinct OutIPAddresses.ip , OutPeers.id,ruleSet, prefix, realprefix, yn from OutIPAddresses left join OutPeers on OutIPAddresses.uid=OutPeers.id left join Users using(uname)  where company = '%@'",carrier]]];
        
        //NSLog(@"MYSQL: Finish peersList for carrier:%@\n peer list is %@",carrier,peersList);
        NSMutableArray *ruleSetAndPrefixes = [NSMutableArray array];
        // ruleSetAndPrefixes :
        //    enabled @"enabled", ruleset @"ruleSet", prefixes, @"prefixes",ips, @"ip"
        //                                                  |                |
        //                                    (prefix1,prefix2)         (ip1,ip2)
        
        for (NSDictionary *inPeer in peersList)
        {
            //NSLog(@"prefix: %@, realPrefix:%@",[inPeer valueForKey:@"prefix"],[inPeer valueForKey:@"realPrefix"]);
            
            NSString *prefix = [inPeer valueForKey:@"prefix"];
            NSString *realPrefix = [inPeer valueForKey:@"realPrefix"];
            NSString *ip = nil;
            if ([inPeer valueForKey:@"ip"]) ip = [inPeer valueForKey:@"ip"];
            else ip=@"undefined";
            
            NSString *ruleSet = [inPeer valueForKey:@"ruleSet"];
            NSString *yn = [inPeer valueForKey:@"yn"];
            NSString *idStr = [inPeer valueForKey:@"id"];
            
            if (([prefix class] != [NSNull class]) && ([realPrefix class] != [NSNull class]) && ([ip class] != [NSNull class]))  
            {
                //NSLog(@"MYSQL: replace prefix : %@, with realPrefix:%@",prefix,realPrefix);
                if (realPrefix) if ([realPrefix length] != 0) prefix = [NSString stringWithString:[prefix stringByReplacingOccurrencesOfString:realPrefix withString:@""]];
            } else continue;
            
            if ([yn isEqualToString:@"n"]) continue;
            
            //NSLog(@"prefix:%@",prefix);
            // check if in colection ruleset and prefixes we have current ruleset
            NSPredicate *predicateRulesetWithCurrentRuleset = [NSPredicate predicateWithFormat:@"(ruleSet == %@)",ruleSet];
            NSArray *rulesetWithCurrentRuleset = [ruleSetAndPrefixes filteredArrayUsingPredicate:predicateRulesetWithCurrentRuleset];
            
            //NSLog(@"MYSQL:rulesetWithCurrentRuleset:%@",rulesetWithCurrentRuleset);
            //NSLog(@"MYSQL:rulesetsWithOutCurrentRuleset:%@",rulesetsWithOutCurrentRuleset);
            //NSLog(@"ruleSetAndPrefixes:%@",ruleSetAndPrefixes);
            
            
            if ([rulesetWithCurrentRuleset count] != 0)
            {    
                // if ruleset already in collection, we check for current ruleset for prefix, and if it not there, we add it
                NSPredicate *predicateFilteredPrefixesInRulesetsList = [NSPredicate predicateWithFormat:@"prefixes contains[cd] %@",prefix];
                NSArray *filteredPrefixesInRulesetsList = [rulesetWithCurrentRuleset filteredArrayUsingPredicate:predicateFilteredPrefixesInRulesetsList];
                if ([filteredPrefixesInRulesetsList count] == 0) {
                    // if prefixes there, we have to replace current ruleset and add prefixes.
                    [ruleSetAndPrefixes removeObject:[rulesetWithCurrentRuleset lastObject]];
                    NSArray *oldPrefixesList = [[rulesetWithCurrentRuleset lastObject] valueForKey:@"prefixes"];
                    NSArray *oldIpList = [[rulesetWithCurrentRuleset lastObject] valueForKey:@"ip"];
                    NSMutableArray *newIpList = [NSMutableArray arrayWithArray:oldIpList];
                    if (![oldIpList containsObject:ip]) [newIpList addObject:ip];
                    NSMutableArray *newPrefixesList = [NSMutableArray arrayWithArray:oldPrefixesList];
                    [newPrefixesList addObject:prefix];
                    [ruleSetAndPrefixes addObject:[NSDictionary dictionaryWithObjectsAndKeys:yn,@"enabled",ruleSet,@"ruleSet",newPrefixesList,@"prefixes",idStr,@"idStr",oldIpList,@"ip",nil]];
                    oldPrefixesList = nil;
                    newPrefixesList = nil;
                } else {
                    // it is second ip for add
                    [ruleSetAndPrefixes removeObject:[rulesetWithCurrentRuleset lastObject]];
                    NSArray *oldIpList = [[rulesetWithCurrentRuleset lastObject] valueForKey:@"ip"];
                    NSArray *oldPrefixesList = [[rulesetWithCurrentRuleset lastObject] valueForKey:@"prefixes"];
                    NSMutableArray *newIpList = [NSMutableArray arrayWithArray:oldIpList];
                    if (![oldIpList containsObject:ip]) [newIpList addObject:ip];
                    [ruleSetAndPrefixes addObject:[NSDictionary dictionaryWithObjectsAndKeys:yn,@"enabled",ruleSet,@"ruleSet",oldPrefixesList,@"prefixes",idStr,@"idStr",newIpList,@"ip",nil]];
                    oldPrefixesList = nil;
                    newIpList = nil;
                }
                filteredPrefixesInRulesetsList = nil;
            } else 
            {
                // if we don't have prefixes there, we just insert one prefix
                NSMutableDictionary *newRuleset = [NSMutableDictionary dictionary];
                [newRuleset setValue:yn forKey:@"enabled"];
                [newRuleset setValue:ruleSet forKey:@"ruleSet"];
                [newRuleset setValue:[NSArray arrayWithObject:prefix] forKey:@"prefixes"];
                [newRuleset setValue:idStr forKey:@"idStr"];
                NSArray *ipListForStart = [NSArray arrayWithObjects:ip, nil];
                [newRuleset setValue:ipListForStart forKey:@"ip"];
                [ruleSetAndPrefixes addObject:[NSDictionary dictionaryWithDictionary:newRuleset]];
                newRuleset = nil;
                
            }
            rulesetWithCurrentRuleset = nil;
            prefix = nil;
        }
        
        NSLog(@"MYSQL:Ruleset and prefixes list for carrier: %@\n have :%@\n for type of service:%d\n",carrier, ruleSetAndPrefixes, type);
        for (NSDictionary *ruleSetAndPrefix in ruleSetAndPrefixes)
        {
            @autoreleasepool {
                
                NSArray *ips = [ruleSetAndPrefix valueForKey:@"ip"];
                NSString *ipStr = [ips componentsJoinedByString:@","];    
                
                NSArray *prefixesForThisRule = [ruleSetAndPrefix valueForKey:@"prefixes"];
                for (NSString *prefixForThisRule in prefixesForThisRule) {
                    NSString *ruleSet = [ruleSetAndPrefix valueForKey:@"ruleSet"];
                    NSString *queryRateSheets = [NSString stringWithFormat:@"select RateSheets.id,RateSheets.name from RuleSets left join Rules on RuleSets.rule = Rules.id left join RateSheets on uid = price where RuleSets.id = '%@'  and date_activate <= now() order by date_activate desc limit 1;",ruleSet];
                    NSArray *rateSheetId = [self fetchNamedAllWith:queryRateSheets];
                    if ([rateSheetId count] == 0) continue;
                    NSString *rateSheetIdString = [[rateSheetId lastObject] valueForKey:@"id"];
                    NSString *rateSheetNameString = [[rateSheetId lastObject] valueForKey:@"name"];
                    // we agreed that we take just one rateSheet, which was activate last
                    //if ([rateSheetId count] > 1) NSLog(@"MYSQL: WARNING! Ruleset and prefixes have more than one rateSheetID  for carrier: %@\n have :%@\n for type of service:%d\n  Hole rateSheetArea:%@ \n",carrier, ruleSetAndPrefixes, type,rateSheetId);
                    NSString *queryCode = [NSString stringWithFormat:@"select code,price,enabled,chdate from InDefaultPrice where uid='%@'",rateSheetIdString];
                    
                    //NSLog(@"currentPrices for carrier: %@\n with uid = %@\n and prefix:%@\n have :%@\n ",carrier,rateSheetId,prefixForThisRule, currentPrices);
                    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                    
                    NSArray *queryResult = [self fetchNamedAllWith:queryCode];
                    //NSArray *currentPrices = [[NSArray alloc] initWithArray:queryResult];
                    
                    for (NSDictionary *currenPrice in queryResult)
                    {
                        @autoreleasepool {
                            NSMutableDictionary *newPrice = [NSMutableDictionary dictionaryWithDictionary:currenPrice];
                            [newPrice setValue:prefixForThisRule  forKey:@"prefix"];
                            [newPrice setValue:[ruleSetAndPrefix valueForKey:@"enabled"]  forKey:@"yn"];
                            [newPrice setValue:rateSheetNameString  forKey:@"rateSheetName"];
                            [newPrice setValue:rateSheetIdString  forKey:@"rateSheetID"];
                            [newPrice setValue:[ruleSetAndPrefix valueForKey:@"idStr"]  forKey:@"peerID"];
                            [newPrice setValue:ipStr forKey:@"ip"];
                            
                            [priceList addObject:newPrice];
                        }
                    }
                    
                    //[currentPrices release];
                }
            }
        }
        //NSLog(@"MYSQL: Start price select for carrier:%@",carrier);
        
        //NSLog(@"priceList:%@",priceList);
        NSArray *localPriceListsOnPeers = nil;
        if (type == 0) localPriceListsOnPeers = [NSArray arrayWithArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select Price.*, InPeers.yn,InIPAddresses.ip, InIPAddresses.prefix from Price left join InPeers on Price.uid = InPeers.id left join Users using (uname) left join InIPAddresses on InIPAddresses.uid=InPeers.id where company = '%@' group by Price.code, Price.uid, InIPAddresses.prefix",carrier]]];
        else localPriceListsOnPeers = [NSArray arrayWithArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select OutPeers.yn, OutPeers.prefix, OutPrice.* from OutPrice left join OutPeers on OutPrice.pid = OutPeers.id left join Users using (uname) where company = '%@'",carrier]]];
        
        [priceList addObjectsFromArray:localPriceListsOnPeers];
        //NSLog(@"priceList:%@",priceList);
        //NSLog(@"MYSQL: Finish price select for carrier:%@",carrier);
        peersList = nil;
        ruleSetAndPrefixes = nil;
        localPriceListsOnPeers = nil;
    }
    NSArray *finalResult = [NSArray arrayWithArray:priceList];
        
    [priceList release];
    return finalResult;
    
}

-(NSArray *) destinationsForSaleList:(NSString *)carrier;
{
    // 0 for sale 1 we are buying.
    return [self destinationsListFor:carrier type:0];
}

-(NSArray *) destinationsWeAreBuyList:(NSString *)carrier;
{
    return [self destinationsListFor:carrier type:1];
    
}
-(NSArray *) outStatUsedCodesWithStatisticForCarrier:(NSString *)carrier day:(NSString *)day;
{
    NSArray *usedCodes = [self outStatUsedCodes:carrier day:day];
    NSLog(@"MYSQL: used OUT codes:%@",usedCodes);
    NSMutableArray *finalusedCodesWithStatistic = [NSMutableArray arrayWithCapacity:0];
    [usedCodes enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *prefix = [obj valueForKey:@"prefix"];
        NSString *code = [obj valueForKey:@"code"];
        NSString *rateSheetId = [obj valueForKey:@"id"];
        
        NSArray *outStatisicForCode = [self outStatistic:carrier withCode:code withDay:day withRateSheetId:rateSheetId withPrefix:prefix];
        [obj setValue:outStatisicForCode forKey:@"statistic"];
        
        NSArray *outStatisicPerHourForCode = [self outStatisticPerHour:carrier withCode:code day:day];
        [obj setValue:outStatisicPerHourForCode forKey:@"statisticPerHour"];
        if ([outStatisicForCode count] >= 1 && [outStatisicPerHourForCode count] >= 1) [finalusedCodesWithStatistic addObject:obj];
        else {
            NSLog(@"MYSQL: warning, carrier:%@, code:%@, prefix:%@,rateSheetID:%@ don't have statistic. OUT statistic:%@, out per hour:%@",carrier,code,prefix,rateSheetId,outStatisicForCode,outStatisicPerHourForCode);
        }
    }];
    return finalusedCodesWithStatistic;
}


-(NSArray *) inStatUsedCodesWithStatisticForCarrier:(NSString *)carrier day:(NSString *)day;
{
    NSArray *usedCodes = [self inStatUsedCodes:carrier day:day];
    NSLog(@"MYSQL: used IN codes:%@",usedCodes);

    NSMutableArray *finalusedCodesWithStatistic = [NSMutableArray arrayWithCapacity:0];

    [usedCodes enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *prefix = [obj valueForKey:@"prefix"];
        NSString *code = [obj valueForKey:@"code"];
        NSString *rateSheetId = [obj valueForKey:@"id"];
        
        NSArray *inStatisicForCode = [self inStatistic:carrier withCode:code withDay:day withRateSheetId:rateSheetId withPrefix:prefix];
        [obj setValue:inStatisicForCode forKey:@"statistic"];
        
        NSArray *inStatisicPerHourForCode = [self inStatisticPerHour:carrier withCode:code day:day prefix:prefix];
        [obj setValue:inStatisicPerHourForCode forKey:@"statisticPerHour"];
        if ([inStatisicForCode count] >= 1 && [inStatisicPerHourForCode count] >= 1) [finalusedCodesWithStatistic addObject:obj];
        else { 
            NSLog(@"MYSQL: warning, carrier:%@, code:%@, prefix:%@,rateSheetID:%@ don't have statistic. IN statistic:%@, out per hour:%@",carrier,code,prefix,rateSheetId,inStatisicForCode,inStatisicPerHourForCode);
        }
    }];
    return finalusedCodesWithStatistic;
}

-(NSArray *) inStatUsedCodes:(NSString *)carrier day:(NSString *)day;
{
    NSString *query = [NSString stringWithFormat:@"select InPeers.ruleSet,code, InIPAddresses.prefix, InIPAddresses.realPrefix from FinReportInCache left join InPeers on peerId = InPeers.id left join Users using ( uname ) left join InIPAddresses on InIPAddresses.uid = InPeers.id where company = '%@' and day > %@ group by code,InPeers.ruleSet",carrier,day];
    NSArray *result = [self fetchNamedAllWith:query];
    NSLog(@"MYSQL: in stat usedCodes:%@",result);
    NSMutableArray *resultForOut = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *resultDict in result)
    {   
        NSMutableDictionary *dictionaryResult = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *ruleSet = [resultDict valueForKey:@"ruleSet"];    
        NSArray *rateSheetId = [self fetchNamedAllWith:[NSString stringWithFormat:@"select RateSheets.id,RateSheets.name from RuleSets left join Rules on RuleSets.rule = Rules.id left join RateSheets on uid = price where RuleSets.id = '%@'  and date_activate <= now() order by date_activate desc limit 1;",ruleSet]];
        [dictionaryResult addEntriesFromDictionary:[rateSheetId lastObject]];
        [dictionaryResult addEntriesFromDictionary:resultDict];
        [resultForOut addObject:dictionaryResult];
    }
    
    NSArray *finalResults = [NSArray arrayWithArray:resultForOut];
    
    query = nil;
    return finalResults;
    
    //return [self fetchNamedAllWith:[NSString stringWithFormat:@"select code, InIPAddresses.prefix, InIPAddresses.realPrefix from FinReportInCache left join InPeers on peerId = InPeers.id left join Users using ( uname ) left join InIPAddresses on InIPAddresses.uid = InPeers.id where company = '%@' and day > %@ group by code",carrier,day]];
}


-(NSArray *) outStatUsedCodes:(NSString *)carrier day:(NSString *)day;
{
    NSString *query = [NSString stringWithFormat:@"select OutPeers.ruleSet,OutPeers.prefix,OutPeers.realPrefix, code from FinReportOutCache left join OutPeers on peerId = OutPeers.id left join Users using ( uname ) where company = '%@' and day > %@ group by code,OutPeers.ruleSet",carrier,day];
    NSArray *result = [self fetchNamedAllWith:query];
    NSLog(@"MYSQL: out stat usedCodes:%@",result);

    NSMutableArray *resultForOut = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *resultDict in result)
    {   
        NSString *prefix = [resultDict valueForKey:@"prefix"];
        NSString *prefixNew = nil;
        if ([resultDict valueForKey:@"realPrefix"]) prefixNew = [prefix stringByReplacingOccurrencesOfString:[resultDict valueForKey:@"realPrefix"] withString:@""];
        else prefixNew = prefix;

        NSMutableDictionary *dictionaryResult = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *ruleSet = [resultDict valueForKey:@"ruleSet"];    
        NSArray *rateSheetId = [self fetchNamedAllWith:[NSString stringWithFormat:@"select RateSheets.id,RateSheets.name from RuleSets left join Rules on RuleSets.rule = Rules.id left join RateSheets on uid = price where RuleSets.id = '%@'  and date_activate <= now() order by date_activate desc limit 1;",ruleSet]];
        [dictionaryResult addEntriesFromDictionary:[rateSheetId lastObject]];
        [dictionaryResult addEntriesFromDictionary:resultDict];
        [dictionaryResult setValue:prefixNew forKey:@""];
        [resultForOut addObject:dictionaryResult];
    }
    
    NSArray *finalResults = [NSArray arrayWithArray:resultForOut];
    
    query = nil;
    return finalResults;
}

-(NSArray *) inStatistic:(NSString *)carrier withCode:(NSString *)code withDay:(NSString *)day withRateSheetId:(NSString *)rateSheetId withPrefix:(NSString *)prefix;
{
    //NSArray *inPeersIds = [NSArray array];
    NSMutableArray *inStat = [NSMutableArray array];
    //NSString *prefixWithPercent = [prefix stringByAppendingString:@"%"];
    NSString *prefixWithCode = [prefix stringByAppendingString:code];
    // prefix in IPAddress can be just prefix or prefix plus code
    NSArray *inPeersIds = [self fetchNamedAllWith:[NSString stringWithFormat:@"select distinct InPeers.id from InPeers left join Users using ( uname ) left join InIPAddresses on uid=InPeers.id where company= '%@' and prefix = '%@'",carrier,prefixWithCode]];
    if ([inPeersIds count] == 0) {
        inPeersIds = [self fetchNamedAllWith:[NSString stringWithFormat:@"select distinct InPeers.id from InPeers left join Users using ( uname ) left join InIPAddresses on uid=InPeers.id where company= '%@' and prefix = '%@'",carrier,prefix]];
    }
    
    
    for (NSDictionary *inPeerID in inPeersIds)
    {
        [inStat addObjectsFromArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select sum(cnt) as Count, sum(mlen)/sum(cnt) as ACD, sum(succ)/sum(cnt) as ASR, sum(mlen) as Minutes, sum(price*mlen+connectSum-ocost) as Profit, sum(price*mlen+connectSum) as Amount from FinReportInCache left join InPeers on peerId = InPeers.id left join Users using ( uname ) where FinReportInCache.valute = 0 and code = '%@' and day > %@ and peerID = %@",code,day,[inPeerID valueForKey:@"id"]]]];
        // NSLog(@"last object count:%@",[[inStat lastObject] valueForKey:@"Count"]);
        NSString *count = [[inStat lastObject] valueForKey:@"Count"];
        BOOL searchCodeDone = NO;
        if ([count isEqualToString:@"NULL"]) {
            NSString *prefixPlusCode = [NSString stringWithFormat:@"%@%@",prefix,code];
            [inStat removeLastObject];
            int maxPrefixDeep = 8; 
            if ([prefixPlusCode length] < maxPrefixDeep) maxPrefixDeep = [[NSNumber numberWithUnsignedInteger:[prefixPlusCode length]] intValue] - 1;
            
            NSRange prefixRange = NSMakeRange(0,[prefixPlusCode length]);
            //NSString *changedPrefix = [NSString string];
            for (NSUInteger prefixDeep = 0; prefixDeep < maxPrefixDeep;prefixDeep++) 
            {
                NSLog(@"MYSQL: WARNING deep attempt for inStatistic with prefixDeep:%@ for code:%@, Carrier:%@",[NSNumber numberWithUnsignedInteger:prefixDeep],code,carrier);
                if (prefixRange.length != 0) prefixRange.length = prefixRange.length - 1;
                else break;
                NSString *changedPrefix = [prefixPlusCode substringWithRange:prefixRange];
                NSArray *inPeersIdsTemporary =  [self fetchNamedAllWith:[NSString stringWithFormat:@"select distinct InPeers.id from InPeers left join Users using ( uname ) left join InIPAddresses on uid=InPeers.id where company= '%@' and prefix = '%@'",carrier,changedPrefix]];
                for (NSDictionary *inPeerIDTemporary in inPeersIdsTemporary) {
                    [inStat addObjectsFromArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select sum(cnt) as Count, sum(mlen)/sum(cnt) as ACD, sum(succ)/sum(cnt) as ASR, sum(mlen) as Minutes, sum(price*mlen+connectSum-ocost) as Profit, sum(price*mlen+connectSum) as Amount from FinReportInCache left join InPeers on peerId = InPeers.id left join Users using ( uname ) where FinReportInCache.valute = 0 and code = '%@' and day > %@ and peerID = %@",code,day,[inPeerIDTemporary valueForKey:@"id"]]]];
                    NSString *lastCount = [[inStat lastObject] valueForKey:@"Count"];

                    if ([lastCount isEqualToString:@"NULL"]) { [inStat removeLastObject]; continue; }
                    else {
                        searchCodeDone = YES;
                        break;
                    }
                }
                if (searchCodeDone) break;
            }
        }
    }
    inPeersIds = nil;
    return inStat;
}

-(NSArray *) inStatisticPerHour:(NSString *)carrier withCode:(NSString *)code day:(NSString *)day prefix:(NSString *)prefix;
{
    //NSArray *inPeersIds = nil;
    NSMutableArray *inStat = [NSMutableArray array];
    //NSString *prefixWithPercent = [prefix stringByAppendingString:@"%"];
    NSString *prefixWithCode = [prefix stringByAppendingString:code];
    
    NSArray *inPeersIds = [self fetchNamedAllWith:[NSString stringWithFormat:@"select distinct InPeers.id from InPeers left join Users using ( uname ) left join InIPAddresses on uid=InPeers.id where company = '%@' and prefix = '%@'",carrier,prefixWithCode]];
    if ([inPeersIds count] == 0) {
        inPeersIds = [self fetchNamedAllWith:[NSString stringWithFormat:@"select distinct InPeers.id from InPeers left join Users using ( uname ) left join InIPAddresses on uid=InPeers.id where company= '%@' and prefix = '%@'",carrier,prefix]];
    }
    
    for (NSDictionary *inPeerID in inPeersIds)
    {
        [inStat addObjectsFromArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select day as Date, cnt as Count, mlen/cnt as ACD, succ/cnt as ASR, mlen as Minutes, price*mlen+connectSum-ocost as Profit, price*mlen+connectSum as Amount from FinReportInCache where FinReportInCache.valute = 0 and code = '%@' and day > %@ and peerID = %@",code,day,[inPeerID valueForKey:@"id"]]]];
        // NSLog(@"last object count:%@",[[inStat lastObject] valueForKey:@"Count"]);
        if ([[inStat lastObject] valueForKey:@"Date"] == [NSNull null]) [inStat removeLastObject];
    }
    inPeersIds = nil;
    
    return inStat;
    
}


-(NSArray *) outStatistic:(NSString *)carrier withCode:(NSString *)code withDay:(NSString *)day withRateSheetId:(NSString *)rateSheetId  withPrefix:(NSString *)prefix;
{
    if (prefix == nil) prefix = @"";
    NSArray *results = [self fetchNamedAllWith:[NSString stringWithFormat:@"select OutPeers.ruleSet,sum(cnt) as Count, sum(mlen)/sum(cnt) as ACD, sum(succ)/sum(cnt) as ASR, sum(mlen) as Minutes from FinReportOutCache left join OutPeers on peerId = OutPeers.id left join Users using ( uname ) where FinReportOutCache.valute = 0 and code = '%@' and company = '%@' and day > %@ and prefix like '%@' group by OutPeers.ruleSet",code,carrier,day,prefix]];
    NSMutableDictionary *finalResult = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSDictionary *resultDict in results) 
    {
        //NSDictionary *resultDict = [results lastObject];
        NSString *ruleSet = [resultDict valueForKey:@"ruleSet"];    
        NSArray *rateSheetSearch = [self fetchNamedAllWith:[NSString stringWithFormat:@"select RateSheets.id,RateSheets.name from RuleSets left join Rules on RuleSets.rule = Rules.id left join RateSheets on uid = price where RuleSets.id = '%@'  and date_activate <= now() order by date_activate desc limit 1;",ruleSet]];
        NSDictionary *currentRateSheetID = [rateSheetSearch lastObject];
        if ([[currentRateSheetID valueForKey:@"id"] isEqualToString:rateSheetId]) [finalResult addEntriesFromDictionary:resultDict];
    }
    NSDictionary *finalResults = [NSDictionary dictionaryWithDictionary:finalResult];
    return [NSArray arrayWithObject:finalResults];
}

-(NSArray *) outStatisticPerHour:(NSString *)carrier withCode:(NSString *)code day:(NSString *)day;
{
    NSArray *results = [self fetchNamedAllWith:[NSString stringWithFormat:@"select OutPeers.ruleSet,day as Date, cnt as Count, mlen/cnt as ACD, succ/cnt as ASR, mlen as Minutes, 0 as Profit, sum(price*mlen+connectSum) as Amount from FinReportOutCache left join OutPeers on peerId = OutPeers.id left join Users using ( uname ) where FinReportOutCache.valute = 0 and code = %@ and company = '%@' and day > %@ group by day, OutPeers.ruleSet",code,carrier,day]];
    NSMutableArray *resultForOut = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *resultDict in results)
    {   
        NSMutableDictionary *dictionaryResult = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *ruleSet = [resultDict valueForKey:@"ruleSet"];    
        NSArray *rateSheetId = [self fetchNamedAllWith:[NSString stringWithFormat:@"select RateSheets.id,RateSheets.name from RuleSets left join Rules on RuleSets.rule = Rules.id left join RateSheets on uid = price where RuleSets.id = '%@'  and date_activate <= now() order by date_activate desc limit 1;",ruleSet]];
        [dictionaryResult setValue:[rateSheetId lastObject] forKey:@"rateSheetId"];
        [dictionaryResult addEntriesFromDictionary:resultDict];
        [resultForOut addObject:dictionaryResult];
    }
    
     NSArray *finalResults = [NSArray arrayWithArray:resultForOut];
     return finalResults;

}


-(NSArray *) carrierStuff:(NSString *)carrier;
{
    return [self fetchNamedAllWith:[NSString stringWithFormat:@"select admname,admemail,techname,techemail from Users  where company = '%@'",carrier]];
}

-(NSArray *) carrierResponsible:(NSString *)carrier;
{
    NSArray *responsibleList = [NSArray arrayWithArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select rname from Users  where company = '%@'",carrier]]];
    NSString *responsible = [[responsibleList lastObject] valueForKey:@"rname"];
    NSArray *responsibleData = [NSArray arrayWithArray:[self fetchNamedAllWith:[NSString stringWithFormat:@"select * from Admins where uname = '%@'",responsible]]];
    return responsibleData;
}

-(void) deleteRateSheetWithID:(NSString *)rateSheetID;
{
    [self deleteWithQuery:[NSString stringWithFormat:@"delete from InDefaultPrice where uid = %@",rateSheetID]];
}

-(BOOL) updateForCode:(NSString *)code  forDate:(NSString *)date forRate:(NSString *)rate  forRateSheet:(NSString *)rateSheetID forCountry:(NSString *)country forSpecific:(NSString *)specific;
{
    BOOL result = NO;
    NSArray *resultQuery = nil;
    NSString *finalCountryString = nil;
    
    if (specific) {
        NSString *countryNew = [country stringByReplacingOccurrencesOfString:@"'" withString:@" "];
        NSString *specificNew = [specific stringByReplacingOccurrencesOfString:@"'" withString:@" "];
        finalCountryString = [NSString stringWithFormat:@"%@/%@ - changed by SNOW",countryNew,specificNew];
    } else {
        NSString *countryNew = [country stringByReplacingOccurrencesOfString:@"'" withString:@" "];
        finalCountryString = [NSString stringWithFormat:@"%@ - changed by SNOW",countryNew];
    }
    
//    NSString *finalCountryString = [NSString stringWithFormat:@"%@/%@ - changed by SNOW",countryNew,specificNew];
    resultQuery = [self insertWithQuery:[NSString stringWithFormat:@"update InDefaultPrice set price = '%@',chdate = '%@',country = '%@' where code = %@ and uid = %@",rate, date, finalCountryString,code, rateSheetID]];
     
    if ([[resultQuery objectAtIndex:1] intValue] == 0) {
        result = NO;
    }
    else result=  YES;
    
    return result;
        
} 

-(NSArray *) receiveRoutingTableForCode:(NSString *)code prefix:(NSString *)prefix carrier:(NSString *)carrier;
{
    NSMutableArray *routing = [NSMutableArray array];
    NSString *prefixWithCode = [prefix stringByAppendingString:code];
    
    
    NSArray *uids = [self fetchNamedAllWith:[NSString stringWithFormat:@"select distinct(uid) as uid,InPeers.profitOptionsClass from InIPAddresses left join InPeers on uid=InPeers.id left join Users using ( uname ) where company = '%@' and prefix = '%@'",carrier,prefixWithCode]];
    if ([uids count] == 0) {
        uids = [self fetchNamedAllWith:[NSString stringWithFormat:@"select distinct(uid) as uid,InPeers.profitOptionsClass from InIPAddresses left join InPeers on uid=InPeers.id left join Users using ( uname ) where company = '%@' and prefix = '%@'",carrier,prefix]];
    }
    //NSLog(@"ROUTING: UIDS:%@ for code:%@, carrier:%@, prefix%@",uids, code, carrier, prefix);
    
    for (NSDictionary *uid in uids)
    {
        NSString *profitOptionsClassId = [uid valueForKey:@"profitOptionsClass"];
        NSArray *profitOptionsClass = [self fetchNamedAllWith:[NSString stringWithFormat:@"select name,minProfitAbs,minProfitRel from ProfitOptions where id = %@",profitOptionsClassId]];
        NSDictionary *profitOptions = nil;
        if ([profitOptionsClass count] != 0) profitOptions = [profitOptionsClass lastObject];
        else profitOptions = [NSDictionary dictionaryWithObjectsAndKeys:@"None",@"name",@"0",@"minProfitAbs",@"0",@"minProfitRel", nil];

        NSString *uidStr = [uid valueForKey:@"uid"];
        
        NSArray *allowedRoutesRouting = [self fetchNamedAllWith:[NSString stringWithFormat:@"select OutPeers.ruleSet,company,prefix,routePrio from AllowedRoutes left join OutPeers on outId=OutPeers.id left join Users on OutPeers.uname = Users.uname where inId= %@",uidStr]];
        
        NSMutableArray *allowedRoutesRoutingChanged = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *resultDict in allowedRoutesRouting)
        {   
            NSMutableDictionary *dictionaryResult = [NSMutableDictionary dictionaryWithCapacity:0];
            NSString *ruleSet = [resultDict valueForKey:@"ruleSet"];    
            NSArray *rateSheetId = [self fetchNamedAllWith:[NSString stringWithFormat:@"select RateSheets.id,RateSheets.name from RuleSets left join Rules on RuleSets.rule = Rules.id left join RateSheets on uid = price where RuleSets.id = '%@'  and date_activate <= now() order by date_activate desc limit 1;",ruleSet]];
            [dictionaryResult setValue:[[rateSheetId lastObject] valueForKey:@"id"] forKey:@"rateSheetId"];
            [dictionaryResult setValue:[[rateSheetId lastObject] valueForKey:@"name"] forKey:@"rateSheet"];

            [dictionaryResult addEntriesFromDictionary:resultDict];
            [dictionaryResult addEntriesFromDictionary:profitOptions];
            [dictionaryResult addEntriesFromDictionary:uid];

            [allowedRoutesRoutingChanged addObject:dictionaryResult];
        }
        [routing addObjectsFromArray:allowedRoutesRoutingChanged];
    
        
        NSArray *allowedGroupsRouting = [self fetchNamedAllWith:[NSString stringWithFormat:@"select OutPeers.ruleSet,company,prefix,routePrio from AllowedGroups left join OutGroupPeers using ( gid ) left join OutPeers on outId=OutPeers.id left join Users on OutPeers.uname = Users.uname where inId= %@",uidStr]];
        NSMutableArray *allowedGroupsRoutingChanged = [NSMutableArray arrayWithCapacity:0];

        for (NSDictionary *resultDict in allowedGroupsRouting)
        {   
            NSMutableDictionary *dictionaryResult = [NSMutableDictionary dictionaryWithCapacity:0];
            NSString *ruleSet = [resultDict valueForKey:@"ruleSet"];    
            NSArray *rateSheetId = [self fetchNamedAllWith:[NSString stringWithFormat:@"select RateSheets.id,RateSheets.name from RuleSets left join Rules on RuleSets.rule = Rules.id left join RateSheets on uid = price where RuleSets.id = '%@'  and date_activate <= now() order by date_activate desc limit 1;",ruleSet]];
            [dictionaryResult setValue:[[rateSheetId lastObject] valueForKey:@"id"] forKey:@"rateSheetId"];
            [dictionaryResult setValue:[[rateSheetId lastObject] valueForKey:@"name"] forKey:@"rateSheet"];

            [dictionaryResult addEntriesFromDictionary:resultDict];
            [dictionaryResult addEntriesFromDictionary:profitOptions];

            [allowedGroupsRoutingChanged addObject:dictionaryResult];
            [dictionaryResult addEntriesFromDictionary:uid];

        }
        
        [routing addObjectsFromArray:allowedGroupsRoutingChanged];
        
    }
    
    NSMutableArray *filteredRouting = [NSMutableArray array];
    for (NSDictionary *route in routing)
    {
        NSString *company = [route valueForKey:@"company"];
        NSString *prefix = [route valueForKey:@"prefix"];
        NSString *routePrio = [route valueForKey:@"routePrio"];
        NSString *rateSheetId = [route valueForKey:@"rateSheetId"];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company = %@) AND (prefix = %@) AND (routePrio = %@) and (rateSheetId = %@)",company,prefix,routePrio,rateSheetId];
        NSArray *resultSearch = [filteredRouting filteredArrayUsingPredicate:predicate];
        if ([resultSearch count] == 0) [filteredRouting addObject:route];
    }
    uids = nil;
    return [NSArray arrayWithArray:filteredRouting];
}

-(BOOL) insertNewCode:(NSString *)code  forDate:(NSString *)date forRate:(NSString *)rate  forRateSheetID:(NSString *)rateSheetID forCountry:(NSString *)country forSpecific:(NSString *)specific;
{
    NSString *rmin = @"0";NSString *reach = @"1";
    
    if ([code rangeOfString:@"52" options:0 range:NSMakeRange(0, code.length)].length != 0) { rmin = @"60"; reach = @"60"; }
    
    NSString *finalCountryString = nil;
    
    if (specific) {
        NSString *countryNew = [country stringByReplacingOccurrencesOfString:@"'" withString:@" "];
        NSString *specificNew = [specific stringByReplacingOccurrencesOfString:@"'" withString:@" "];
        finalCountryString = [NSString stringWithFormat:@"%@/%@ - inserted by SNOW",countryNew,specificNew];
    } else {
        NSString *countryNew = [country stringByReplacingOccurrencesOfString:@"'" withString:@" "];
        finalCountryString = [NSString stringWithFormat:@"%@ - inserted by SNOW",countryNew];
    }
    
    NSArray *insertId = [self insertWithQuery:[NSString stringWithFormat:@"insert into InDefaultPrice (code,country,price,uid,rmin,reach,chdate,enabled,minDigits,maxDigits) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');",code,finalCountryString,rate,rateSheetID,rmin,reach,date,@"y",@"1",@"25"]];
                         
    if ([[insertId objectAtIndex:1] intValue] != 1) { 
        // mysql error, code presented 
        [self deleteWithQuery:[NSString stringWithFormat:@"delete from InDefaultPrice where code=%@ and uid=%@",code,rateSheetID]];
        insertId = [self insertWithQuery:[NSString stringWithFormat:@"insert into InDefaultPrice (code,country,price,uid,rmin,reach,chdate,enabled,minDigits,maxDigits) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');",code,finalCountryString,rate,rateSheetID,rmin,reach,date,@"y",@"1",@"25"]];

    }
    if ([[insertId objectAtIndex:1] intValue] == 0) return NO;
    else return YES;
}

-(NSNumber *) createNewGroup:(NSDictionary *)outPeerGroup;
{        
    // outPeerGroup DICTIONARY(id,name, outPeerList -> ARRAY(outId, routePrio, firstName, secondName, tag ))

    //[NSNumber numberWithBool:YES],@"selected", destination.carrier.name, @"firstName",destination.rate,@"secondName", destination.lastUsedACD,@"tag",destination.lastUsedCallAttempts,@"routePrio",outCode.peerID,@"peerID", nil]];
    NSNumber *insertedGroupId = [[self insertWithQuery:[NSString stringWithFormat:@"insert into OutGroupNames set name='%@';",[outPeerGroup valueForKey:@"name"]]]objectAtIndex:0];
    NSArray *outPeers = [outPeerGroup valueForKey:@"outPeerList"];
    //NSLog(@"MYSQL: outPeers for new group is :%@", outPeers);

    for (NSDictionary *outPeer in outPeers){ 
        //NSLog(@"MYSQL: insert out peer gid=%@, outId=%@ ",insertedGroupId,[outPeer valueForKey:@"peerID"]);
        [self insertWithQuery:[NSString stringWithFormat:@"insert into OutGroupPeers set gid=%@, outId=%@;",insertedGroupId,[outPeer valueForKey:@"peerID"]]];
    }

    //NSLog(@"MYSQL:group was created with id:%@",insertedGroupId);
    return insertedGroupId;
}

-(NSString *) insertNewInpeerForCarrier:(NSString *)carrier 
                        withRateSheetID:(NSString *)rateSheetID 
                        withIPAddresses:(NSString *)ipAddressesList 
                             withPrefix:(NSString *)prefix 
                            withCountry:(NSString *)country 
                           withSpecific:(NSString *)specific 
                           withCodeList:(NSArray *)codesList 
                     withOutPeersGroups:(NSArray *)outPeersGroups 
                                forRate:(NSString *)rate;
{
    
    NSArray *unames = [self fetchNamedAllWith:[NSString stringWithFormat:@"select uname from Users where company = '%@'",carrier]];
    NSDictionary *unameDict = [unames lastObject];
    NSString *uname = [unameDict valueForKey:@"uname"];
    NSString *rateSheetsUid = [[[self fetchNamedAllWith:[NSString stringWithFormat:@"select uid from RateSheets where id = %@",rateSheetID]] lastObject] valueForKey:@"uid"];
    NSString *rulesId = [[[self fetchNamedAllWith:[NSString stringWithFormat:@"select id from Rules where price = %@",rateSheetsUid]] lastObject] valueForKey:@"id"];
    NSString *ruleSetsId = [[[self fetchNamedAllWith:[NSString stringWithFormat:@"select id from RuleSets where rule = %@",rulesId]] lastObject] valueForKey:@"id"];

    // TOTAL allowed lenght is 22, format is CountrySpecific_FirstCode_CarrierFirst2AndLast2 symbols 
    NSString *carrierNameForInsert = [NSString stringWithFormat:@"%@%@",[carrier substringToIndex:2],[carrier substringFromIndex:[carrier length] - 2]]; 

    NSString *firstCode = [codesList objectAtIndex:0];
    NSString *countryAndSpecific = [NSString stringWithFormat:@"%@%@",country,specific];
    NSUInteger countryAndSpecificCut = 15 - [firstCode length];
    if (countryAndSpecificCut > [countryAndSpecific length]) countryAndSpecificCut = [countryAndSpecific length];
    NSString *countryPlusName = [countryAndSpecific substringToIndex:countryAndSpecificCut];
    NSString *inPeerName = [NSString stringWithFormat:@"%@_%@_%@",countryPlusName,firstCode,carrierNameForInsert];

    NSUInteger indexCarrierCut = 15 - [firstCode length];
    if (indexCarrierCut > [carrierNameForInsert length]) indexCarrierCut = [carrierNameForInsert length];
    NSString *tag = [NSString stringWithFormat:@"%@_%@",firstCode,[carrierNameForInsert substringToIndex:indexCarrierCut]];
        
    NSArray *result = [self fetchNamedAllWith:[NSString stringWithFormat:@"select class from ANumReplaceClasses where name = '%@'",carrier]];
    NSDictionary *resultDict = [result lastObject];
    NSString *anumReplaceClassId = [resultDict valueForKey:@"class"];
    if (!anumReplaceClassId) { 
        NSLog(@"MYSQL: anumReplaceClass for carrier:%@ not found",carrier); 
        return nil; 
    }
    
    result = [self insertWithQuery:[NSString stringWithFormat:@"insert into InPeers set name='%@', uname='%@', ruleSet = %@, allRoutes = '%@', minDigits = %@, maxDigits = %@, sigOptions = %@, tag = '%@', profitOptionsClass = %@,aNumReplaceClass = %@, yn = 'y'",inPeerName,uname,ruleSetsId,@"n",@"1",@"25",@"12",tag,@"2",anumReplaceClassId]];
    NSNumber *inPeerID = [result objectAtIndex:0];
    NSString *inPeerIDStr = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    if ([inPeerID intValue] == 0) {
        // maybe inpeer is already there? :
        NSArray *inpeers = [self fetchNamedAllWith:[NSString stringWithFormat:@"select id from InPeers where name='%@'",inPeerName]];
        
        inPeerIDStr = [[inpeers lastObject] valueForKey:@"id"];
        
        if ([inPeerIDStr length] != 0) {
            //ok, some inpeer already there
            //rename it
            //BOOL updateOK = NO;
            [formatter setDateFormat:@"mm-HH-MM-dd-yyyy"];
            NSString *newName = [formatter stringFromDate:[NSDate date]];
            NSArray *resultQuery = [self insertWithQuery:[NSString stringWithFormat:@"update InPeers set name='%@' where id = %@",newName,inPeerIDStr]];
            if ([[resultQuery objectAtIndex:1] intValue] == 0) NSLog(@"MYSQL:cant update inpeer for id:%@",inPeerIDStr);
            //else updateOK=  YES;

            // delete previous ips 
            //[self deleteWithQuery:[NSString stringWithFormat:@"delete from InPeerGWS where peer = %@",inPeerIDStr]];
            //[self deleteWithQuery:[NSString stringWithFormat:@"delete from AllowedGroups where ip = %@ and prefix = %@",inPeerIDStr]];
            result = [self insertWithQuery:[NSString stringWithFormat:@"insert into InPeers set name='%@', uname='%@', ruleSet = %@, allRoutes = '%@', minDigits = %@, maxDigits = %@, sigOptions = %@, tag = '%@', profitOptionsClass = %@,aNumReplaceClass = %@, yn = 'y'",inPeerName,uname,ruleSetsId,@"n",@"1",@"25",@"12",tag,@"2",anumReplaceClassId]];
            inPeerID = [result objectAtIndex:0];
            if ([inPeerID intValue] == 0) {
                [formatter release];
     
                return nil;
            }// so attempt was wrong, please check
            else {
                NSNumberFormatter *inPeerIDFormatterForRepeat = [[NSNumberFormatter alloc] init];
                [inPeerIDFormatterForRepeat setFormat:@"#"];
                inPeerIDStr = [inPeerIDFormatterForRepeat stringFromNumber:inPeerID];
                [inPeerIDFormatterForRepeat release], inPeerIDFormatterForRepeat = nil;
            }
        }
        // something wrong not based on inpeer duplicate
        
        else { 
            [formatter release];
            return nil;
        }
    } else {
    
        NSNumberFormatter *inPeerIDFormatter = [[NSNumberFormatter alloc] init];
        [inPeerIDFormatter setFormat:@"#"];
        inPeerIDStr = [inPeerIDFormatter stringFromNumber:inPeerID];
        [inPeerIDFormatter release], inPeerIDFormatter = nil;
    }
    
    // insert NAS
    NSArray *gws = [self fetchNamedAllWith:[NSString stringWithFormat:@"select id from gws"]];
    for (NSDictionary *gw in gws) [self insertWithQuery:[NSString stringWithFormat:@"insert into InPeerGWS set nas = %@, peer = %@",[gw valueForKey:@"id"],inPeerIDStr]];
        
    // insert IPS

    NSArray *ipAddressesArray = [ipAddressesList componentsSeparatedByString:@","];
    for (NSString *ipAddress in ipAddressesArray)
    {
        if ([ipAddress isEqualToString:@"NULL"]) { 
            NSLog(@"MYSQL: warning, IP address is NULL for codesList:%@",codesList);
            continue;
        }
        for (NSString *code in codesList)
        {
            NSString *realPrefix = [prefix stringByAppendingString:code];
            NSArray *ipAddressInsert = [self insertWithQuery:[NSString stringWithFormat:@"insert into InIPAddresses set uid='%@', ip='%@', prefix='%@', realPrefix='%@';",inPeerIDStr,ipAddress,code,realPrefix]];
            
            if ([[ipAddressInsert objectAtIndex:0] intValue] == 0){ 
                
                [self deleteWithQuery:[NSString stringWithFormat:@"delete from InIPAddresses where ip='%@' and prefix='%@';",ipAddress,code]];
                 ipAddressInsert = [self insertWithQuery:[NSString stringWithFormat:@"insert into InIPAddresses set uid='%@', ip='%@', prefix='%@', realPrefix='%@';",inPeerIDStr,ipAddress,code,realPrefix]];
                if ([[ipAddressInsert objectAtIndex:0] intValue] == 0) NSLog(@"MYSQL:cant insert into InIPAddresses set uid='%@', ip='%@', prefix='%@', realPrefix='%@';",inPeerIDStr,ipAddress,code,realPrefix);

            }
            [formatter setDateFormat:@"yyyy-MM-dd"];

            [self insertNewCode:code forDate:[formatter stringFromDate:[NSDate date]] forRate:rate forRateSheetID:rateSheetID forCountry:country forSpecific:specific];
            
        }
    }
    [formatter release],formatter = nil;

    // insert OutGroup

    for (NSDictionary *outPeerGroup in outPeersGroups)
    {
        // outPeerGroup DICTIONARY(id,name, outPeerList -> SET(outId, routePrio, firstName, secondName, tag ))
        NSArray *outpeers = [outPeerGroup valueForKey:@"outPeerList"];
        NSNumber *resultOfCreate;
        if (![[outpeers lastObject] valueForKey:@"outId"]) {
            resultOfCreate = [self createNewGroup:outPeerGroup];
            [self insertWithQuery:[NSString stringWithFormat:@"insert into AllowedGroups set inId=%@, gid = %@;",inPeerIDStr,[resultOfCreate stringValue]]];
        } else { 
            
            [self insertWithQuery:[NSString stringWithFormat:@"insert into AllowedGroups set inId=%@, gid = %@;",inPeerIDStr,[outPeerGroup valueForKey:@"id"]]]; 
        }
    }
    
    return inPeerIDStr;
}

-(NSArray *) getOutGroupsListWithOutPeersListInsideForCountry:(NSString *)country forSpecific:(NSString *)specific;
{
    NSString *countrySpecific = [NSString stringWithFormat:@"%@_%@%@",country,specific,@"%"];
    NSArray *outGroupsIDsAndNames = [self fetchNamedAllWith:[NSString stringWithFormat:@"select id,name from OutGroupNames where name like '%@'",countrySpecific]];
    NSMutableArray *finalResultWithOutPeersAndOutGroupsInformation = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *outGroupIDandName in outGroupsIDsAndNames)
    {
        NSMutableDictionary *outGroupIDandNameAndArrayOutOutPeers = [NSMutableDictionary dictionaryWithDictionary:outGroupIDandName];
        
//        NSArray *outPeersList = [self fetchNamedAllWith:[NSString stringWithFormat:@"select outId, routePrio, firstName, secondName, tag from OutGroupPeers left join OutPeers on OutGroupPeers.outId = OutPeers.id where gid = %@",[outGroupIDandName valueForKey:@"id"]]];
        NSArray *outPeersList = [self fetchNamedAllWith:[NSString stringWithFormat:@"select outId, routePrio, firstName, secondName, tag, company as carrierName from OutGroupPeers left join OutPeers on OutGroupPeers.outId = OutPeers.id left join Users on OutPeers.uname=Users.uname where gid = %@",[outGroupIDandName valueForKey:@"id"]]];
        
        //NSMutableSet *outPeersListSet = [NSMutableSet setWithArray:outPeersList];
        [outGroupIDandNameAndArrayOutOutPeers setValue:outPeersList forKey:@"outPeerList"];
        
        [finalResultWithOutPeersAndOutGroupsInformation addObject:outGroupIDandNameAndArrayOutOutPeers];
    }
    // final result:id,name,routePrio, outPeerList -> Array(outId, routePrio, firstName, secondName, tag )
    return  finalResultWithOutPeersAndOutGroupsInformation;
}

-(BOOL) updateOutGroupsListWithOutPeersListInsideForOutGroup:(NSString *)outGroupID forEnabledOutPeers:(NSArray *)enabled forDisabledOutPeers:(NSArray *)disabled;
{
    __block BOOL result = YES;
    
    if (disabled) {
        [disabled enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *outPeerId = [obj valueForKey:@"outId"];
            NSArray *resultQuery = [self insertWithQuery:[NSString stringWithFormat:@"delete from OutGroupPeers where gid = %@ and outId = %@",outGroupID,outPeerId]];
            
            if ([[resultQuery objectAtIndex:1] intValue] == 0) result = NO;
            
        }];
    }
    if (enabled) {
        [enabled enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *outPeerId = [obj valueForKey:@"outId"];
            NSArray *resultQuery = [self insertWithQuery:[NSString stringWithFormat:@"insert into OutGroupPeers set gid = %@, outId = %@",outGroupID,outPeerId]];
            
            if ([[resultQuery objectAtIndex:1] intValue] == 0) result = NO;
            
        }];
    }
    
    
    return result;
}

-(BOOL) checkIfPriceWasChangesWithRateSheetID:(NSString *)rateSheetID withDate:(NSString *)date ; 
{
    NSString *query = [NSString stringWithFormat:@"select count(*) as count from InDefaultPrice where uid = '%@' and chdate > '%@'",rateSheetID,date];
    
    NSArray *price = [self fetchNamedAllWith:query];
    NSString *count = [[price lastObject] valueForKey:@"count"];
    if ([count isEqualToString:@"0"]) return NO;
    //if ([price count] > 0) return YES;
    return YES;
}

-(NSNumber *)getCTPpeerIdForCarrier:(NSString *)carrier andPeerName:(NSString *)peerName;
{
    NSArray *outGroupsIDsAndNames = [self fetchNamedAllWith:[NSString stringWithFormat:@"select id from peers where company like '%@' and peer like '%@'",carrier,peerName]];
    NSNumberFormatter *number = [[NSNumberFormatter alloc] init];
    NSString *peerId = [[outGroupsIDsAndNames lastObject] valueForKey:@"id"];
    NSNumber *peerIDNumber = [number numberFromString:peerId];
    [number release];
    return peerIDNumber;
}

-(NSArray *)getCTPdestinationsNumberForPrefix:(NSArray *)prefixes;
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    for (CountrySpecificCodeList *code in prefixes) {
        NSSet *codesList = code.codesList;
        CodesList *anyCode = codesList.anyObject;
        
        NSString *prefixForMysq = [anyCode.code.stringValue stringByAppendingString:@"%"];
        NSArray *destinationsNumbers = [self fetchNamedAllWith:[NSString stringWithFormat:@"select dstnum from results where dstnum like '%@' limit 5",prefixForMysq]];
        [destinationsNumbers enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *dstnum = [obj valueForKey:@"dstnum"];
            if (![result containsObject:dstnum]) [result addObject:dstnum];
        }];
        if ([result count] > 5) break;
    }
    NSArray *finalResult = [NSArray arrayWithArray:result];

    return finalResult;
}

-(NSNumber *)putCTPtestingTaskWithNumbers:(NSString *)numbers withCTPPeerId:(NSString *)peerID;
{
    NSArray *insertedRequestId = [self insertWithQuery:[NSString stringWithFormat:@"insert into requests set peer_id=%@, dstnums='%@',resp = 'alex';",peerID,numbers]];
    NSNumber *insertId = [insertedRequestId objectAtIndex:0];
    return insertId;
}

-(BOOL)getCTPtestingCheckResultForRequestID:(NSNumber *)requestID;
{
    NSArray *destinationsNumbers = [self fetchNamedAllWith:[NSString stringWithFormat:@"select * from requests where id = %@ and finished > 0",[requestID stringValue]]];
    if ([[destinationsNumbers lastObject] count] != 0) return YES;
    else return NO;
}

-(NSArray *)getCTPtestingResultForRequestID:(NSNumber *)requestID;
{
    //NSArray *testingResults = [self fetchNamedAllWith:[NSString stringWithFormat:@"select id,request,srcnum,dstnum,ts_invite,ts_trying,ts_ringing,ts_ok,ts_release,disconnect_code,disconnect_cause,inpack,outpack,call_id,ts from results where request = %@",[requestID stringValue]]];
    //NSArray *testingResultsData = [self fetchBinaryData:[NSString stringWithFormat:@"select id,media_ogg,media_ogg_ring from results where request = %@",[requestID stringValue]]];
    NSArray *testingResults = [self fetchBinaryData:[NSString stringWithFormat:@"select * from results where request = %@",[requestID stringValue]]];
    //NSLog(@"testing result:%@ for requestID:%@",testingResults,requestID);
    
    //NSData *ogg = [[testingResults lastObject] valueForKey:@"media_ogg"];
    //[ogg writeToFile:@"/Users/alex/te.ogg" atomically:YES];
    return testingResults;
}

-(NSArray *)getCompanyAccounts;
{
    return [self fetchNamedAllWith:[NSString stringWithFormat:@"select * from Accounts"]];
}

-(NSArray *) getInvoicesAndPaymentsForCarrier:(NSString *)carrier;
{
    NSString *carriedID = [[[self fetchNamedAllWith:[NSString stringWithFormat:@"select id from Users where company = '%@'",carrier]] lastObject] valueForKey:@"id"];
    return [self fetchNamedAllWith:[NSString stringWithFormat:@"select * from GrossBook where correspondent = '%@'",carriedID]];
}

-(NSString *)mysqlStringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateToReturn = [formatter stringFromDate:date];
    [formatter release];
    return dateToReturn;
}

-(NSString *)mysqlForPerHourStringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    NSString *dateToReturn = [formatter stringFromDate:date];
    [formatter release];
    return dateToReturn;
}


-(NSNumber *) idForInsertedInvoiceOrPaymentForCarrier:(NSString *)carrier forAccountName:(NSString *)accountName forServiceDate:(NSDate *)serviceDate forSumm:(NSNumber *)amount forInvoice:(BOOL)isInvoice forReceived:(BOOL)isReceived;
{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *sDate = [self mysqlStringFromDate:serviceDate];
    NSString *oDate = [self mysqlStringFromDate:[NSDate date]];
//    [formatter release];
    NSString *accountID = [[[self fetchNamedAllWith:[NSString stringWithFormat:@"select id from Accounts where name = '%@'",accountName]] lastObject] valueForKey:@"id"];

    NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init];
    [rateFormatter setMaximumFractionDigits:2];
    
    [rateFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [rateFormatter setDecimalSeparator:@"."];

    NSString *summ = [rateFormatter stringFromNumber:amount];
    [rateFormatter release];
    
    NSDictionary *carrierIDandResponsibleID = [[self fetchNamedAllWith:[NSString stringWithFormat:@"select id,rname from Users where company = '%@'",carrier]] lastObject];
    
    NSString *carriedID = [carrierIDandResponsibleID valueForKey:@"id"];
    NSString *responsibleID = [carrierIDandResponsibleID valueForKey:@"rname"];

    NSString *accountIDFrom = nil;
    NSString *accountIDTo = nil;
    if (isReceived) {
        accountIDFrom = @"0";
        accountIDTo = accountID;
    } else {
        accountIDFrom = accountID;
        accountIDTo = @"0";
    }
    
    NSString *invOrPayment = nil;
    if (isInvoice) invOrPayment = @"Inv"; 
        else invOrPayment = @"Pay";
    
    NSArray *insertedRequestId = [self insertWithQuery:[NSString stringWithFormat:@"insert into GrossBook (oDate,sDate,direction,what,fromAccount,toAccount,service,correspondent,defSum,comment,uname,account,fromSum,toSum) values('%@','%@','In','%@','%@','%@','1','%@','%@','posted by snow','%@','0','%@','%@');",oDate,sDate,invOrPayment,accountIDFrom,accountIDTo,carriedID,summ,responsibleID,summ,summ]];
    NSNumber *insertId = [insertedRequestId objectAtIndex:0];
    return insertId;
}

-(NSUInteger) countOfStatisticForSalePerHourForCarrier:(NSString *)carrier fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
{
    NSString *dateFrom = [self mysqlForPerHourStringFromDate:fromDate];
    NSString *dateTo = [self mysqlForPerHourStringFromDate:toDate];
    NSString *query = [NSString stringWithFormat:@"select count(*) from FinReportInCache as f  inner join InPeers as i  on i.id=f.peerId inner join Users as u on u.uname=i.uname  where  f.day >= '%@' and f.day<= '%@'  and  u.company='%@'",dateFrom,dateTo,carrier];
    NSArray *result = [self fetchNamedAllWith:query];
    NSString *count = [[result lastObject] valueForKey:@"count(*)"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *countNumber = [formatter numberFromString:count];
    [formatter release];
    return [countNumber unsignedIntegerValue];
}

-(NSUInteger) countOfStatisticWeBuyPerHourForCarrier:(NSString *)carrier fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
{
    NSString *dateFrom = [self mysqlForPerHourStringFromDate:fromDate];
    NSString *dateTo = [self mysqlForPerHourStringFromDate:toDate];
    NSString *count = [[[self fetchNamedAllWith:[NSString stringWithFormat:@"select count(*) from FinReportOutCache as f  inner join OutPeers as o  on o.id=f.peerId inner join Users as u on u.uname=o.uname  where  f.day >= '%@' and f.day<= '%@'  and  u.company='%@'",dateFrom,dateTo,carrier]] lastObject] valueForKey:@"count(*)"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *countNumber = [formatter numberFromString:count];
    [formatter release];

    return [countNumber unsignedIntegerValue];

}
@end

@implementation MySQLIXC (PrivateAPI)

/**
 * Determine whether the current host is reachable; essentially
 * whether a connection is available (no packets should be sent)
 */
- (BOOL)_isCurrentHostReachable
{
    //NSLog(@"MYSQL: checking network connectivity for queue number%@",[NSNumber numberWithUnsignedInteger:self.queneNumber]);
        // CFRelease(target);
    
    // Part 1 - Create Internet socket addr of zero
	struct sockaddr_in zeroAddr;
	bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
    
	// Part 2- Create target in format need by SCNetwork
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
    
	// Part 3 - Get the flags
	SCNetworkReachabilityFlags flags;
	SCNetworkReachabilityGetFlags(target, &flags);

    if (flags & kSCNetworkFlagsReachable){
        //NSLog(@"MYSQL: checking network connectivity for queue number%@ SUCCESS",[NSNumber numberWithUnsignedInteger:self.queneNumber]);
        return YES;
    }
    else {
        NSLog(@"MYSQL: checking network connectivity for queue number%@ FAILED",[NSNumber numberWithUnsignedInteger:self.queneNumber]);

        return NO;
    }
    CFRelease(target);
    //NSLog(@"This happened in %@ (current object class %@) at line %d in file %s in function %s in pretty function %s",
     //     NSStringFromSelector(_cmd), NSStringFromClass([self class]), __LINE__, __FILE__, __FUNCTION__, __PRETTY_FUNCTION__);

        // Return success
        
}

@end