//
//  public.h
//  D5大生活
//
//  Created by June801 on 15/12/24.
//  Copyright © 2015年 June801. All rights reserved.
//

#ifndef public_h
#define public_h

//NSString * const LeftMenuSelectIndex = @"LeftMenuSelectIndex";
//NSString * const LeftMenuSelectNotification = @"LeftMenuSelectNotification";

#define LeftMenuSelectIndex @"LeftMenuSelectIndex"
#define LeftMenuSelectNotification @"LeftMenuSelectNotification"

//Release 版本关闭打印
#if DEBUG
#warning NSLogs will be shown
#else
#define NSLog(...) {}
#endif

#endif /* public_h */
