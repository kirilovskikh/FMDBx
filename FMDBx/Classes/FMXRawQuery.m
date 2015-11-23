//
// Created by Maksim Kirilovskikh on 23.09.15.
// Copyright (c) 2015 Maksim Kirilovskikh. All rights reserved.
//

#import <objc/runtime.h>
#import "FMXRawQuery.h"


@implementation FMXRawQuery {

}
- (instancetype)initConnection:(FMDatabase *)db {
    self = [super init];
    if (self) {
        self.db = db;
    }

    return self;
}

- (instancetype)initDefaultConnection {
    self = [super init];
    if (self) {
        self.db = [[FMXDatabaseManager sharedManager] defaultDatabase];
    }

    return self;
}

- (NSArray *)rawQuery:(NSString *)sql arguments:(NSArray *)arguments converter:(NSObject *(^)(NSDictionary *rawResult))mapping {
    FMResultSet *resultSet = [self.db executeQuery:sql withArgumentsInArray:arguments];

    NSMutableArray *result = [[NSMutableArray alloc] init];

    while ([resultSet next]) {
        NSDictionary *resultDictionary = [resultSet resultDictionary];

        [result addObject:mapping(resultDictionary)];
    }

    return result;
}

- (NSArray *)rawQuery:(NSString *)sql arguments:(NSArray *)arguments class:(Class)class {
    FMResultSet *resultSet = [self.db executeQuery:sql withArgumentsInArray:arguments];

    NSMutableArray *mappingResult = [[NSMutableArray alloc] init];
    NSDictionary *filedDictionary = [self getFieldDictionaryByClass:class withLowerCase:NO];

    while ([resultSet next]) {
        NSObject *model = [[class alloc] init];
        NSDictionary *rawResult = [resultSet resultDictionary];

        for (NSString *key in rawResult) {
            if (filedDictionary[key]) {
                [model setValue:rawResult[key] forKey:key];
            }
        }

        [mappingResult addObject:model];
    }

    return mappingResult;
}

- (NSArray *)rawQuery:(NSString *)sql arguments:(NSArray *)arguments mappingDictionary:(NSDictionary *)mappingDictionary class:(Class)class {
    FMResultSet *resultSet = [self.db executeQuery:sql withArgumentsInArray:arguments];

    NSDictionary *columnDictionary = [resultSet columnNameToIndexMap];
    NSMutableArray *mappingResult = [[NSMutableArray alloc] init];
    NSDictionary *filedDictionary = [self getFieldDictionaryByClass:class withLowerCase:NO];

    while ([resultSet next]) {
        NSObject *model = [[class alloc] init];

        for (NSString *key in mappingDictionary) {
            NSString *objectKey = mappingDictionary[key];

            if (columnDictionary[key] && filedDictionary[objectKey]) {
                NSObject *insertObject = [resultSet objectForColumnName:key];

                [model setValue:insertObject forKey:objectKey];
            }
        }

        [mappingResult addObject:model];
    }

    return mappingResult;
}

- (NSMutableDictionary *)getFieldDictionaryByClass:(Class)class withLowerCase:(BOOL)lowerCase {
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(class, &count);

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    unsigned i;
    for (i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];

        NSString *key = lowerCase ? [name lowercaseString] : name;
        dictionary[key] = name;
    }

    free(properties);

    return dictionary;
}

@end