//
//  GameScene.swift
//  saisyuukadai
//
//  Created by 長屋天友 on 2024/07/30.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    var scoreLabel: SKLabelNode!
    var lifeLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var stageLabel: SKLabelNode!
    var backgroundMusicPlayer: AVAudioPlayer!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            if score % 50 == 0 {
                nextStage()
            }
        }
    }
    var playerLife: Int = 3 {
        didSet {
            lifeLabel.text = "Life: \(playerLife)"
        }
    }
    var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore") {
        didSet {
            highScoreLabel.text = "High Score: \(highScore)"
            UserDefaults.standard.set(highScore, forKey: "HighScore")
        }
    }
    var stage: Int = 1 {
        didSet {
            stageLabel.text = "Stage: \(stage)"
        }
    }
    
    var isPoweredUp: Bool = false
    var bossLife: Int = 20  // ボスのライフを強化
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        // プレイヤー画像を表示する
        let player = SKSpriteNode(imageNamed: "player")
        player.name = "player"
        player.position = CGPoint(x: size.width / 2, y: player.size.height / 2 + 20)
        player.size = CGSize(width: 50, height: 50) // プレイヤーのサイズを設定
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        lifeLabel = SKLabelNode(fontNamed: "Chalkduster")
        lifeLabel.fontSize = 20
        lifeLabel.fontColor = SKColor.white
        lifeLabel.position = CGPoint(x: size.width / 2, y: size.height - 70)
        lifeLabel.text = "Life: 3"
        addChild(lifeLabel)
        
        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        highScoreLabel.fontSize = 20
        highScoreLabel.fontColor = SKColor.yellow
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        highScoreLabel.text = "High Score: \(highScore)"
        addChild(highScoreLabel)
        
        stageLabel = SKLabelNode(fontNamed: "Chalkduster")
        stageLabel.fontSize = 20
        stageLabel.fontColor = SKColor.green
        stageLabel.position = CGPoint(x: size.width / 2, y: size.height - 130)
        stageLabel.text = "Stage: \(stage)"
        addChild(stageLabel)
        
        playBackgroundMusic()
        
        startGame()
        
        isUserInteractionEnabled = true
    }
    
    func startGame() {
        let spawnEnemyAction = SKAction.run { [weak self] in
            self?.spawnDiverseEnemies()
        }
        let waitAction = SKAction.wait(forDuration: 1.0 / Double(stage))
        let spawnSequence = SKAction.sequence([spawnEnemyAction, waitAction])
        let repeatAction = SKAction.repeatForever(spawnSequence)
        run(repeatAction)
        
        let spawnPowerUpAction = SKAction.run { [weak self] in
            self?.spawnPowerUp()
        }
        let powerUpWaitAction = SKAction.wait(forDuration: 10.0)
        let powerUpSequence = SKAction.sequence([spawnPowerUpAction, powerUpWaitAction])
        let powerUpRepeatAction = SKAction.repeatForever(powerUpSequence)
        run(powerUpRepeatAction)
    }
    
    func nextStage() {
        stage += 1
        removeAllActions()
        startGame()
        
        // ステージが増えるごとに敵の出現率を上げたり、新しい敵を追加するロジックをここに追加します。
        if stage % 3 == 0 {
            spawnBoss()
        }
    }
    
    func spawnBoss() {
        let boss = SKSpriteNode(imageNamed: "boss")
        boss.name = "boss"
        boss.size = CGSize(width: 120, height: 120)  // ボスのサイズを大きくする
        boss.position = CGPoint(x: size.width / 2, y: size.height - boss.size.height / 2)
        addChild(boss)
        
        let moveLeft = SKAction.moveTo(x: 80, duration: 2.0)
        let moveRight = SKAction.moveTo(x: size.width - 80, duration: 2.0)
        let moveSequence = SKAction.sequence([moveLeft, moveRight])
        let moveForever = SKAction.repeatForever(moveSequence)
        boss.run(moveForever)
        
        let shootAction = SKAction.run { [weak self] in
            self?.shootBossBullet()
        }
        let waitAction = SKAction.wait(forDuration: 0.5)  // ボスの攻撃頻度を上げる
        let shootSequence = SKAction.sequence([shootAction, waitAction])
        let shootForever = SKAction.repeatForever(shootSequence)
        boss.run(shootForever)
    }
    
    func shootBossBullet() {
        if let boss = childNode(withName: "boss") as? SKSpriteNode {
            let bullet = SKSpriteNode(imageNamed: "bossBullet")
            bullet.size = CGSize(width: 15, height: 30)
            bullet.name = "bossBullet"
            bullet.position = CGPoint(x: boss.position.x, y: boss.position.y - boss.size.height / 2 - bullet.size.height / 2)
            addChild(bullet)
            
            let moveAction = SKAction.moveBy(x: 0, y: -size.height, duration: 3.0)
            let removeAction = SKAction.removeFromParent()
            let sequence = SKAction.sequence([moveAction, removeAction])
            bullet.run(sequence)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let player = childNode(withName: "player") as? SKSpriteNode {
            player.position = location
        }
        
        shootBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let player = childNode(withName: "player") as? SKSpriteNode {
            player.position = location
        }
    }
    
    func shootBullet() {
        if let player = childNode(withName: "player") as? SKSpriteNode {
            let bullet = createBullet()
            bullet.position = CGPoint(x: player.position.x, y: player.position.y + player.size.height / 2 + bullet.size.height / 2)
            addChild(bullet)
            
            if isPoweredUp {
                // パワーアップ中は複数の弾を発射する
                let leftBullet = createBullet()
                leftBullet.position = CGPoint(x: player.position.x - 20, y: player.position.y + player.size.height / 2 + leftBullet.size.height / 2)
                addChild(leftBullet)
                
                let rightBullet = createBullet()
                rightBullet.position = CGPoint(x: player.position.x + 20, y: player.position.y + player.size.height / 2 + rightBullet.size.height / 2)
                addChild(rightBullet)
            }
            
            run(SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false))
        }
    }
    
    func createBullet() -> SKSpriteNode {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.size = CGSize(width: 10, height: 20)
        bullet.name = "bullet"
        
        let moveAction = SKAction.moveBy(x: 0, y: size.height, duration: 2.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])
        bullet.run(sequence)
        
        return bullet
    }
    
    func spawnDiverseEnemies() {
        let enemyTypes = ["enemy1", "enemy2", "enemy3", "enemy4", "enemy5"]
        let randomIndex = Int(arc4random_uniform(UInt32(enemyTypes.count)))
        let enemyType = enemyTypes[randomIndex]
        let enemy = SKSpriteNode(imageNamed: enemyType)
        enemy.name = "enemy"
        
        // 敵ごとのサイズや動きを設定
        switch enemyType {
        case "enemy4":
            enemy.size = CGSize(width: 50, height: 50)
            enemy.run(SKAction.sequence([SKAction.moveBy(x: 0, y: -size.height, duration: 4.0), SKAction.removeFromParent()]))
        case "enemy5":
            enemy.size = CGSize(width: 30, height: 30)
            enemy.run(SKAction.sequence([SKAction.moveBy(x: 0, y: -size.height, duration: 2.0), SKAction.removeFromParent()]))
        default:
            enemy.size = CGSize(width: 40, height: 40)
            enemy.run(SKAction.sequence([SKAction.moveBy(x: 0, y: -size.height, duration: 3.0), SKAction.removeFromParent()]))
        }
        
        let randomX = CGFloat.random(in: 0...size.width)
        enemy.position = CGPoint(x: randomX, y: size.height + enemy.size.height / 2)
        addChild(enemy)
    }
    
    func spawnPowerUp() {
        let powerUpTypes = ["powerUpSpeed", "powerUpShield", "powerUpDoubleDamage"]
        let randomIndex = Int(arc4random_uniform(UInt32(powerUpTypes.count)))
        let powerUpType = powerUpTypes[randomIndex]
        let powerUp = SKSpriteNode(imageNamed: powerUpType)
        powerUp.name = powerUpType
        
        powerUp.size = CGSize(width: 20, height: 20)
        
        let randomX = CGFloat.random(in: 0...size.width)
        powerUp.position = CGPoint(x: randomX, y: size.height + powerUp.size.height / 2)
        addChild(powerUp)
        
        let moveAction = SKAction.moveBy(x: 0, y: -size.height, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])
        powerUp.run(sequence)
    }
    
    func activatePowerUp(_ powerUpType: String) {
        switch powerUpType {
        case "powerUpSpeed":
            run(SKAction.playSoundFileNamed("powerUp.wav", waitForCompletion: false))
            let speedAction = SKAction.run { [weak self] in
                self?.isPoweredUp = true
            }
            let waitAction = SKAction.wait(forDuration: 5.0)
            let endPowerUpAction = SKAction.run { [weak self] in
                self?.isPoweredUp = false
            }
            let sequence = SKAction.sequence([speedAction, waitAction, endPowerUpAction])
            run(sequence)
            
        case "powerUpShield":
            run(SKAction.playSoundFileNamed("shield.wav", waitForCompletion: false))
            playerLife += 1  // シールドアイテムを取得するとライフが増える
            
        case "powerUpDoubleDamage":
            run(SKAction.playSoundFileNamed("doubleDamage.wav", waitForCompletion: false))
            let doubleDamageAction = SKAction.run { [weak self] in
                self?.isPoweredUp = true
            }
            let waitAction = SKAction.wait(forDuration: 5.0)
            let endPowerUpAction = SKAction.run { [weak self] in
                self?.isPoweredUp = false
            }
            let sequence = SKAction.sequence([doubleDamageAction, waitAction, endPowerUpAction])
            run(sequence)
            
        default:
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for bullet in children where bullet.name == "bullet" {
            for enemy in children where enemy.name == "enemy" {
                if bullet.frame.intersects(enemy.frame) {
                    bullet.removeFromParent()
                    enemy.removeFromParent()
                    score += 1
                    if score > highScore {
                        highScore = score
                    }
                }
            }
            
            if let boss = childNode(withName: "boss") {
                if bullet.frame.intersects(boss.frame) {
                    bullet.removeFromParent()
                    bossLife -= 1
                    if bossLife <= 0 {
                        boss.removeFromParent()
                        score += 20  // ボスを倒したときのスコアを増加
                        if score > highScore {
                            highScore = score
                        }
                    }
                }
            }
        }
        
        if let player = childNode(withName: "player") as? SKSpriteNode {
            for enemy in children where enemy.name == "enemy" {
                if enemy.frame.intersects(player.frame) {
                    enemy.removeFromParent()
                    playerLife -= 1
                    if playerLife <= 0 {
                        gameOver()
                    }
                }
            }
            
            for powerUp in children where powerUp.name == "powerUp" || powerUp.name == "powerUpSpeed" || powerUp.name == "powerUpShield" || powerUp.name == "powerUpDoubleDamage" {
                if powerUp.frame.intersects(player.frame) {
                    powerUp.removeFromParent()
                    activatePowerUp(powerUp.name!)
                }
            }
            
            for bossBullet in children where bossBullet.name == "bossBullet" {
                if bossBullet.frame.intersects(player.frame) {
                    bossBullet.removeFromParent()
                    playerLife -= 1
                    if playerLife <= 0 {
                        gameOver()
                    }
                }
            }
        }
    }
    
    func gameOver() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameOverScene = GameOverScene(size: size)
        gameOverScene.scaleMode = scaleMode
        view?.presentScene(gameOverScene, transition: transition)
        
        if score > highScore {
            highScore = score
        }
    }
    
    func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            backgroundMusicPlayer = try? AVAudioPlayer(contentsOf: musicURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.play()
        }
    }
}

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        let startLabel = SKLabelNode(fontNamed: "Chalkduster")
        startLabel.fontSize = 40
        startLabel.fontColor = SKColor.white
        startLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startLabel.text = "Tap to Start"
        addChild(startLabel)
        
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        let highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        highScoreLabel.fontSize = 20
        highScoreLabel.fontColor = SKColor.yellow
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        highScoreLabel.text = "High Score: \(highScore)"
        addChild(highScoreLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        view?.presentScene(gameScene, transition: transition)
    }
}

class GameOverScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverLabel.text = "Game Over"
        addChild(gameOverLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.fontSize = 20
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        restartLabel.text = "Tap to Restart"
        addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        view?.presentScene(gameScene, transition: transition)
    }
}
