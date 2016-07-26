//
//  KeyboardViewController.swift
//
//  Created by Thomas Prezioso on 7/5/16.
//  Copyright (c) 2016 Thomas Prezioso. All rights reserved.
//

import UIKit
import Social
import Accounts

extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    
    var uppercaseFirst: String {
        return first.uppercaseString + String(characters.dropFirst())
    }
}

private class whiteStatusBarVC: UIViewController {
    private override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

class BLUKeyboardViewController: UIInputViewController, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var capsLockOn = true
    var topRow: UIView!
    var middleRow: UIView!
    var bottomRow: UIView!
    var lastRow: UIView!
    var numberRow: UIView!
    var characterOneRow: UIView!
    var characterTwoRow: UIView!
    var didPressCharacter: Bool!
    var didRotateView: Bool!
    var lexicon: UILexicon!
    var currentString: String!
    var didTapSpaceForSpellCheck: Bool!
    var popoverView: UIView!
    var alertView: UIView!
    var refreshControl: UIRefreshControl!
    var tableView:UITableView!
    var dataSource = [AnyObject]()
    var hasAccessToTwiter: Bool!
    var didGetInfo: Bool!
    var newView: UIView!
    var pickSocialView: UIView!
    var topView: UIView!
    var bottomView: UIView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        setupViews()
        view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("PORTRAIT!!!!!\(view.frame.size.width) X \(view.frame.size.height)")
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UIScreen.mainScreen().bounds.size.width > UIScreen.mainScreen().bounds.size.height {
            didRotateView = true
            setUpViewConstraints()
            print("LANDSCAPE!!!!!\(view.frame.size.width) X \(view.frame.size.height)")
        }
    }

    func setupViews() {
        didPressCharacter = false
        didRotateView = false
        setupViewHeight()
        
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let numbersButton = createButtons(numbers)
        self.numberRow = UIView(frame: CGRectMake(0,0, view.frame.size.width, 40))
        
        let characterOne = ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")"]
        let characterButtons = createButtons(characterOne)
        self.characterOneRow = UIView(frame: CGRectMake(0,0, view.frame.size.width, 40))
        
        let characterTwo = [",", "<", ">", "?", "/", ":", ";", "+", "=", "-"]
        let characterButtons2 = createButtons(characterTwo)
        self.characterTwoRow = UIView(frame: CGRectMake(0,0, view.frame.size.width, 40))
        self.characterTwoRow.hidden = true
        
        let topButtonTitles = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttons = createButtons(topButtonTitles)
        self.topRow = UIView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height / 3))
        
        let middleRowTitles = ["A","S","D","F","G","H","J","K","L"]
        var middleButtons = createButtons(middleRowTitles)
        self.middleRow = UIView(frame: CGRectMake(0,0, view.frame.size.width, 40))
        
        let bottomRowTitles = ["Z","X","C","V","B","N","M"]
        var bottomRowButtons = createButtons(bottomRowTitles)
        self.bottomRow = UIView(frame: CGRectMake(0, 0,view.frame.size.width, 40))
        
        self.lastRow = UIView(frame: CGRectMake(0,0, view.frame.size.width, 40))
        var lastRowButtons: [UIButton] = [UIButton]()
        let returnButton = createReturn("⏎")
        let period = createPeriod()
        let spaceButton = createSpace()
        let changeKeyboard = createChangeKeyboard()
        let changeCharacter = createChangeCharacters()
        let popupmenu = popUpAction()
        
        middleButtons.append(popupmenu)
        lastRowButtons.append(changeCharacter)
        lastRowButtons.append(changeKeyboard)
        lastRowButtons.append(spaceButton)
        lastRowButtons.append(period)
        lastRowButtons.append(returnButton)
        
        self.characterOneRow.translatesAutoresizingMaskIntoConstraints = false
        self.characterTwoRow.translatesAutoresizingMaskIntoConstraints = false
        self.topRow.translatesAutoresizingMaskIntoConstraints = false
        self.middleRow.translatesAutoresizingMaskIntoConstraints = false
        self.bottomRow.translatesAutoresizingMaskIntoConstraints = false
        self.lastRow.translatesAutoresizingMaskIntoConstraints = false
        self.numberRow.translatesAutoresizingMaskIntoConstraints = false
        
        let backspace = createBackSpaceButton("🔙")
        bottomRowButtons.append(backspace)
        
        let shift = createShiftButton("↑")
        bottomRowButtons.insert(shift, atIndex: 0)
        
        for button in numbersButton {
            numberRow.addSubview(button)
        }
        
        for button in characterButtons {
            characterOneRow.addSubview(button)
        }
        
        for button in characterButtons2 {
            characterTwoRow.addSubview(button)
        }
        
        for button in buttons {
            topRow.addSubview(button)
        }
        
        for button in middleButtons {
            middleRow.addSubview(button)
        }
        
        for button in bottomRowButtons {
            bottomRow.addSubview(button)
        }
        
        for button in lastRowButtons {
            lastRow.addSubview(button)
        }

        self.view.addSubview(numberRow)
        self.view.addSubview(characterOneRow)
        self.view.addSubview(characterTwoRow)
        self.view.addSubview(topRow)
        self.view.addSubview(middleRow)
        self.view.addSubview(bottomRow)
        self.view.addSubview(lastRow)
        setUpViewConstraints()
        addConstraints(numbersButton, containingView: numberRow)
        addConstraints(characterButtons, containingView: characterOneRow)
        addConstraints(characterButtons2, containingView: characterTwoRow)
        addConstraints(buttons, containingView: topRow)
        addConstraints(middleButtons, containingView: middleRow)
        addConstraints(bottomRowButtons, containingView: bottomRow)
        addConstraintsForLastLine(lastRowButtons, containingView: lastRow)
    }

    //MARK: Creating of Special Buttons
    func createButtons(titles: [String]) -> [UIButton] {
        var buttons = [UIButton]()
        for title in titles {
            let button = UIButton(type: .System) as UIButton
            button.setTitle(title, forState: .Normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
            button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            button.addTarget(self, action: #selector(BLUKeyboardViewController.keyPressed(_:)), forControlEvents: .TouchUpInside)
            buttons.append(button)
        }
        return buttons
    }

    func createBackSpaceButton(title: String) -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle(title, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.backSpacePressed(_:)), forControlEvents: .TouchUpInside)
        return button
    }

    func createShiftButton(title: String) -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle(title, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.capsLockPressed(_:)), forControlEvents: .TouchUpInside)
        return button
    }
    
    func createReturn(title: String) -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle(title, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.returnPressed(_:)), forControlEvents: .TouchUpInside)
        return button
    }
    
    func createPeriod() -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle(".", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.keyPressed(_:)), forControlEvents: .TouchUpInside)
        return button
    }
    
    func createSpace() -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle(" ", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white:  1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.spacePressed(_:)), forControlEvents: .TouchUpInside)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.doubleTapSpaceAction(_:)), forControlEvents: .TouchDownRepeat)
        return button
    }

    func createChangeKeyboard() -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle("🌐", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white:  1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.nextKeyboardPressed(_:)), forControlEvents: .TouchUpInside)
        return button
    }
    
    func createChangeCharacters() -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle("1/2", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.charSetPressed(_:)), forControlEvents: .TouchUpInside)
        return button
    }

    func popUpAction() -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle("📫", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.showAlertWasTapped(_:)), forControlEvents: .TouchUpInside)
        return button
    }
  
    func closeAlertButton() -> UIButton {
        var button = UIButton(type: .System) as UIButton
        button.setTitle("", forState: .Normal)
        button = UIButton(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        button.backgroundColor = UIColor.clearColor()
        button.setTitleColor(UIColor.clearColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.closeView(_:)), forControlEvents: .TouchUpInside)
        return button
    }

    func faceBookButton() -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle("Facebook", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clearColor()
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.closeView(_:)), forControlEvents: .TouchUpInside)
        return button
    }
    
    func twitterButton() -> UIButton {
        let button = UIButton(type: .System) as UIButton
        button.setTitle("Twitter", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clearColor()
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.addTarget(self, action: #selector(BLUKeyboardViewController.twitterTapped), forControlEvents: .TouchUpInside)
        return button
    }

    
    // MARK:Button Constraints
    func addConstraints(buttons: [UIButton], containingView: UIView){
        for (index, button) in buttons.enumerate() {
            let topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: containingView, attribute: .Top, multiplier: 1.0, constant: 1)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: containingView, attribute: .Bottom, multiplier: 1.0, constant: -1)
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: containingView, attribute: .Left, multiplier: 1.0, constant: 1)
            } else {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: buttons[index-1], attribute: .Right, multiplier: 1.0, constant: 1)
                let widthConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                containingView.addConstraint(widthConstraint)
            }
            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: containingView, attribute: .Right, multiplier: 1.0, constant: -1)
            } else {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: buttons[index+1], attribute: .Left, multiplier: 1.0, constant: -1)
            }
            containingView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func addConstraintsForLastLine(buttons: [UIButton], containingView: UIView){
        for (index, button) in buttons.enumerate() {
            let topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: containingView, attribute: .Top, multiplier: 1.0, constant: 1)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: containingView, attribute: .Bottom, multiplier: 1.0, constant: -1)
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: containingView, attribute: .Left, multiplier: 1.0, constant: 1)
            } else if index == 2 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: buttons[index-1], attribute: .Right, multiplier: 1.0, constant: 1)
                let widthConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: -150)
                containingView.addConstraint(widthConstraint)
            } else {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: buttons[index-1], attribute: .Right, multiplier: 1.0, constant: 1)
                let widthConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                containingView.addConstraint(widthConstraint)
            }
            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: containingView, attribute: .Right, multiplier: 1.0, constant: -1)
            } else {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: buttons[index+1], attribute: .Left, multiplier: 1.0, constant: -1)
            }
            containingView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }

    func setupViewHeight() {
//        self.view = UIView(frame: CGRectMake(0,0, view.frame.size.width, UIScreen.mainScreen().bounds.size.height))
//        let heightConstraint = NSLayoutConstraint(item:self.view,
//                                                  attribute: .Height,
//                                                  relatedBy: .Equal,
//                                                  toItem: nil,
//                                                  attribute: .NotAnAttribute,
//                                                  multiplier: 0.0,
//                                                  constant:UIScreen.mainScreen().bounds.size.height / 2)
//        self.view.addConstraint(heightConstraint)
    }
    
    // MARK: View Layout with Visual Format
    func setUpViewConstraints() {
        
        let viewDictionary = ["view":view, "topRow": topRow, "middleRow": middleRow, "bottomRow":bottomRow, "lastRow":lastRow,
                              "cha1":characterOneRow, "cha2":characterTwoRow, "num":numberRow]
        
        if didRotateView == true {
            let view1_constraint_H_Number = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            
            let view1_constraint_V_Number = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[num(40)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            numberRow.addConstraints(view1_constraint_H_Number)
            numberRow.addConstraints(view1_constraint_V_Number)
            
            let view1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let view1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[topRow(40)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            topRow.addConstraints(view1_constraint_H)
            topRow.addConstraints(view1_constraint_V)
            
            let view2_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let view2_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[middleRow(40)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            middleRow.addConstraints(view2_constraint_H)
            middleRow.addConstraints(view2_constraint_V)
            
            let view3_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let view3_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[bottomRow(40)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            bottomRow.addConstraints(view3_constraint_H)
            bottomRow.addConstraints(view3_constraint_V)
            
            let lastview1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let lastview1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[lastRow(40)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            lastRow.addConstraints(lastview1_constraint_H)
            lastRow.addConstraints(lastview1_constraint_V)
            
            let charview1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let charview1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[cha1(40)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            characterOneRow.addConstraints(charview1_constraint_H)
            characterOneRow.addConstraints(charview1_constraint_V)
            
            let charview2_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let charview2_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[cha2(50)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            characterTwoRow.addConstraints(charview2_constraint_H)
            characterTwoRow.addConstraints(charview2_constraint_V)

        } else {

            let view1_constraint_H_Number = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
        
            let view1_constraint_V_Number = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[num(45)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            numberRow.addConstraints(view1_constraint_H_Number)
            numberRow.addConstraints(view1_constraint_V_Number)

            let view1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let view1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[topRow(50)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            topRow.addConstraints(view1_constraint_H)
            topRow.addConstraints(view1_constraint_V)

            let view2_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let view2_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[middleRow(50)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            middleRow.addConstraints(view2_constraint_H)
            middleRow.addConstraints(view2_constraint_V)

            let view3_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            let view3_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[bottomRow(50)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            bottomRow.addConstraints(view3_constraint_H)
            bottomRow.addConstraints(view3_constraint_V)

            let lastview1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            
            let lastview1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[lastRow(50)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            lastRow.addConstraints(lastview1_constraint_H)
            lastRow.addConstraints(lastview1_constraint_V)

            let charview1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            
            let charview1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[cha1(50)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            characterOneRow.addConstraints(charview1_constraint_H)
            characterOneRow.addConstraints(charview1_constraint_V)

            let charview2_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[view]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil, views: viewDictionary)
            
            let charview2_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[cha2(50)]",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil, views: viewDictionary)
            characterTwoRow.addConstraints(charview2_constraint_H)
            characterTwoRow.addConstraints(charview2_constraint_V)
        }

//        MARK:Position View constraints
        let numview_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[num]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)

        let charview_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[cha1]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        
        let charviewTwo_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[cha2]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        
        let view_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[topRow]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        
        let view_constraint_H_Middle = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[middleRow]-10-|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        
        let view_constraint_H_Bottom = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-20-[bottomRow]-20-|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        
        let view_constraint_H_last = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[lastRow]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        
        if didPressCharacter == true {
            let view_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[num][cha1][cha2][lastRow]|",
                options: NSLayoutFormatOptions.AlignAllLeading,
                metrics: nil, views: viewDictionary)
                view.addConstraints(view_constraint_V)
        } else {
            let view_constraint_V2 = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[topRow][middleRow][bottomRow][lastRow]|",
                options: NSLayoutFormatOptions.AlignAllLeading,
                metrics: nil, views: viewDictionary)
                view.addConstraints(view_constraint_V2)
        }
        view.addConstraints(numview_constraint_H)
        view.addConstraints(charview_constraint_H)
        view.addConstraints(charviewTwo_constraint_H)
        view.addConstraints(view_constraint_H)
        view.addConstraints(view_constraint_H_Middle)
        view.addConstraints(view_constraint_H_Bottom)
        view.addConstraints(view_constraint_H_last)
    }

    //MARK: Button Actions
    func capitalizeFirstLetterOfASentence() {
        let textfieldinput = textDocumentProxy.documentContextBeforeInput
        if (textfieldinput?.characters.count == 0) {
            textfieldinput?.uppercaseFirst
            capsLockOn = true
            changeCaps(topRow)
            changeCaps(middleRow)
            changeCaps(bottomRow)
        } else {
            capsLockOn = false
            changeCaps(topRow)
            changeCaps(middleRow)
            changeCaps(bottomRow)
        }
    }
    
    func keyPressed(sender: AnyObject?) {
        let button = sender as! UIButton
        let title = button.titleForState(.Normal)
        (textDocumentProxy as UIKeyInput).spellCheckingType
        (textDocumentProxy as UIKeyInput).insertText(title!)
        capitalizeFirstLetterOfASentence()
        if button.titleLabel?.text == "." {
            capsLockOn = true
            changeCaps(topRow)
            changeCaps(middleRow)
            changeCaps(bottomRow)
        } else {
            capsLockOn = false
            changeCaps(topRow)
            changeCaps(middleRow)
            changeCaps(bottomRow)
        }
    }

    @IBAction func nextKeyboardPressed(button: UIButton) {
        advanceToNextInputMode()
    }
    
    @IBAction func capsLockPressed(button: UIButton) {
        capsLockOn = !capsLockOn
        changeCaps(topRow)
        changeCaps(middleRow)
        changeCaps(bottomRow)
    }
    
    @IBAction func backSpacePressed(button: UIButton) {
        (textDocumentProxy as UIKeyInput).deleteBackward()
    }
    
    @IBAction func spacePressed(button: UIButton) {
        checkSpelling()
        (textDocumentProxy as UIKeyInput).insertText(" ")
    }
    
    func checkSpelling() {
        let str = textDocumentProxy.documentContextBeforeInput
        var newString = str?.componentsSeparatedByString(" ")
        for spellCheckWord in newString! {
            if spellCheckWord == "" {
                newString?.removeLast()
            }
        }
        let stringToPass = newString?.last
        let textChecker = UITextChecker()
        let misspelledRange = textChecker.rangeOfMisspelledWordInString(
            stringToPass!, range: NSRange(0..<stringToPass!.utf16.count),
            startingAt: 0, wrap: false, language: "en_US")
        if misspelledRange.location != NSNotFound,
            let guesses = textChecker.guessesForWordRange(misspelledRange, inString: stringToPass!, language: "en_US") as? [String] {
            for _ in (stringToPass?.characters)! {
                (textDocumentProxy as UIKeyInput).deleteBackward()
            }
             let replaced = stringToPass!.stringByReplacingOccurrencesOfString(stringToPass!, withString: guesses.first!)
            (textDocumentProxy as UIKeyInput).insertText(replaced)
            print("First guess: \(guesses.first)")
        } else {
            print("Not found")
        }
    }
    
    @IBAction func closeView(view: UIView) {
        self.newView.removeFromSuperview()
    }
    
    func setTextWithLineSpacing(label:UILabel,text:String,lineSpacing:CGFloat)
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        label.attributedText = attrString
    }

    func twitterTapped() {
        setUpTwitterWithCheck()
    }
    
    @IBAction func showAlertWasTapped(sender: UIButton) {
        //MARK: Fix Constraints Issue
        self.pickSocialView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        self.pickSocialView.backgroundColor = UIColor.whiteColor()
        self.pickSocialView.translatesAutoresizingMaskIntoConstraints = false
        
        let faceBook = [faceBookButton()]
        let twitter = [twitterButton()]
        
        self.topView = UIView(frame: CGRectMake(0,0, view.frame.size.width, 40))
        self.bottomView = UIView(frame: CGRectMake(0,0, view.frame.size.width, 40))

        getFacebookTimeline()
        
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        for button in faceBook {
            topView.addSubview(button)
        }

        for button in twitter {
            bottomView.addSubview(button)
        }
      
        self.view.addSubview(pickSocialView)
        self.pickSocialView.addSubview(topView)
        self.pickSocialView.addSubview(bottomView)
        socialViewConstraints()
        addConstraints(faceBook, containingView: topView)
        addConstraints(twitter, containingView: bottomView)
    }
    
    func setUpTwitterWithCheck() {
        self.popoverView = UIView(frame: CGRectMake(0,0, view.frame.size.width, view.frame.size.height))
        self.alertView = UIView(frame: CGRectMake(0,0, view.frame.size.width, view.frame.size.height))
        
        if isOpenAccessGranted() == false {
            self.newView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
            let label = UILabel(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.blackColor()
            label.numberOfLines = 0
            label.text = "To Use Social Feed You Need to enable full access in the keyboard settings Part of the Settings App. Settings > General > KeyBoard > TheBLUMarketKeyboard > Allow Full Access."
            setTextWithLineSpacing(label, text: label.text!, lineSpacing: 10.0)
            label.textAlignment = NSTextAlignment.Center
            self.newView.addSubview(label)
            self.newView.addSubview(closeAlertButton())
            self.newView.backgroundColor = UIColor.whiteColor()
            view.addSubview(self.newView)
            labelConstraints(label)
            print("NO FULL ACCESS 🙁")
        } else {
            setupTableView(popoverView)
            view.addSubview(popoverView)
        }

    }
    
    func labelConstraints(labelToSet: UILabel) -> UILabel {
        
        let viewDic = ["view": view, "labelToSet":labelToSet]
        
        let view1_constraint_H_Number = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[view]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil, views: viewDic)
        
        let view1_constraint_V_Number = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[view]",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDic)
        
        labelToSet.addConstraints(view1_constraint_H_Number)
        labelToSet.addConstraints(view1_constraint_V_Number)
        
        let view1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[labelToSet]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDic)

        let view1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[labelToSet]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDic)
        
        view.addConstraints(view1_constraint_H)
        view.addConstraints(view1_constraint_V)

        return labelToSet
    }
   
    func socialViewConstraints() {
        
        let viewDic = ["view" : view, "facebook" : topView, "twitter" : bottomView, "social": pickSocialView]
        
        let view1_constraint_Vpick = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[social]|",
            options: NSLayoutFormatOptions.AlignAllLeading,
            metrics: nil, views: viewDic)
        
        let view1_constraint_Hpick = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[social]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDic)

        let view1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[twitter(90)][facebook(90)]-|",
            options: NSLayoutFormatOptions.AlignAllLeading,
            metrics: nil, views: viewDic)
        
        let view1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[facebook]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDic)

        let view1_constraint_HT = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[twitter]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDic)
        view.addConstraints(view1_constraint_Hpick)
        view.addConstraints(view1_constraint_Vpick)
        view.addConstraints(view1_constraint_H)
        view.addConstraints(view1_constraint_HT)
        view.addConstraints(view1_constraint_V)
    }

    
    func refresh() {
        getTwitterTimeLine()
    }

    func doubleTapSpaceAction(button: UIButton) {
        (textDocumentProxy as UIKeyInput).deleteBackward()
        (textDocumentProxy as UIKeyInput).insertText(".")
    }
    
    @IBAction func returnPressed(button: UIButton) {
        (textDocumentProxy as UIKeyInput).insertText("\n")
    }
    
    @IBAction func myTypingAction(sender: UIButton) {
        let title = sender.titleForState(.Normal)
        (textDocumentProxy as UIKeyInput).insertText(title!)
    }
    
    @IBAction func charSetPressed(button: UIButton) {
        if button.titleLabel!.text == "2/2" {
            characterOneRow.hidden = true
            characterTwoRow.hidden = true
            topRow.hidden = false
            middleRow.hidden = false
            bottomRow.hidden = false
            didPressCharacter = true
            setUpViewConstraints()
            button.setTitle("1/2", forState: .Normal)
        } else if button.titleLabel!.text == "1/2" {
            characterOneRow.hidden = false
            characterTwoRow.hidden = false
            topRow.hidden = true
            middleRow.hidden = true
            bottomRow.hidden = true
            didPressCharacter = true
            setUpViewConstraints()
            button.setTitle("2/2", forState: .Normal)
        }
    }
    
    func changeCaps(containerView: UIView) {
        for view in containerView.subviews {
            if let button = view as? UIButton {
                let buttonTitle = button.titleLabel!.text
                if capsLockOn {
                    let text = buttonTitle!.uppercaseString
                    button.setTitle("\(text)", forState: .Normal)
                } else {
                    let text = buttonTitle!.lowercaseString
                    button.setTitle("\(text)", forState: .Normal)
                }
            }
        }
    }
    
    // MARK: TableView
    func setupTableView(viewToAdd :UIView) {
        self.tableView = UITableView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension
        getTwitterTimeLine()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        viewToAdd.addSubview(tableView)
        if (didGetInfo != nil) {
            timedRefresh()
        }
    }
    
    func timedRefresh() {
        let myTimer = NSTimer(timeInterval: 30.0, target: self, selector: #selector(BLUKeyboardViewController.refresh), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(myTimer, forMode: NSDefaultRunLoopMode)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        var tweetString = (self.dataSource[indexPath.row]["user"] as? [String: AnyObject])? ["name"] as? String
        tweetString!.appendContentsOf("\n\(self.dataSource[indexPath.row]["text"] as! String)")
        cell.textLabel?.text = tweetString
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func openURL(url: NSURL) -> Bool {
        do {
            let application = try self.sharedApplication()
            return application.performSelector(#selector(BLUKeyboardViewController.openURL(_:)), withObject: url) != nil
        }
        catch {
            return false
        }
    }
    
    func sharedApplication() throws -> UIApplication {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application
            }
            responder = responder?.nextResponder()
        }
        throw NSError(domain: "UIInputViewController+sharedApplication.swift", code: 1, userInfo: nil)
    }
    
    func openInTwitter() {
        let url = NSURL(string: "https://www.twitter.com/")!
        openURL(url)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        openInTwitter()
        tableView.removeFromSuperview()
        popoverView.removeFromSuperview()
        print("You selected cell #\(indexPath.row)!")
    }
    
    func isOpenAccessGranted() -> Bool {
        return UIPasteboard.generalPasteboard().isKindOfClass(UIPasteboard)
    }
    
    func getTwitterTimeLine() {
        
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(
            ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil, completion: {(success: Bool, error: NSError!) -> Void in
            if success {
                let arrayOfAccounts =
                    account.accountsWithAccountType(accountType)
                if arrayOfAccounts.count > 0 {
                    let twitterAccount = arrayOfAccounts.last as! ACAccount
                    let requestURL = NSURL(string:"https://api.twitter.com/1.1/statuses/home_timeline.json")
                    let parameters = ["screen_name" : "@TomP1129","include_rts" : "0","trim_user" : "0", "count" : "20"]
                    
                    let postRequest = SLRequest(forServiceType:SLServiceTypeTwitter,
                        requestMethod: SLRequestMethod.GET,
                        URL: requestURL,
                        parameters: parameters)
                    postRequest.account = twitterAccount
                    postRequest.performRequestWithHandler({(responseData: NSData!,
                        urlResponse: NSHTTPURLResponse!,
                        error: NSError!) -> Void in
                        
                        self.dataSource = try! NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments) as! [AnyObject]
                        print("\(self.dataSource)")
                        if self.dataSource.count != 0 {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
                self.didGetInfo = true
            } else {
                print("Failed to access account")
                self.didGetInfo = false
            }
        })
    }
    
    func getFacebookTimeline() {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(
            ACAccountTypeIdentifierFacebook)
        
        let postingOptions = [ACFacebookAppIdKey:"fb857311861041303",
                              ACFacebookPermissionsKey: ["email"],
                              ACFacebookAudienceKey: ACFacebookAudienceFriends]
        
        accountStore.requestAccessToAccountsWithType(accountType, options: postingOptions as! [NSObject : AnyObject]) {
            success, error in
                if success {
                    let options = [ACFacebookAppIdKey:"fb857311861041303", ACFacebookPermissionsKey: ["publish_actions"], ACFacebookAudienceKey: ACFacebookAudienceFriends]
                                                            
                    accountStore.requestAccessToAccountsWithType(accountType, options: options as! [NSObject : AnyObject]) {
                        success, error in
                            if success {
                                    var accountsArray = accountStore.accountsWithAccountType(accountType)
                                        if accountsArray.count > 0 {
                                            let facebookAccount = accountsArray[0] as! ACAccount
                                            
                                            var parameters = Dictionary <String, AnyObject>()
                                            parameters["access_token"] = facebookAccount.credential.oauthToken
                                            parameters["message"] = "My first Facebook post from iOS 8"
                                                                                                                    
                                            let feedURL = NSURL(string:"https://graph.facebook.com/me/feed")
                                                                                                                    
                                            let postRequest = SLRequest(forServiceType:SLServiceTypeFacebook, requestMethod: SLRequestMethod.GET, URL: feedURL, parameters: parameters)
                                            postRequest.performRequestWithHandler({(responseData: NSData!, urlResponse: NSHTTPURLResponse!,error: NSError!) -> Void in
                                               
                                                self.dataSource = try! NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments) as! [AnyObject]
                                                print("\(self.dataSource)")
                                                if self.dataSource.count != 0 {
                                                    dispatch_async(dispatch_get_main_queue()) {
                                                        self.tableView.reloadData()
                                                    }
                                                }
                                                print("Twitter HTTP response \(urlResponse.statusCode)")
                                            })
                                        }
                                    } else {
                                        print("Access denied")
                                        print(error.localizedDescription)
                                    }
                                }
                            } else {
                                print("Access denied")
                                print(error.localizedDescription)
                        }
        }
    }
}
