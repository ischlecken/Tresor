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

#define kVaultName             @"vault-test"
#define kVaultName1            @"vault-test1"
#define kVaultName2            @"vault-test2"
#define kVaultType             @"vault-type"
#define kVaultPin              @"01234567"
#define kVaultPuk              @"0123456789abcdef"

#define kPayloadItemTitle1     @"PayloadTitle1"
#define kPayloadItemSubtitle1  @"PayloadSubtitle1"
#define kPayloadItemIcon1      @"PayloadIcon1"
#define kPayloadItemIconcolor1 @"PayloadIconcolor1"
#define kPayloadItemData1      @"PayloadData1"

#define kCommitMsg  @"Initial Commit Test Message"

@interface TresorTests : XCTestCase<DecryptedMasterKeyPromiseDelegate>
@property NSMutableDictionary* decryptedMasterKeys;
@end

@implementation TresorTests

/**
 *
 */
-(PMKPromise*) decryptedMasterKey:(MasterKey*)masterKey
{ _NSLOG_SELECTOR;
  
  PMKPromise* result          = nil;
  NSString*   dictionaryKey   = [NSString stringWithFormat:@"%@:%@",masterKey.cryptoiv,masterKey.kdfsalt];
  NSData*     cachedMasterKey = [self.decryptedMasterKeys objectForKey:dictionaryKey];
  
  if( cachedMasterKey==nil )
  { result = [masterKey decryptedMasterKeyUsingPIN:kVaultPin]
    .then(^(NSData* decryptedMasterKey)
    { _NSLOG(@"cachedKey:%@",dictionaryKey);
            
      [self.decryptedMasterKeys setObject:decryptedMasterKey forKey:dictionaryKey];
      
      return [AnyPromise promiseWithValue:cachedMasterKey];
    });
  } /* of if */
  else
    result = [AnyPromise promiseWithValue:cachedMasterKey];
  
  return result;
}

/*
 *
 */
