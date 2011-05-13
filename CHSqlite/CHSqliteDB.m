//
//  CHSqliteDB.m
//  gesture_clipboard
//
//  Created by Charz on 2011/3/23.
//  Copyright 2011年 com.chhsu. All rights reserved.
//

#import "ObjSqliteDB.h"
#import "ObjSqliteStatement.h"

#import "CHSqliteDB.h"

//#define DB_DEBUG    (1)
//#define DB_DEBUG_SQL    (1)
//#define DB_DEBUG_DETAIL (1)

static NSString* kdefaultDB = @"CHdefault.db";
static NSString* kTableSelectAll = @"SELECT * FROM %@;";
static NSString* kTableCountAll = @"SELECT count(*) FROM %@";
static NSString* kTableNameWithSelectValue = @"SELECT * FROM %@ WHERE %@ = ?;";

@implementation CHSqliteDB

@synthesize dbPath,dbName;

#ifdef DB_DEBUG
- (void) showDocumentsFile {
	CFShow([[NSFileManager defaultManager] directoryContentsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]]);	
}
#endif

#pragma mark -
#pragma mark CHSqliteDB initial function
- (id) init {
    return [self init:kdefaultDB withTable:[DBRecord class] readOnly:YES];
}


- (id) init:(NSString *)db withTable:(Class)obj readOnly:(BOOL)readonly{    
    
    if ((self = [super init]) != nil ){
        if (db) {
            dbName = [NSString stringWithString:db];
        }else{
            dbName = [NSString stringWithString:kdefaultDB];
        }

        if (!readonly) {
            dbPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],dbName];
//            NSLog(@" DB(rw) Path: %@\n", dbPath);     
#ifdef DB_DEBUG
            NSLog(@"Init DB: %@", dbName);            
#endif            
            [self createTable:obj];        
        } else {
            NSString *resourcePath = [ [NSBundle mainBundle] resourcePath];
            NSString *filePath  = [resourcePath stringByAppendingPathComponent:dbName];
            dbPath = [[NSString alloc] initWithString: filePath];
//            NSLog(@" DB(ro) Path: %@\n",  dbPath);
#ifdef DB_DEBUG
            NSLog(@"Open DB: %@", dbName);            
#endif            
        }
    }
    return self;
}

- (void)dealloc {

    [dbPath release];
    [super dealloc];
}


#pragma mark -
#pragma mark CHSqliteDB DB operating

- (void) createTable:(Class)obj {
#ifdef DB_DEBUG
    NSLog(@">>>>> createTable TABLE:%@", [obj tableName]);        
#endif    
    
    int count=0;
    NSString *queryTableSQL = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';",
                                                   [obj tableName]];

                          
    ObjSqliteStatement *statement; 
    ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:dbPath];                               
    if(db == nil) NSLog(@"The db failed to initialize. %@", dbPath);

    statement = [[ObjSqliteStatement alloc] initWithSQL:[queryTableSQL UTF8String] db:db];
    while ([statement stepAndHasNextRow]) {
       count++;
    }
    [statement release];
    statement = nil;
   
    if (!count) {
        // Create table for DB
        
        NSArray *objElements = [obj tableElements];
        NSString *elementSql = nil;
        for(NSDictionary *element in objElements){
            count++;
            elementSql = [NSString stringWithFormat:@"%@ '%@' %@%@ ", 
                          (elementSql != nil)?elementSql:@"",
                          [element valueForKey:@"name"], 
                          [element valueForKey:@"type"],
                          (count != [objElements count])?@",":@"" ];
            ;
            //        NSLog(@"sql = %@", elementSql);
        }    
        
        NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE %@ ( %@);", 
                                    [obj tableName],
                                    elementSql];
#ifdef DB_DEBUG_SQL        
        NSLog(@"CREATE SQL:\n\t\t\t\t\t\t\t\t\t\t%@\n", createTableSQL);  
#endif

        statement = [[ObjSqliteStatement alloc] initWithSQL:[createTableSQL UTF8String] db:db];
        if( ![statement step] ) NSLog(@"Create Table failure: %@", [obj tableName]);
        
        [statement release];
        statement = nil;

    } else {
#ifdef DB_DEBUG        
        NSLog(@"### TABLE Exist: %@", [obj tableName]);          
#endif        
    }
  
    [db close];
    [db release];
    db =nil;
}

- (void) dumpTable:(Class)obj{
    NSMutableArray *targetArray = [[[NSMutableArray alloc ]init]autorelease];     
    [self queryAllRecords: [obj class] toArray:targetArray];    
    for ( id e in targetArray) {
        [e dumpRecord];
    }
}

