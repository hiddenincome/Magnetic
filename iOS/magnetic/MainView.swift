/*

The MIT License (MIT)

Copyright (c) 2018 Anders Holmberg - hiddenincome.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

import UIKit

class MainView: UIView {

    let topBar = UILabel()
    let textPanel = UITextView()
    let bottomBar = UIView()
    
    var selectGameState = true
    
    private var queue = DispatchQueue(label: "com.hiddenincome.magnetic")

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = UIColor.blue
        topBar.text = "Magnetic Scrolls"
        topBar.textColor = UIColor.white
        topBar.textAlignment = .center
        topBar.font = UIFont(name: "Courier-Bold", size: 20)
        topBar.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topBar.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = UIColor.blue
        bottomBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomBar.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        bottomBar.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        bottomBar.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -65).isActive = true
        
        addSubview(textPanel)
        textPanel.translatesAutoresizingMaskIntoConstraints = false
        textPanel.backgroundColor = UIColor.blue
        textPanel.text = ""
        textPanel.font = UIFont(name: "Courier-Bold", size: 20)
        textPanel.textColor = UIColor.white
        textPanel.textAlignment = .left
        textPanel.autocorrectionType = .no
        textPanel.spellCheckingType = .no
        textPanel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        textPanel.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        textPanel.bottomAnchor.constraint(equalTo: bottomBar.topAnchor).isActive = true
        textPanel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        
        runGame()
    }

    func runGame()
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathToStoryFile = documentsUrl.appendingPathComponent("pawn.mag").path

        bridge_init(pathToStoryFile);

        queue.async {

            while true {
                ms_rungame()
                // TODO : replace this with loop that builds string as long as ms_consume_buffer returns != '\0'
                // Loop need to get all text before getchar is called.
                for _ in 1...100 {
                    let c = bridge_output()
                    if c != 0 {
                        // Output to UI must be synced with main thread.
                        DispatchQueue.main.async {
                            self.textPanel.insertText(String(Character(UnicodeScalar(c))))
                        }
                    }
                }
            }
        }
    }
    
    func inputText(newCharacter text:String)
    {
        let textLower = text.lowercased()
    
        let newPosition = textPanel.endOfDocument
        textPanel.selectedTextRange = textPanel.textRange(from: newPosition, to: newPosition)
        if textLower == "\u{8}" {
            textPanel.deleteBackward()
        } else {
            textPanel.insertText(textLower)
        }
        for character in textLower {
            bridge_input(Array(String(character).utf8)[0])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
