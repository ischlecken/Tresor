//
//  TresorTests.m
//  TresorTests
//
//  Created by Feldmaus on 22.11.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

BOOL gInited = FALSE;

#define kVaultName @"vault-test"
#define kVaultType @"vault-type"

@interface TresorTests : XCTestCase

@end

@implementation TresorTests

/*
 *
 */
-(void) setUp
{ [super setUp];
  
  if( !gInited )
  { gInited = TRUE;
    
    NSError* error = nil;

    _TRESORCONFIG.databaseStoreName = @"testcase.sqlite";
    [[TresorFileUtil sharedInstance] deleteFileURL:[_TRESORCONFIG databaseStoreURL] didFailWithError:&error];
    [_TRESORMODEL resetCoreDataObjects];
  } /* of if */
}

/*
 *
 */
-(void) tearDown
{
  [super tearDown];
}


/*
 *
 */
-(void) test01CreateVault
{ XCTestExpectation* expection = [self expectationWithDescription:@"Should be a Vault object."];
  
  VaultParameter* vp = [VaultParameter new];
  vp.name = kVaultName;
  vp.type = kVaultType;
  
  PMKPromise* vaultPromise = [Vault vaultObjectWithParameter:vp];
  
  vaultPromise.then(^(Vault* vault)
  { XCTAssert([vault isKindOfClass:[Vault class]], @"Should be a Vault object.");
    
    [expection fulfill];
  });
  
  [self waitForExpectationsWithTimeout:5 handler:nil];
}


/*
 *
 */
- (void)test02FindVault
{ NSError* error = nil;
  
  Vault* v = [Vault findVaultByName:kVaultName andError:&error];
  
  XCTAssertNotNil(v,@"Vault %1$@ not found, error is %2$@",kVaultName,error);
  
  XCTAssertTrue([v.vaultname isEqualToString:kVaultName],@"Wrong vaultname");
  XCTAssertTrue([v.vaulttype isEqualToString:kVaultType],@"Wrong vaulttype");
}

/*
 *
 */
- (void)test99PerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
