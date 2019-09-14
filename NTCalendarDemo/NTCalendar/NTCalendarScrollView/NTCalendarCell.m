

#import "NTCalendarCell.h"
#import "ntcalendarConst.h"

@implementation NTCalendarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}


- (void)setCellType:(NTDateCellType)cellType
{
    _cellType = cellType;
    
    if (cellType == NTDateCellTypeNormalDay) {
        self.textLb.textColor = [UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1.0];
        
    } else if (cellType == NTDateCellTypeSelctedDay) {
        self.textLb.textColor = [UIColor yellowColor];
        
    } else {
        self.textLb.textColor = [UIColor colorWithRed:56/255.0 green:68/255.0 blue:97/255.0 alpha:1.0];
    }
}

@end