- (int) queryTableCount:(Class)obj { 
#ifdef DB_DEBUG    
    NSLog(@">>>>> queryTableCount TABLE:%@", [obj tableName]);
#endif    
    int count = 0;        
//    NSString *sql = [[[NSString alloc] initWithFormat:kTableSelectAll, [obj tableName]] autorelease];   
    NSString *sql = [[[NSString alloc] initWithFormat:kTableCountAll, [obj tableName]] autorelease];       

    ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:dbPath];
    ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:[sql UTF8String] db:db];
    if( [statement step] ){
        count = [statement intFromColumn:0];       
    }else{
        NSLog( @"Failed statement: %@", db.lastErrorMessage);
    }

    [statement release];
    statement = nil;
    
    [db close];
    [db release];
    db =nil; 
#ifdef DB_DEBUG_DETAIL       
    NSLog(@">>>>> queryTableCount cnt: %d", count);
#endif        
    return count;  
}

- (void) queryAllRecords:(Class)obj toArray:(NSMutableArray *)allrec {
#ifdef DB_DEBUG
    NSLog(@">>>>> queryAllRecords TABLE:%@", [obj tableName]);
#endif    
    
    NSArray *objElements = [obj tableElements];
    NSString *sql = [[[NSString alloc] initWithFormat:kTableSelectAll, [obj tableName]] autorelease];
    
#ifdef DB_DEBUG_SQL    
    NSLog(@"QUERY_ALL SQL:\n\t\t\t\t\t\t\t\t\t\t\t%@", sql);
    for(NSDictionary *element in objElements){
        NSLog(@" name: %@ , type: %@", [element valueForKey:@"name"], [element valueForKey:@"type"]);
    }    
#endif
    
    ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:dbPath];
    ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:[sql UTF8String] db:db];
        
    while ([statement stepAndHasNextRow]) {
        NSMutableArray *newTmp = [[NSMutableArray alloc]init];        
//        id new = nil;
        
        int i=0;
        for(NSDictionary *element in objElements){
                
            if ( [[element valueForKey:@"type"] isEqualToString:@"TEXT"] ) {
#ifdef DB_DEBUG_DETAIL                 
                NSLog(@">> TXT(%d): %@ |%@|",i, [element valueForKey:@"name"] , [statement textFromColumn:i]);
#endif          
                if([statement textFromColumn:i]){
                    [newTmp addObject:[statement textFromColumn:i]];
                }else{
                    [newTmp addObject:@""];
                }
            } else if( [[element valueForKey:@"type"] isEqualToString:@"INTEGER"] ) {
#ifdef DB_DEBUG_DETAIL                 
                NSLog(@">> INT(%d): %@ |%d|",i, [element valueForKey:@"name"],[statement intFromColumn:i]);
#endif                
                [newTmp addObject:[NSNumber numberWithInt:[statement intFromColumn:i]] ];                
            }
            i++;
        }         

//        new = [obj recordWithArray:newTmp];
        [allrec addObject:[obj recordWithArray:newTmp]];
        [newTmp release];
//        [new release];
    }

    [statement release];
    statement = nil;    
    
    [db close];
    [db release];
    db = nil;    
}

- (void) queryRecord:(Class)obj toArray:(NSMutableArray *)matchRec byValue:(NSString *)value andColume:(NSString *)col {
#ifdef DB_DEBUG    
    NSLog(@">>>>> queryRecord TABLE:%@", [obj tableName]);
#endif    
    NSArray *objElements = [obj tableElements];

    NSString *sql = [[[NSString alloc] initWithFormat:kTableNameWithSelectValue, [obj tableName], col] autorelease];
#ifdef DB_DEBUG_SQL      
    NSLog(@"QUERY_SINGLE SQL:\n\t\t\t\t\t\t\t\t\t\t\t\t%@\n", sql);
#endif    
    
    ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:dbPath];
    ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:[sql UTF8String] db:db];
    [statement bindText:value toColumn:1];    // value
    
    while ([statement stepAndHasNextRow]) {
        NSMutableArray *newTmp = [[NSMutableArray alloc]init];        
//        id new = nil;
        
        int i=0;
        for(NSDictionary *element in objElements){
            
            if ( [[element valueForKey:@"type"] isEqualToString:@"TEXT"] ) {
#ifdef DB_DEBUG_DETAIL                 
                NSLog(@">> %@ |%@|", [element valueForKey:@"name"] , [statement textFromColumn:i]);
#endif          
                if([statement textFromColumn:i]){
                    [newTmp addObject:[statement textFromColumn:i]];
                }else{
                    [newTmp addObject:@""];
                }                
            } else if( [[element valueForKey:@"type"] isEqualToString:@"INTEGER"] ) {
#ifdef DB_DEBUG_DETAIL                 
                NSLog(@">> %@ |%d|", [element valueForKey:@"name"],[statement intFromColumn:i]);
#endif                
                [newTmp addObject: [NSNumber numberWithInt:[statement intFromColumn:i]] ];                
            }
            i++;
        }         

//        new = [obj recordWithArray:newTmp];        
        [matchRec addObject:[obj recordWithArray:newTmp]];
        [newTmp release];
//        [new release];
    }
    [statement release];
    statement = nil;    
    
    [db close];
    [db release];
    db = nil;    
     
}


