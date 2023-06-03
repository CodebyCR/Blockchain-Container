//
//  Blockchain.swift
//
//
//  Created by Christoph Rohde on 03.06.23.
//

import Foundation
import CryptoKit

struct Block<T: Codable>: Codable {
    let index: Int
    let timestamp: Date
    let data: T
    let previousHash: Data
    var hash: Data {
        get {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(self)
            return SHA256.hash(data: data)
        }
    }
}

class Blockchain<T: Codable>: Iterable {
    private var chain: [Block<T>] = []

    init() {
        createGenesisBlock()
    }

    /// creates a genesis block as root of the chain
    private func createGenesisBlock() {
        let data = Data()
        let genesisBlock = Block<T>(index: 0, timestamp: Date(), data: data, previousHash: Data())
        chain.append(genesisBlock)
    }

    /// Adds a block to the blockchain
    func addBlock(data: T) {
        let previousBlock = chain.last!
        let newBlock = Block<T>(index: previousBlock.index + 1, timestamp: Date(), data: data, previousHash: previousBlock.hash)
        chain.append(newBlock)
    }

    func validate() -> Bool {
        for (index, block) in chain.enumerated() {
            if index > 0 && block.hash != block.hash {
                return false
            }

            if index > 0 && block.previousHash != chain[index - 1].hash {
                return false
            }
        }

        return true
    }

    /// Iterrator fuunction for iterating over whole Blockchain
    func makeIterator() -> IndexingIterator<[Block<T>]> {
        return chain.makeIterator()
    }
    
    func prettyPrint() {
        print("Blockchain:")
        for block in chain {
            print("Index: \(block.index)")
            print("Timestamp: \(block.timestamp)")
            print("Data: \(block.data)")
            print("Previous Hash:\n\(block.previousHash.hexEncodedString())")
            print("Self Hash:\n\(block.hash.hexEncodedString())")
            print(String(repeating: '-', count: 64))
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

// Beispielverwendung:
struct Transaction: Codable {
    let from:   String
    let to:     String
    let amount: Double
}

let blockchain      = Blockchain<Transaction>()
let transaction1    = Transaction(from: "Alice",   to: "Bob",      amount: 1.0)
let transaction2    = Transaction(from: "Bob",     to: "Charlie",  amount: 0.5)

blockchain.addBlock(data: transaction1)
blockchain.addBlock(data: transaction2)

blockchain.prettyPrint()
