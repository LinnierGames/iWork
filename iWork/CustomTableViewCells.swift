//
//  CustomTableViewCells.swift
//  iWork
//
//  Created by Erick Sanchez on 7/4/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

enum CDCustomTableViewStyle {
    case none
    case textInput
    case titleTextInput
}

protocol CustomTableViewCellDelegate {
    func customCell(_ cell: CustomTableViewCells, segmentedControlDidSelect segment: UISegmentedControl)
}

class CustomTableViewCells: UITableViewCell {
    
    var cellStyle: CDCustomTableViewStyle = .none
    
    @IBOutlet open var labelTitle: UILabel?
    
    @IBOutlet open var labelSubtitle: UILabel?
    
    @IBOutlet open var textField: UITextField?
    
    @IBOutlet open var segment: UISegmentedControl?
    
    @IBAction public func pressSegment(sender: UISegmentedControl) {
        delegate?.customCell(self, segmentedControlDidSelect: sender)
    }
    
    var delegate: CustomTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