- (void) addRecord:(DBRecord *)record checkDuplicate:(BOOL)duplicate{
    Class obj = [record class];
#ifdef DB_DEBUG
    NSLog(@">>>>> addRecord TABLE:%@", [obj tableName]);    
#endif    
    NSArray *objElements = [obj tableElements];
    NSDictionary *primaryElement = [objElements objectAtIndex:[obj tablePrimaryKeyByIndex]];
    NSArray *recArray = [record arrayWithRecord:record];
    
#ifdef DB_DEBUG_DETAIL    
    for ( id rec in recArray ) {
        if( [[rec class] isSubclassOfClass:[NSString class]] ){
            NSLog(@"--> %@ str", rec );
        }else if ([[rec class] isSubclassOfClass:[NSNumber class]] ){
            NSLog(@"--> %d number", [rec intValue]);            
        }

    }
#endif
    
    //
    // check current record exist?
    //
    if (duplicate) {
        NSMutableArray *matchRec = [[[NSMutableArray alloc]init]autorelease];
        
        id primaryValue = [recArray objectAtIndex:[obj tablePrimaryKeyByIndex]];
        if( [[primaryValue class] isSubclassOfClass:[NSString class]] ){
            [self queryRecord:obj 
                      toArray:(NSMutableArray *)matchRec 
                      byValue:primaryValue
                    andColume:[primaryElement valueForKey:@"name"]];

        }else if ([[primaryValue class] isSubclassOfClass:[NSNumber class]] ){
            [self queryRecord:obj 
                      toArray:(NSMutableArray *)matchRec 
                      byValue:[primaryValue stringValue]
                    andColume:[primaryElement valueForKey:@"name"]];

        }else{
            NSLog(@"NOT MATCH TYPE: %@", [primaryValue class]);
        }

    #ifdef DB_DEBUG_DETAIL
        NSLog(@"## record : %d", [matchRec count]);
    #endif    
        if ([matchRec count]) {
            // found record, return 
            return;
        }
    }
    
    // Add new record to [obj tableName]   
    int count=0;
    NSString *elementSql = nil;
    for(NSDictionary *element in objElements){
        count++;
        elementSql = [NSString stringWithFormat:@"%@ ?%@", 
                      (elementSql != nil)?elementSql:@"",
                      (count != [objElements count])?@",":@"" ];
        //        NSLog(@"sql = %@", elementSql);
    }    
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(%@);", 
                     [obj tableName],
                     elementSql];
#ifdef DB_DEBUG_SQL    
    NSLog(@"ADD SQL:\n\t\t\t\t\t\t\t\t\t\t\t%@\n", sql);     
#endif
    

    ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:dbPath];
    ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:[sql UTF8String] db:db];    
    
    int i=0;
    for(NSDictionary *element in objElements){
        if ( [[element valueForKey:@"type"] isEqualToString:@"TEXT"] ){ 
#ifdef DB_DEBUG_DETAIL            
            NSLog(@">> %d: %@ |%@|",i+1, [element valueForKey:@"name"] , [recArray objectAtIndex:i]);
#endif            
            [statement bindText:[recArray objectAtIndex:i] toColumn:i+1]; 
        } else if( [[element valueForKey:@"type"] isEqualToString:@"INTEGER"] ) {
#ifdef DB_DEBUG_DETAIL                        
            NSLog(@">> %d: %@ |%d|",i+1, [element valueForKey:@"name"],[[recArray objectAtIndex:i]intValue]);
#endif            
            [statement bindInt:[[recArray objectAtIndex:i] intValue] toColumn:i+1]; 
        }
        i++;
    }         
    
    if(![statement step]) 
        NSLog( @"Failed statement: %@", db.lastErrorMessage);
    [statement release];
    statement = nil; 

    [db close];
    [db release];
    db = nil;
    
#ifdef DB_DEBUG        
    // Update rds Counter
    NSLog(@"After Add REC: %d", [self queryTableCount:obj]);
    [self showDocumentsFile];    
#endif    
    
}



