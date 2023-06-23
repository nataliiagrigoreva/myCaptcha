//
//  ViewController.swift
//  myCaptcha
//
//  Created by Nataly on 23.06.2023.
//


import UIKit

class ViewController: UIViewController {
    
    var numberLabel: UILabel!
    var inputTextField: UITextField!
    var startButton: UIButton!
    var checkButton: UIButton!
    var topLabel: UILabel!
    var scoreLabel: UILabel!
    var retryButton: UIButton!
    var numbersArray: [Int] = []
    var currentNumberIndex = 0
    var timer: Timer?
    var score = 0
    var totalScore = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLabels()
    }
    
    func setupUI() {
        // Создание метки для отображения чисел
        numberLabel = UILabel()
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont.boldSystemFont(ofSize: 60)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(numberLabel)
        
        // Создание текстового поля для ввода чисел
        inputTextField = UITextField()
        inputTextField.textAlignment = .center
        inputTextField.font = UIFont.systemFont(ofSize: 20)
        inputTextField.borderStyle = .roundedRect
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputTextField)
        
        // Создание кнопки "Старт"
        startButton = UIButton(type: .system)
        startButton.setTitle("Старт", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)
        
        // Создание кнопки "Проверить"
        checkButton = UIButton(type: .system)
        checkButton.setTitle("Проверить", for: .normal)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        checkButton.isEnabled = false
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkButton)
        
        // Создание кнопки "Попробовать снова"
        retryButton = UIButton(type: .system)
        retryButton.setTitle("Попробовать снова", for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.isEnabled = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(retryButton)
        
        // Установка ограничений для элементов интерфейса
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            inputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputTextField.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 20),
            inputTextField.widthAnchor.constraint(equalToConstant: 200),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 20),
            
            checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 20)
        ])
    }
    
    func setupLabels() {
        // Создание метки для текста вверху экрана
        topLabel = UILabel()
        topLabel.text = "Попробуй взломать сейф!                                      Запомни числа за 10 секунд и введи их для проверки. Если все числа введены верно, то сейф откроется!"
        topLabel.numberOfLines = 0
        topLabel.textAlignment = .center
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topLabel)
        
        // Создание метки для отображения количества очков
        scoreLabel = UILabel()
        scoreLabel.text = "Сейфов вскрыто: 0"
        scoreLabel.textAlignment = .right
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            topLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func startButtonTapped() {
        startGame()
    }
    
    @objc func checkButtonTapped() {
        checkNumbers()
    }
    
    @objc func retryButtonTapped() {
        retryGame()
    }
    
    func startGame() {
        numbersArray = generateRandomNumbers(count: 6)
        currentNumberIndex = 0
        inputTextField.text = ""
        numberLabel.text = ""
        startButton.isEnabled = false
        checkButton.isEnabled = false
        retryButton.isEnabled = false
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(displayNextNumber), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.timer?.invalidate()
            self.timer = nil
            self.numberLabel.text = ""
            self.checkButton.isEnabled = true
            self.retryButton.isEnabled = true
        }
    }
    
    @objc func displayNextNumber() {
        if currentNumberIndex < numbersArray.count {
            let number = numbersArray[currentNumberIndex]
            numberLabel.text = String(number)
            numberLabel.textColor = getRandomColor()
            currentNumberIndex += 1
        } else {
            timer?.invalidate()
            timer = nil
            numberLabel.text = ""
            checkButton.isEnabled = true
            retryButton.isEnabled = true
        }
    }
    
    func generateRandomNumbers(count: Int) -> [Int] {
        var numbers: [Int] = []
        var lastNumber = -1
        for _ in 0..<count {
            var number = Int.random(in: 0...9)
            while number == lastNumber {
                number = Int.random(in: 0...9)
            }
            numbers.append(number)
            lastNumber = number
        }
        return numbers
    }
    
    func checkNumbers() {
        guard let inputText = inputTextField.text, !inputText.isEmpty else {
            showAlert(message: "Введено недостаточное количество чисел")
            return
        }
        
        let inputNumbers = inputText.map { Int(String($0)) }
        let unwrappedInputNumbers = inputNumbers.compactMap({ $0 })
        
        if unwrappedInputNumbers.count < numbersArray.count {
            showAlert(message: "Введено недостаточное количество чисел")
        } else if unwrappedInputNumbers.count > numbersArray.count {
            showAlert(message: "Введено слишком много чисел")
        } else {
            var isCorrect = true
            for (index, number) in unwrappedInputNumbers.enumerated() {
                if number != numbersArray[index] {
                    isCorrect = false
                    break
                }
            }
            
            if isCorrect {
                showAlert(message: "Поздравляю! Сейф вскрыт!")
                score += 1
                scoreLabel.text = "Сейфов вскрыто: \(score)"
            } else {
                showAlert(message: "К сожалению, сейф не открыт. Попробуйте снова.")
                score = 0
                scoreLabel.text = "Сейфов вскрыто: \(score)"
            }
        }
    }
    
    func retryGame() {
        startButton.isEnabled = true
        checkButton.isEnabled = false
        retryButton.isEnabled = false
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getRandomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}



