import { EventSubscriptionVendor } from 'react-native';

export interface IndoorManager extends EventSubscriptionVendor {
	initService(apiKey: string, apiSecret: string): void;
	requestWayFinding(latitude: number, longitude: number, floor: number): void;
	stopWayFinding(): void;
}

export const IndoorManager: IndoorManager;

export interface IALocation {
	latitude: number;
	longitude: number;
	altitude: number;
	floor: number;
	horizontalAccuracy: number;
	verticalAccuracy: number;
}

export interface IARouteLeg {}

export type IARoute = IARouteLeg[];
