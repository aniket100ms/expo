// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI37_0_0EXConstantsBinding.h"
#import "ABI37_0_0EXUnversioned.h"

@interface ABI37_0_0EXConstantsBinding ()

@property (nonatomic, strong) NSString *appOwnership;
@property (nonatomic, strong) NSString *experienceId;
@property (nonatomic, strong) NSDictionary *unversionedConstants;

@property (nonatomic, weak) id<ABI37_0_0EXConstantsDeviceInstallUUIDManager> deviceInstallUUIDManager;

@end

@implementation ABI37_0_0EXConstantsBinding : ABI37_0_0EXConstantsService

- (instancetype)initWithExperienceId:(NSString *)experienceId andParams:(NSDictionary *)params deviceInstallUUIDManager:(id<ABI37_0_0EXConstantsDeviceInstallUUIDManager>)deviceInstallUUIDManager
{
  if (self = [super init]) {
    _experienceId = experienceId;
    _unversionedConstants = params[@"constants"];
    _deviceInstallUUIDManager = deviceInstallUUIDManager;
    if (_unversionedConstants && _unversionedConstants[@"appOwnership"]) {
      _appOwnership = _unversionedConstants[@"appOwnership"];
    }
  }
  return self;
}

- (NSDictionary *)constants
{
  NSMutableDictionary *constants = [[super constants] mutableCopy];

  [constants setValue:[self expoClientVersion] forKey:@"expoVersion"];

  BOOL isDetached = NO;
#ifdef ABI37_0_0EX_DETACHED
  isDetached = YES;
#endif

  constants[@"isDetached"] = @(isDetached);
  
  if (_unversionedConstants) {
    [constants addEntriesFromDictionary:_unversionedConstants];
  }

  if ([constants[@"appOwnership"] isEqualToString:@"expo"]) {
    NSMutableDictionary *platform = [constants[@"platform"] mutableCopy];
    NSMutableDictionary *ios = [platform[@"ios"] mutableCopy];
    [ios setValue:[NSNull null] forKey:@"buildNumber"];
    [platform setValue:ios forKey:@"ios"];
    [constants setValue:platform forKey:@"platform"];
  }

  return constants;
}

- (NSString *)expoClientVersion
{
  NSString *expoClientVersion = _unversionedConstants[@"expoRuntimeVersion"];
  if (expoClientVersion) {
    return expoClientVersion;
  } else {
    // not correct in standalone apps
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  }
}

- (NSString *)installationId
{
  return [_deviceInstallUUIDManager deviceInstallUUID];
}

@end
