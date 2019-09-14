

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTCalendar : UIView

typedef void (^DidSelectDateHandler)(NSInteger y, NSInteger m, NSInteger d, UILabel *textLb);
@property (nonatomic, copy) DidSelectDateHandler didSelectDateHandler;

@end

NS_ASSUME_NONNULL_END
