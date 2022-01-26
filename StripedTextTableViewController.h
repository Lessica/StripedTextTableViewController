//
//  StripedTextTableViewController.h
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2022/1/20.
//  Copyright © 2022 Zheng Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StripedTextTableViewController : UITableViewController

- (instancetype)initWithPath:(NSString *)path;
@property (nonatomic, copy, readonly) NSString *entryPath;

@property (nonatomic, assign) BOOL reversed;
@property (nonatomic, assign) BOOL allowTrash;
@property (nonatomic, assign) BOOL allowSearch;
@property (nonatomic, assign) BOOL tapToCopy;
@property (nonatomic, assign) BOOL pressToCopy;
@property (nonatomic, assign) BOOL preserveEmptyLines;

@property (nonatomic, copy) NSString *rowSeparator;

@end

NS_ASSUME_NONNULL_END
