/*
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/.
 *
 * Copyright (c) 2014 ischlecken.
 */

#define _APPDELEGATE              ((TresorAppDelegate*) [UIApplication sharedApplication].delegate)
#define _APPWINDOW                _APPDELEGATE.window
#define _DUMMYPASSWORD            [NSData dataWithUTF8String:@"01234567891123456789212345678931"]

@class Vault;
@class Payload;

@interface TresorAppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic,strong         ) UIWindow*            window;
@property(nonatomic,strong,readonly) NSString*            appName;
@property(nonatomic,strong,readonly) NSString*            appVersion;
@property(nonatomic,strong,readonly) NSString*            appBuild;
@property(nonatomic,strong         ) Vault*               vault;
@end
