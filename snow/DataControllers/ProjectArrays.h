//
//  ProjectArrays.h
//  snow
//
//  Created by Alex Vinogradov on 20.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SynthesizeSingleton.h"


@interface ProjectArrays : NSObject {
    IBOutlet NSMutableArray *myCountrySpecificCodeList;
    NSMutableArray *myCountrySpecificCodeListWithClass;
    IBOutlet NSArrayController *countrySpecificCodeList;
    IBOutlet NSMutableArray *queryProgress;
    NSDictionary *dictionaryForCountryCodesResult;
    NSMutableArray *databaseConnections;
    NSMutableDictionary *dictionaryDictionaryesForCountryCodes;

}

@property (nonatomic, retain) NSMutableArray *myCountrySpecificCodeList;
@property (nonatomic, retain) NSArrayController *countrySpecificCodeList;
@property (nonatomic, retain) NSMutableArray *queryProgress;
@property (nonatomic, retain) NSMutableArray *myCountrySpecificCodeListWithClass;
@property (retain) NSDictionary *dictionaryForCountryCodesResult;
@property (retain) NSMutableArray *databaseConnections;
@property (retain) NSMutableDictionary *dictionaryDictionaryesForCountryCodes;
+(ProjectArrays *)sharedProjectArrays;

@end
