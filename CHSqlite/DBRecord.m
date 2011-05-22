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
//    NSLog(@"%@ : %d - %@, %d, %d, %d, %d  ", [WardrobeDBR tableName], 
//          [wType intValue], wId, 
//          [wSeason intValue], [wOccasion intValue], 
//          [wFavorite intValue], [wCount intValue]);    
}

- (NSArray *) arrayWithRecord:(DBRecord *)rec {
    return nil;
//    return [NSArray arrayWithObjects:wType, wId, wSeason, wOccasion, wFavorite, wCount, nil];
}

- (id) initWithArray: (NSArray *) content {
    if ((self = [super init]) != nil ){
//        wType = [[content objectAtIndex:0] retain];
//        wId = [[content objectAtIndex:1] retain];
//        wSeason = [[content objectAtIndex:2] retain];
//        wOccasion = [[content objectAtIndex:3] retain];
//        wFavorite = [[content objectAtIndex:4] retain];          
//        wCount = [[content objectAtIndex:5] retain];         
    }
    return self;    
}

- (id) init {
    if ((self = [super init]) != nil ){       
//        wType = nil;
//        wId = nil;
//        wSeason = nil;
//        wOccasion = nil;
//        wFavorite = nil;          
//        wCount = nil;   
    }
    return self;
}

- (void)dealloc {
//    [wType release];
//    [wId release];
//    [wSeason release];
//    [wOccasion release];
//    [wFavorite release];          
//    [wCount release];       
    [super dealloc];
}

@end
