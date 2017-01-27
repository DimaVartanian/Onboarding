//
//  FlowScreenViewController.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/24/17.
//

import UIKit

class FlowScreenViewController: UIViewController, UITextFieldDelegate, TransitionableFlowViewController
{
    // TransitionableFlowViewController
    var viewsToFade = [UIView]()
    var viewsToSlide = [UIView]()
    
    let viewModel: FlowScreenViewModel!
    
    var inputFields = [UITextField]()
    
    let scrollView: UIScrollView =
    {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    let contentView: UIView =
    {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    init(withViewModel viewModel: FlowScreenViewModel)
    {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.viewModel = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        let outerPadding: CGFloat = 20
        let innerPadding: CGFloat = 15
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        var lastView: UIView
        
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomLayoutGuide.topAnchor).isActive = true
        let scrollViewHeight = scrollView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: 0)
        scrollViewHeight.priority = UILayoutPriorityDefaultLow
        scrollViewHeight.isActive = true
        
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        let headerLabel = AutoLayoutLabel()
        viewsToFade.append(headerLabel)
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerLabel)
        headerLabel.numberOfLines = 0
        headerLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: outerPadding).isActive = true
        headerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerPadding).isActive = true

        lastView = headerLabel
        
        headerLabel.text = viewModel.formattedHeader
        
        if let takeaways = viewModel.formattedTakeaways
        {
            var previousTakeawayLabel: UILabel?
            for takeaway in takeaways
            {
                let takeawayLabel = AutoLayoutLabel()
                viewsToSlide.append(takeawayLabel)
                takeawayLabel.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(takeawayLabel)
                takeawayLabel.numberOfLines = 0
                takeawayLabel.font = UIFont.preferredFont(forTextStyle: .title3)
                takeawayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                takeawayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerPadding * 2).isActive = true
                
                if let previousTakeawayLabel = previousTakeawayLabel
                {
                    takeawayLabel.topAnchor.constraint(equalTo: previousTakeawayLabel.bottomAnchor, constant: innerPadding).isActive = true
                }
                else
                {
                    takeawayLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: outerPadding).isActive = true
                }
                
                takeawayLabel.text = takeaway
                
                previousTakeawayLabel = takeawayLabel
                lastView = takeawayLabel
            }
        }
        else
        {
            var previousAnswerField: UITextField?
            
            let questions = viewModel.formattedQuestions!
            for (index, question) in questions.enumerated()
            {
                let questionLabel = AutoLayoutLabel()
                questionLabel.numberOfLines = 0
                viewsToSlide.append(questionLabel)
                questionLabel.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(questionLabel)
                
                questionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
                questionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: innerPadding).isActive = true
                
                if let previousAnswerField = previousAnswerField
                {
                    questionLabel.topAnchor.constraint(equalTo: previousAnswerField.bottomAnchor, constant: innerPadding).isActive = true
                }
                else
                {
                    questionLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: outerPadding).isActive = true
                }
                
                let answerField = UITextField()
                viewsToSlide.append(answerField)
                answerField.autocorrectionType = .no
                answerField.spellCheckingType = .no
                answerField.borderStyle = .roundedRect
                answerField.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(answerField)
                answerField.font = UIFont.preferredFont(forTextStyle: .subheadline)
                answerField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                answerField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: innerPadding).isActive = true
                answerField.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 5).isActive = true
                
                inputFields.append(answerField)
                answerField.delegate = self
                
                let input = viewModel.inputs![index]
                
                if input.answerParameters.type == .int
                {
                    answerField.keyboardType = .numbersAndPunctuation
                }
                
                lastView = answerField
                previousAnswerField = answerField
                
                questionLabel.text = question
            }
        }
        
        if let continuePrompt = viewModel.screen.continuePrompt
        {
            let continueButton = UIButton(type: .system)
            viewsToFade.append(continueButton)
            continueButton.translatesAutoresizingMaskIntoConstraints = false
            continueButton.setTitle(continuePrompt, for: .normal)
            continueButton.contentHorizontalAlignment = .center
            continueButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            contentView.addSubview(continueButton)
            continueButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            let topConstraint = continueButton.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: outerPadding)
            topConstraint.priority = UILayoutPriorityDefaultLow
            topConstraint.isActive = true
            lastView = continueButton
            continueButton.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: -outerPadding).isActive = true
            continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        }
        
        let superSecretRestartButton = UIButton(type:.system)
        contentView.addSubview(superSecretRestartButton)
        superSecretRestartButton.translatesAutoresizingMaskIntoConstraints = false
        superSecretRestartButton.setTitle("Restart(debug)", for: .normal)
        superSecretRestartButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        superSecretRestartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        superSecretRestartButton.addTarget(self, action: #selector(debugRestartPressed), for: .touchUpInside)
        lastView = superSecretRestartButton
        
        lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -outerPadding).isActive = true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        let index = inputFields.index(of: textField)!
        let input = viewModel.inputs![index]
        if let choices = input.answerParameters.choices
        {
            openPickerView(forTextField: textField, choices: choices)
            return false
        }
        else
        {
            return true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        let index = inputFields.index(of: textField)!
        if index + 1 < inputFields.count
        {
            inputFields[index + 1].becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func openPickerView(forTextField textField: UITextField, choices: [Any])
    {
        let index = inputFields.index(of: textField)!
        let input = viewModel.inputs![index]
        let stringChoices: [String]
        if input.answerParameters.type == .int
        {
            stringChoices = choices.map{String($0 as! Int)}
        }
        else
        {
            stringChoices = choices as! [String]
        }
        
        let alertController = UIAlertController(title: viewModel.formattedQuestions![index], message: nil, preferredStyle: .actionSheet)
        
        for choice in stringChoices
        {
            alertController.addAction(UIAlertAction(title: choice, style: .default, handler:
            { (action) in
                textField.text = choice
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - actions
    
    func continuePressed()
    {
        self.scrollView.scrollRectToVisible(CGRect.zero, animated: true)
        DispatchQueue.main.async
        {
            let accepted = self.viewModel.acceptAnswers(answers: self.inputFields.map{$0.text ?? ""})
            if !accepted
            {
                let alertController = UIAlertController(title: "Oops!", message: "Our robots are having a hard time understanding one or more of your answers.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func debugRestartPressed()
    {
        (UIApplication.shared.delegate as! AppDelegate).beginOnboardingFlow()
    }
}
