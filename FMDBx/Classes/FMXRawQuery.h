//
// Created by Maksim Kirilovskikh on 23.09.15.
// Copyright (c) 2015 Maksim Kirilovskikh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabase.h>
#import "FMXDatabaseManager.h"


@class FMDatabase;


@interface FMXRawQuery : NSObject

@property(retain, nonatomic) FMDatabase *db;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initConnection:(FMDatabase *)db;

- (instancetype)initDefaultConnection;

- (NSArray *)rawQuery:(NSString *)sql arguments:(NSArray *)arguments converter:(NSObject *(^)(NSDictionary *rawResult))mapping;

- (NSArray *)rawQuery:(NSString *)sql arguments:(NSArray *)arguments class:(Class)class;

- (NSArray *)rawQuery:(NSString *)sql arguments:(NSArray *)arguments mappingDictionary:(NSDictionary *)mappingDictionary class:(Class)class;

@end