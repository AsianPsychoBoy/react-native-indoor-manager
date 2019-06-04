
#import "RNIndoorManager.h"

@implementation RNIndoorManager
RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"locationChanged", @"didUpdateRoute"];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(initService: (NSString *)apiKey apiSecret:(NSString *)apiSecret) {
    self.locationManager = [IALocationManager sharedInstance];
    self.locationManager.delegate = self;
    [self.locationManager setApiKey:apiKey andSecret:apiSecret];
	[self.locationManager startUpdatingLocation];
	NSString *verStr = IALocationManager.versionString;
	NSLog([NSString stringWithFormat:@"%@, %@", @"IA version:", verStr]);
}

RCT_EXPORT_METHOD(startWayfinding: (nonnull NSNumber *)latitude longitude: (nonnull NSNumber *)longitude floor: (nonnull NSNumber *)floor) {
	IAWayfindingRequest *request = [[IAWayfindingRequest alloc] init];
	request.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
	request.floor = 1;
	[self.locationManager startMonitoringForWayfinding:request];
}

RCT_EXPORT_METHOD(stopWayfinding) {
	
	[self.locationManager stopMonitoringForWayfinding];
}

- (void)indoorLocationManager:(IALocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    (void) manager;
    IALocation *l = locations.lastObject;
//    IARegion *f = [(IALocation *)locations.lastObject region];
	
	NSLog(@"position changed to coordinate: %.6fx%.6f", l.location.coordinate.latitude, l.location.coordinate.longitude);
//    if ([f type] == kIARegionTypeFloorPlan) {
        [self sendEventWithName:@"locationChanged" body:@{@"latitude": [NSNumber numberWithDouble:l.location.coordinate.latitude],
                                                          @"longitude": [NSNumber numberWithDouble:l.location.coordinate.longitude],
														  @"altitude":[NSNumber numberWithDouble:l.location.altitude],
														  @"floor": [NSNumber numberWithDouble:l.floor.level],
														  @"horizontalAccuracy": [NSNumber numberWithDouble:l.location.horizontalAccuracy],
														  @"verticalAccuracy": [NSNumber numberWithDouble:l.location.verticalAccuracy]
//                                                          @"atlasId": [f identifier]
                                                          }];
//    }
}

- (void)indoorLocationManager:(IALocationManager *)manager didUpdateRoute:(IARoute *)route {
	(void) manager;
	NSMutableArray *legs = [[NSMutableArray alloc] init];
	for (int i = 0; i < [route.legs count]; i++)
	{
		NSDictionary *begin = @{
			@"longitude" : @(route.legs[i].begin.coordinate.longitude),
			@"latitude" : @(route.legs[i].begin.coordinate.latitude),
			@"floor" : @(route.legs[i].begin.floor),
			@"nodeIndex" : @(route.legs[i].begin.nodeIndex)
		};
		NSDictionary *end = @{
			@"longitude" : @(route.legs[i].end.coordinate.longitude),
			@"latitude" : @(route.legs[i].end.coordinate.latitude),
			@"floor" : @(route.legs[i].end.floor),
			@"nodeIndex" : @(route.legs[i].end.nodeIndex)
		};
		NSDictionary *leg = @{
			@"begin" : begin,
			@"end" : end,
			@"length" : @(route.legs[i].length),
			@"direction" : @(route.legs[i].direction),
			@"edgeIndex" : @(route.legs[i].edgeIndex)
		};
		
		[legs addObject:leg];
	}
	
	[self sendEventWithName:@"didUpdateRoute" body:@{
													 @"route": legs
													 }];
}

@end
