//
//  Node.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/25/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

open class Node: SKShapeNode {
    lazy var mask: SKCropNode = { [unowned self] in
        let node = SKCropNode()

        node.zPosition = 10.0

        node.maskNode = {
            let node = SKShapeNode(circleOfRadius: self.frame.width / 2)

            node.zPosition = 20.0
            node.fillColor = .white
            node.strokeColor = .clear

            return node
        }()

        self.addChild(node)

        _ = self.maskOverlay // Masking creates aliasing. This masks the aliasing.

        return node
    }()
    
    lazy var maskOverlay: SKShapeNode = { [unowned self] in
        let node = SKShapeNode(circleOfRadius: self.frame.width / 2)

        node.zPosition = 30.0
        node.fillColor = .clear
        node.strokeColor = self.strokeColor
        
        self.addChild(node)

        return node
    }()
    
    public lazy var sprite: SKSpriteNode = { [unowned self] in
        let sprite = SKSpriteNode()

        sprite.zPosition = 40.0
        sprite.size = self.frame.size

        self.mask.addChild(sprite)

        return sprite
    }()
    
    /**
     The images displayed by the node.
     */
    open var defaultImage: UIImage? {
        didSet {
            guard let image = defaultImage else { return }
            
            defaultTexture = SKTexture(image: image)
            
            if sprite.texture == nil {
                if let texture = defaultTexture {
                    sprite.run(.setTexture(texture))
                }
            }
        }
    }
    
    open var selectedImage: UIImage? {
        didSet {
            guard let image = selectedImage else { return }
            
            selectedTexture = SKTexture(image: image)
        }
    }
    
    /**
     The textures displayed by the node.
     */
    private var defaultTexture: SKTexture?
    private var selectedTexture: SKTexture?
    
    /**
     Selection scale
     */
    private var selectionScale: CGFloat = 4/3
    
    /**
     The color of the node.
     
     Also blends the color with the image.
     */
    open var color: UIColor {
        get { return sprite.color }
        set { sprite.color = newValue }
    }
    
    /**
     The selection state of the node.
     */
    open var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
            if isSelected {
                selectedAnimation()
            } else {
                deselectedAnimation()
            }
        }
    }
    
    /**
     Creates a circular node object.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - radius: The radius of the circle.
     
     - Returns: A new node.
     */
    public convenience init(radius: CGFloat, selectionScale scale: CGFloat) {
        self.init(circleOfRadius: radius)
        
        selectionScale = scale
        
        self.physicsBody = {
            let body = SKPhysicsBody(circleOfRadius: radius + 2)
            body.allowsRotation = false
            body.friction = 0
            body.linearDamping = 3
            return body
        }()
        
        _ = self.sprite
    }
    
    override open func removeFromParent() {
        removedAnimation() {
            super.removeFromParent()
        }
    }
    
    /**
     The animation to execute when the node is selected.
     */
    open func selectedAnimation() {
        run(.scale(to: 4/3, duration: 0.2))
        
        if let texture = selectedTexture {
            sprite.run(.setTexture(texture))
        }
    }
    
    /**
     The animation to execute when the node is deselected.
     */
    open func deselectedAnimation() {
        run(.scale(to: 1, duration: 0.2))
        
        if let texture = defaultTexture {
            sprite.run(.setTexture(texture))
        }
    }
    
    /**
     The animation to execute when the node is removed.
     
     - important: You must call the completion block.
     
     - parameter completion: The block to execute when the animation is complete. You must call this handler and should do so as soon as possible.
     */
    open func removedAnimation(completion: @escaping () -> Void) {
        run(.fadeOut(withDuration: 0.2), completion: completion)
    }
}
