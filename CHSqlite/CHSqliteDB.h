//
//  CHSqliteDB.h
//  gesture_clipboard
//
//  Created by Charz on 2011/3/23.
//  Copyright 2011年 com.chhsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRecord.h"


@interface CHSqliteDB : NSObject {
    NSString *dbName;
    NSString *dbPath;
}
@property (nonatomic, retain) NSString *dbName;
@property (nonatomic, retain) NSString *dbPath;


- (id) init;
- (id) init:(NSString *)db withTable:(Class)obj readOnly:(BOOL)readonly;

- (void) createTable:(Class)obj;
- (int) queryTableCount:(Class)obj; 


- (void) dumpTable:(Class)obj;
- (void) queryAllRecords:(Class)obj toArray:(NSMutableArray *)allrec;
- (void) queryRecord:(Class)obj toArray:(NSMutableArray *)matchRec byValue:(NSString *)value andColume:(NSString *)col;


- (void) addRecord:(DBRecord *)record checkDuplicate:(BOOL)duplicate;
- (void) deleteRecord:(DBRecord *)record;
- (void) updateRecord:(DBRecord *)record replacedRec:(DBRecord *)oldRec;

@end
