

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NTDateCellType) {
    NTDateCellTypeNormalDay = 0,    //普通日期
    NTDateCellTypeSelctedDay,       //选中日期
    NTDateCellTypeOtherMonsDay      //其他月份日期
};

@interface NTCalendarCell : UICollectionViewCell

@property (nonatomic, assign) NTDateCellType cellType;
@property (weak, nonatomic) IBOutlet UILabel *textLb;

@end