-(void) setUp
{ [super setUp];
  
  if( !gInited )
  { gInited = TRUE;
    
    self.decryptedMasterKeys = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    NSError* error = nil;
    [CryptoService sharedInstance].delegate = self;

    _TRESORCONFIG.databaseStoreName = @"testcase.sqlite";
    [[TresorFileUtil sharedInstance] deleteFileURL:[_TRESORCONFIG databaseStoreURL] didFailWithError:&error];
    [_TRESORMODEL resetCoreDataObjects];
    
    [MasterKey deleteAllKeychainMasterkeys];
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
-(void) test001CreateVault
{ XCTestExpectation* expection    = [self expectationWithDescription:@"Should reject promise with error."];
  PMKPromise*        vaultPromise = [Vault vaultObjectWithParameter:nil];
  XCTAssertNotNil(vaultPromise);
  
  vaultPromise.catch(^(NSError* error)
  { _NSLOG(@"error:%@",error);
    
    XCTAssert([error.domain isEqualToString:kTresorErrorDomain] && error.code==TresorErrorMandatoryVaultParameterNotSet,@"Unexpected error:%@",error);
    [expection fulfill];
  });
  
  [self waitForExpectationsWithTimeout:4 handler:nil];
}

/*
 *
 */
-(void) test002CreateVault
{ XCTestExpectation* expection = [self expectationWithDescription:@"Should reject promise with error."];
  VaultParameter*    vp        = [VaultParameter new];
  vp.name = kVaultName;
  vp.type = kVaultType;
  
  PMKPromise* vaultPromise = [Vault vaultObjectWithParameter:vp];
  XCTAssertNotNil(vaultPromise);
  
  vaultPromise.catch(^(NSError* error)
  { _NSLOG(@"error:%@",error);
   
    XCTAssert([error.domain isEqualToString:kTresorErrorDomain] && error.code==TresorErrorMandatoryVaultParameterNotSet,@"Unexpected error:%@",error);
    [expection fulfill];
  });
  
  [self waitForExpectationsWithTimeout:4 handler:nil];
}

/**
 *
 */
-(VaultParameter*) createVaultParameter
{ VaultParameter* vp = [VaultParameter new];
  vp.name = kVaultName;
  vp.type = kVaultType;
  vp.pin  = kVaultPin;
  vp.puk  = kVaultPuk;

  return vp;
}

/*
 *
 */
-(void) test003CreateVault
{ XCTestExpectation* expection    = [self expectationWithDescription:@"Should be a Vault object."];
  VaultParameter*    vp           = [self createVaultParameter];
  PMKPromise*        vaultPromise = [Vault vaultObjectWithParameter:vp];
  XCTAssertNotNil(vaultPromise);
  
  vaultPromise.then(^(Vault* vault)
  { XCTAssert([vault isKindOfClass:[Vault class]], @"Should be a Vault object.");
    
    [expection fulfill];
  })
  .catch(^(NSError* error)
  { _NSLOG(@"error:%@",error);
   
    XCTAssertFalse(error,@"Unexpected error:%@",error);
    [expection fulfill];
  });
  
  [self waitForExpectationsWithTimeout:20 handler:nil];
}

/*
 *
 */
-(void) test004CreateVaultWithSameName
{ XCTestExpectation* expection    = [self expectationWithDescription:@"Should reject promise with error."];
  VaultParameter*    vp           = [self createVaultParameter];
  PMKPromise*        vaultPromise = [Vault vaultObjectWithParameter:vp];
  XCTAssertNotNil(vaultPromise);
  
  vaultPromise.catch(^(NSError* error)
  { _NSLOG(@"error:%@",error);
    
    XCTAssert([error.domain isEqualToString:kTresorErrorDomain] && error.code==TresorErrorVaultNameShouldBeUnique,@"Unexpected error:%@",error);

    [expection fulfill];
  });
  
  [self waitForExpectationsWithTimeout:4 handler:nil];
}


/*
 *
 */
- (void)test010FindVault
{ NSError* error = nil;
  
  Vault* v = [Vault findVaultByName:kVaultName andError:&error];
  
  XCTAssertNotNil(v,@"Vault %1$@ not found, error is %2$@",kVaultName,error);
  
  XCTAssertTrue([v.vaultname isEqualToString:kVaultName],@"Wrong vaultname");
  XCTAssertTrue([v.vaulttype isEqualToString:kVaultType],@"Wrong vaulttype");
}

/**
 *
 */
-(void) test011AllVaults
{ XCTestExpectation* expection    = [self expectationWithDescription:@"Array of vaults should contain three items."];
  VaultParameter*    vp           = [self createVaultParameter];
  PMKPromise*        vaultPromise = [Vault vaultObjectWithParameter:vp];
  XCTAssertNotNil(vaultPromise);
  
  vaultPromise
  .then(^(Vault* vault)
  { XCTAssert([vault isKindOfClass:[Vault class]], @"Should be a Vault object.");
  
    vp.name = kVaultName1;
    
    return [Vault vaultObjectWithParameter:vp];
  })
  .then(^(Vault* vault)
  { XCTAssert([vault isKindOfClass:[Vault class]], @"Should be a Vault object.");
    
    vp.name = kVaultName2;
    
    return [Vault vaultObjectWithParameter:vp];
  })
  .then(^(Vault* vault)
  { XCTAssert([vault isKindOfClass:[Vault class]], @"Should be a Vault object.");
    
    NSError* error  = nil;
    NSArray* vaults = [Vault allVaults:&error];
    
    XCTAssertNotNil(@"vaults");
    XCTAssertTrue(vaults.count==3);
    
    [expection fulfill];
  })
  .catch(^(NSError* error)
  { _NSLOG(@"error:%@",error);
           
    XCTAssertFalse(error,@"Unexpected error:%@",error);
    [expection fulfill];
  });
  
  [self waitForExpectationsWithTimeout:600 handler:nil];
}

/**
 *
 */
-(Commit*) createInitial:(Vault*)vault withCommitMessage:(NSString*)commitMsg
{ NSError* error         = nil;
  Commit*  initialCommit = [vault useOrCreateNextCommit:&error];
  
  XCTAssertNotNil(initialCommit);
  
  initialCommit.message = kCommitMsg;
  
  vault.commit = initialCommit;
  
  XCTAssertTrue([_MOC save:&error]);
  
  return initialCommit;
}

/**
 *
 */
-(void) test020CreateCommit
{ XCTestExpectation* expection    = [self expectationWithDescription:@"Create initial commit."];
  VaultParameter*    vp           = [self createVaultParameter];
  PMKPromise*        vaultPromise = [Vault vaultObjectWithParameter:vp];
  XCTAssertNotNil(vaultPromise);
  
  vaultPromise
  .then(^(Vault* vault)
  { XCTAssert([vault isKindOfClass:[Vault class]], @"Should be a Vault object.");
    
    [self createInitial:vault withCommitMessage:kCommitMsg];
    
    NSError* error         = nil;
    Vault*   v             = [Vault findVaultByName:vp.name andError:&error];
    XCTAssertNotNil(v);
    
    Commit*  c             = v.commit;
    XCTAssertNotNil(c);
    XCTAssertEqual(c.message, kCommitMsg);
    
    [expection fulfill];
  })
  .catch(^(NSError* error)
  { _NSLOG(@"error:%@",error);
   
    XCTAssertFalse(error,@"Unexpected error:%@",error);
    [expection fulfill];
  });
  
  [self waitForExpectationsWithTimeout:60 handler:nil];
}

/**
 *
 */
-(void) test021AddPayloadItem
{ XCTestExpectation* expection    = [self expectationWithDescription:@"Add Payload Item."];
  VaultParameter*    vp           = [self createVaultParameter];
  PMKPromise*        vaultPromise = [Vault vaultObjectWithParameter:vp];
  NSIndexPath*       path         = [NSIndexPath new];
  XCTAssertNotNil(vaultPromise);
  
  vaultPromise
  .then(^(Vault* vault)
  { XCTAssert([vault isKindOfClass:[Vault class]], @"Should be a Vault object.");
    
    [self createInitial:vault withCommitMessage:kCommitMsg];
    
    NSError* error         = nil;
    Vault*   v             = [Vault findVaultByName:vp.name andError:&error];
    XCTAssertNotNil(v);
    
    Commit*  c             = v.commit;
    XCTAssertNotNil(c);
    XCTAssertEqual(c.message, kCommitMsg);
  
    return [c addPayloadItemWithTitle:kPayloadItemTitle1
                          andSubtitle:kPayloadItemSubtitle1
                              andIcon:kPayloadItemIcon1
                         andIconColor:kPayloadItemIconcolor1
                            andObject:kPayloadItemData1
                              forPath:path];
  })
  .then(^(Commit* changedCommit)
  { NSError* error = nil;
   
    XCTAssertTrue( [_MOC save:&error] );
    
    return [changedCommit parentPathForPath:path];
  })
  .then(^(NSArray* parentPath)
  { id decryptedPayload = [[parentPath firstObject] decryptedPayload];
    
    XCTAssertTrue( [decryptedPayload isKindOfClass:[PayloadItemList class]] );
    
    PayloadItemList* plil = (PayloadItemList*)decryptedPayload;
    PayloadItem*     pli  = [plil objectAtIndex:[plil count]-1];
    
    XCTAssertEqual(pli.title    , kPayloadItemTitle1);
    XCTAssertEqual(pli.subtitle , kPayloadItemSubtitle1);
    XCTAssertEqual(pli.icon     , kPayloadItemIcon1);
    XCTAssertEqual(pli.iconcolor, kPayloadItemIconcolor1);
    
    NSError* error   = nil;
    Payload* payload = [pli payload:&error];
    
    XCTAssertNotNil(payload);
    
    return [[CryptoService sharedInstance] decryptPayload:payload];
  })
  .then(^(id decryptedPayload)
  { XCTAssertTrue( [decryptedPayload isKindOfClass:[NSString class]] );
    XCTAssertEqual(decryptedPayload, kPayloadItemData1);
    
    [expection fulfill];
  })
  .catch(^(NSError* error)
  { _NSLOG(@"error:%@",error);
   
    XCTAssertFalse(error,@"Unexpected error:%@",error);
    [expection fulfill];
  });
  
  [self waitForExpectationsWithTimeout:60 handler:nil];
}


/*
 *
 */
- (void)test999PerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
