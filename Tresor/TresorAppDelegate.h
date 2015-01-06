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
#define _HUDCOLOR                 [UIColor colorWithRed:255.0/255.0 green:84.0/255.0 blue:0 alpha:0.6]

@interface TresorAppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic,strong) UIWindow* window;
@end
