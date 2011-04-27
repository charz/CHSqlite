//
//  DBRecord.m
//  iOSBibleReader
//
//  Created by Charz on 2011/4/11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DBRecord.h"


@implementation DBRecord

+(NSString *) tableName{
    return @"DBRecord";
}

+(NSString *) tablePrimaryKey{
    return nil;
}

+(NSInteger) tablePrimaryKeyByIndex{
    return -1;  //bookmarkPage
}

+(NSArray *) tableElements {
        return nil;
    //    NSDictionary *title = [NSDictionary dictionaryWithObjectsAndKeys:@"bookmarkTitle", @"name",
    //                           @"TEXT", @"type",
    //                           nil];
    //    NSDictionary *detial = [NSDictionary dictionaryWithObjectsAndKeys:@"bookmarkDetial", @"name",
    //                            @"TEXT", @"type",
    //                            nil];
    //    NSDictionary *page = [NSDictionary dictionaryWithObjectsAndKeys:@"bookmarkPage", @"name",
    //                          @"INTEGER", @"type",
    //                          nil];    
    //    
    //    return [NSArray arrayWithObjects:title,detial,page, nil];
}

+(DBRecord *) recordWithArray:(NSArray *) array {
    return [[[DBRecord alloc] initWithArray:array]autorelease];
}

- (void) dumpRecord{
    NSLog(@"%@ : Empty", [DBRecord tableName]);
}

- (NSArray *) arrayWithRecord:(DBRecord *)rec {
    return nil;
//    return [NSArray arrayWithObjects:bookmarkTitle,bookmarkDetial,bookmarkPage, nil];
}

- (id) initWithArray: (NSArray *) content {
    if ((self = [super init]) != nil ){
    }
    return self;    
}

- (id) init {
    if ((self = [super init]) != nil ){       

    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

@end
