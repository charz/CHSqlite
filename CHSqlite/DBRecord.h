//
//  DBRecord.h
//  iOSBibleReader
//
//  Created by Charz on 2011/4/11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBRecord : NSObject {
    
}

+ (NSString *) tableName;
+ (NSString *) tablePrimaryKey;
+ (NSInteger) tablePrimaryKeyByIndex;
+ (NSArray *) tableElements;
+ (DBRecord *) recordWithArray:(NSArray *) array;
- (void) dumpRecord;
- (NSArray *) arrayWithRecord:(DBRecord *)rec;
- (id) initWithArray: (NSArray *) content;

@end
