//  TriviaViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  
  private var answerButtons: [UIButton] { [answerButton0, answerButton1, answerButton2, answerButton3] }
  private var isLoading = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addGradient()
    questionContainerView.layer.cornerRadius = 8.0
    
    // Add a Reset button to fetch a different set of questions
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(didTapReset))
    
    // FETCH TRIVIA QUESTIONS HERE
    fetchQuestionsAndStart()
  }
  
  // MARK: - Networking / Flow
  
  private func fetchQuestionsAndStart(categoryID: Int? = nil, difficulty: String? = nil, type: String? = nil) {
    setLoading(true, message: "Loading questions…")
    TriviaQuestionService.shared.fetchQuestions(
      amount: 5,
      categoryID: categoryID,
      difficulty: difficulty,
      type: type
    ) { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.setLoading(false)
        switch result {
        case .success(let qs):
          self.questions = qs
          self.currQuestionIndex = 0
          self.numCorrectQuestions = 0
          self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
        case .failure(let error):
          self.presentError(error.localizedDescription)
        }
      }
    }
  }
  
  private func setLoading(_ loading: Bool, message: String? = nil) {
    isLoading = loading
    answerButtons.forEach { $0.isEnabled = !loading }
    if loading {
      currentQuestionNumberLabel.text = ""
      categoryLabel.text = ""
      questionLabel.text = message ?? "Loading…"
      // hide all buttons during load
      answerButtons.enumerated().forEach { idx, b in
        b.setTitle("", for: .normal)
        b.isHidden = true
      }
    }
  }
  
  private func presentError(_ message: String) {
    let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
      self?.fetchQuestionsAndStart()
    }))
    present(alert, animated: true)
  }
  
  // MARK: - UI Updates
  
  private func updateQuestion(withQuestionIndex questionIndex: Int) {
    currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
    
    let question = questions[questionIndex]
    questionLabel.text = question.question
    categoryLabel.text = question.category
    
    // reset all buttons hidden
    answerButtons.forEach { $0.isHidden = true }
    
    let answers = question.allAnswersShuffled
    for (i, title) in answers.enumerated() where i < answerButtons.count {
      let btn = answerButtons[i]
      btn.setTitle(title, for: .normal)
      btn.isHidden = false
    }
  }
  
  private func updateToNextQuestion(answer: String) {
    guard !isLoading else { return }
    if isCorrectAnswer(answer) {
      numCorrectQuestions += 1
    }
    currQuestionIndex += 1
    guard currQuestionIndex < questions.count else {
      showFinalScore()
      return
    }
    updateQuestion(withQuestionIndex: currQuestionIndex)
  }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(
      title: "Game over!",
      message: "Final score: \(numCorrectQuestions)/\(questions.count)",
      preferredStyle: .alert
    )
    // On restart, fetch a NEW set of questions ✅
    let resetAction = UIAlertAction(title: "Fetch New Game", style: .default) { [unowned self] _ in
      fetchQuestionsAndStart()
    }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  // MARK: - Actions
  
  @objc private func didTapReset() {
    // Optional: show a quick confirmation to allow category/difficulty later
    fetchQuestionsAndStart()
  }
  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) { updateToNextQuestion(answer: sender.titleLabel?.text ?? "") }
  @IBAction func didTapAnswerButton1(_ sender: UIButton) { updateToNextQuestion(answer: sender.titleLabel?.text ?? "") }
  @IBAction func didTapAnswerButton2(_ sender: UIButton) { updateToNextQuestion(answer: sender.titleLabel?.text ?? "") }
  @IBAction func didTapAnswerButton3(_ sender: UIButton) { updateToNextQuestion(answer: sender.titleLabel?.text ?? "") }
}
