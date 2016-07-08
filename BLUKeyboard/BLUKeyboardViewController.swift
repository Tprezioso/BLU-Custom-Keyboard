//
//  KeyboardViewController.swift
//
//  Created by Thomas Prezioso on 7/5/16.
//  Copyright (c) 2016 Thomas Prezioso. All rights reserved.
//

import UIKit

extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    
    var last: String {
        return String(characters.suffix(1))
    }
    
    func indexAt(int: Character) -> String {
        return String(characters.indexOf(int))
    }
    
    var uppercaseFirst: String {
        return first.uppercaseString + String(characters.dropFirst())
    }
}

class BLUKeyboardViewController: UIInputViewController {
    
    var capsLockOn = true
    var topRow: UIView!
    var middleRow: UIView!
    var bottomRow: UIView!
    var lastRow: UIView!
    var characterOneRow: UIView!
    var characterTwoRow: UIView!
    var didPressCharacter: Bool!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func setupViews() {
        didPressCharacter = false
        
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
        let bottomRowButtons = createButtons(bottomRowTitles)
        self.bottomRow = UIView(frame: CGRectMake(0, 0,view.frame.size.width, 40))
        
        self.lastRow = UIView(frame: CGRectMake(0,0, view.frame.size.width, 40))
        var lastRowButtons: [UIButton] = [UIButton]()
        let returnButton = createReturn("⏎")
        let period = createPeriod()
        let spaceButton = createSpace()
        let changeKeyboard = createChangeKeyboard()
        let changeCharacter = createChangeCharacters()
        
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
        
        let backspace = createBackSpaceButton("🔙")
        middleButtons.append(backspace)
        
        let shift = createShiftButton("↑")
        middleButtons.insert(shift, atIndex: 0)
        
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
        
        self.view.addSubview(characterOneRow)
        self.view.addSubview(characterTwoRow)
        self.view.addSubview(topRow)
        self.view.addSubview(middleRow)
        self.view.addSubview(bottomRow)
        self.view.addSubview(lastRow)
        setUpViewConstraints()
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
            button.addTarget(self, action:#selector(BLUKeyboardViewController.keyPressed(_:)), forControlEvents: .TouchUpInside)
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

    // MARK: View Layout with Visual Format
    func setUpViewConstraints() {
        let viewDictionary = ["topRow": topRow, "middleRow": middleRow, "bottomRow":bottomRow, "view":view, "lastRow":lastRow,
                              "cha1":characterOneRow, "cha2":characterTwoRow];
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
            "V:[cha2(40)]",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        characterTwoRow.addConstraints(charview2_constraint_H)
        characterTwoRow.addConstraints(charview2_constraint_V)

        //MARK:Position View constraints
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
            "H:|[middleRow]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        let view_constraint_H_Bottom = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-40-[bottomRow]-40-|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil, views: viewDictionary)
        let view_constraint_H_last = NSLayoutConstraint.constraintsWithVisualFormat("H:|[lastRow]|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: viewDictionary)
        
        if didPressCharacter == true {
            let view_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[cha2][topRow][middleRow][bottomRow][lastRow]|",
                options: NSLayoutFormatOptions.AlignAllLeading,
                metrics: nil, views: viewDictionary)
                view.addConstraints(view_constraint_V)
        } else {
            let view_constraint_V2 = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[cha1][topRow][middleRow][bottomRow][lastRow]|",
                options: NSLayoutFormatOptions.AlignAllLeading,
                metrics: nil, views: viewDictionary)
                view.addConstraints(view_constraint_V2)
        }
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
        print("<<<<<<<<<<<<<<<<<<\(textfieldinput)")
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
        (textDocumentProxy as UIKeyInput).insertText(" ")
    }
    
    @IBAction func returnPressed(button: UIButton) {
        (textDocumentProxy as UIKeyInput).insertText("\n")
    }
    
    @IBAction func charSetPressed(button: UIButton) {
        if button.titleLabel!.text == "1/2" {
            characterOneRow.hidden = true
            characterTwoRow.hidden = false
            didPressCharacter = true
            button.setTitle("2/2", forState: .Normal)
        } else if button.titleLabel!.text == "2/2" {
            characterOneRow.hidden = false
            characterTwoRow.hidden = true
            didPressCharacter = false
            button.setTitle("1/2", forState: .Normal)
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
}