- (void) deleteRecord:(DBRecord *)record{    
    Class obj = [record class];
#ifdef DB_DEBUG    
     NSLog(@">>>>> deleteRecord TABLE:%@", [obj tableName]); 
#endif   
    NSArray *objElements = [obj tableElements];
    NSDictionary *primaryElement = [objElements objectAtIndex:[obj tablePrimaryKeyByIndex]];
    NSArray *recArray = [record arrayWithRecord:record];    
    
    // Add new record to [obj tableName]   
    NSString *primaryValueString = nil;
    id primaryValue = [recArray objectAtIndex:[obj tablePrimaryKeyByIndex]];
    if( [[primaryValue class] isSubclassOfClass:[NSString class]] ){
        primaryValueString = [NSString stringWithString:primaryValue];
    }else if ([[primaryValue class] isSubclassOfClass:[NSNumber class]] ){
        primaryValueString = [NSString stringWithString:[primaryValue stringValue]];
    }else{
        NSLog(@"NOT MATCH TYPE: %@", [primaryValue class]);
    }
    
    NSString *elementSql = nil;
    elementSql = [NSString stringWithFormat:@"%@ = '%@'", 
                            [primaryElement valueForKey:@"name"],
                            primaryValueString ];
    
    NSString *deleteRecordSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@;", 
                                                             [obj tableName],
                                                             elementSql];
#ifdef DB_DEBUG_SQL    
    NSLog(@"DELETE SQL:\n\t\t\t\t\t\t\t\t\t\t\t%@\n", deleteRecordSQL);     
#endif

    ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:dbPath];
    ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:[deleteRecordSQL UTF8String] db:db];       
    if(![statement step]) 
        NSLog( @"Failed to delete statement: %@", db.lastErrorMessage);
    [statement release];
    statement = nil; 

    [db close];
    [db release];
    db = nil;    

#ifdef DB_DEBUG        
    NSLog(@"After DEL REC: %d", [self queryTableCount:obj]);
#endif    

}


- (void) updateRecord:(DBRecord *)record replacedRec:(DBRecord *)oldRec{    
    Class obj = [record class];    
#ifdef DB_DEBUG    
    NSLog(@">>>>> updateRecord TABLE:%@", [obj tableName]); 
#endif   
    NSArray *objElements = [obj tableElements];
    NSDictionary *primaryElement = [objElements objectAtIndex:[obj tablePrimaryKeyByIndex]];
    NSArray *oldRecArray = [oldRec arrayWithRecord:oldRec];
    NSArray *newRecArray = [record arrayWithRecord:record];   
    
    if ( ![newRecArray count] || ![oldRecArray count]) {
        NSLog(@"UPDATERecord failure! input data incorrect!");
        return;
    }
    
    // Add new record to [obj tableName]   
    NSString *primaryValueString = nil;
    id primaryValue = [oldRecArray objectAtIndex:[obj tablePrimaryKeyByIndex]];
    if( [[primaryValue class] isSubclassOfClass:[NSString class]] ){
        primaryValueString = [NSString stringWithString:primaryValue];
    }else if ([[primaryValue class] isSubclassOfClass:[NSNumber class]] ){
        primaryValueString = [NSString stringWithString:[primaryValue stringValue]];
    }else{
        NSLog(@"NOT MATCH TYPE: %@", [primaryValue class]);
    }
    
    NSString *pElementSql = nil;
    pElementSql = [NSString stringWithFormat:@"%@ = '%@'", 
                  [primaryElement valueForKey:@"name"],
                  primaryValueString ];
    
    int count=0;
    id eValue = nil;
    NSString *eValueString = nil;    
    NSString *elementSql = nil;
    for(NSDictionary *element in objElements){
        count++;        

        eValue = [newRecArray objectAtIndex:count-1];
        if( [[eValue class] isSubclassOfClass:[NSString class]] ){
            eValueString = [NSString stringWithString:eValue];            
        }else if ([[eValue class] isSubclassOfClass:[NSNumber class]] ){
            eValueString = [NSString stringWithString:[eValue stringValue]];
        }
    
        elementSql = [NSString stringWithFormat:@"%@ %@='%@'%@", 
                            (elementSql != nil)?elementSql:@"",
                            [element valueForKey:@"name"], 
                            eValueString,
                            (count != [objElements count])?@",":@""
                          ];
//        NSLog(@"sql = %@", elementSql);
    }        
    
    NSString *updateRecordSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@;", 
                                 [obj tableName],
                                 elementSql,
                                 pElementSql];
#ifdef DB_DEBUG_SQL    
    NSLog(@"UPDATE SQL:\n\t\t\t\t\t\t\t\t\t\t\t%@\n", updateRecordSQL); 
#endif
    
    ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:dbPath];
    ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:[updateRecordSQL UTF8String] db:db];       
    if(![statement step]) 
        NSLog( @"Failed to delete statement: %@", db.lastErrorMessage);
    [statement release];
    statement = nil; 
    
    [db close];
    [db release];
    db = nil;    
    
#ifdef DB_DEBUG        
    NSLog(@"After UPDATE REC: %d", [self queryTableCount:obj]);
#endif    
    
}



@end
