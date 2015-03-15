//  Created by Stefan Thomas on 26.01.15.
//  Copyright (c) 2015 LSSiEurope. All rights reserved.
//

@interface EditPayloadItemData : NSObject
@property NSString* title;
@property NSString* subtitle;
@property NSString* icon;
@property NSString* iconcolor;

@property Class     payloadObjectClass;
@property NSObject* payloadObject;
@property BOOL      addFolder;
@end

@interface EditPayloadItemViewController : UITableViewController
@property EditPayloadItemData* item;
@end
